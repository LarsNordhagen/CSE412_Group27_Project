"""
crowdflow.app.db
----------------
PostgreSQL connection helpers built on psycopg2.

Connection pooling is used so per-request DB access stays cheap. Every
query runs through `query()` / `execute()`, which apply parameter binding
to prevent SQL injection — user-supplied values are NEVER concatenated
into SQL strings.
"""
from __future__ import annotations

import os
from contextlib import contextmanager
from typing import Any, Iterable

import psycopg2
import psycopg2.extras
from psycopg2 import pool


_pool: pool.SimpleConnectionPool | None = None


def init_pool() -> None:
    """Initialize the global connection pool from environment variables."""
    global _pool
    if _pool is not None:
        return

    _pool = pool.SimpleConnectionPool(
        minconn=1,
        maxconn=10,
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "5432")),
        dbname=os.getenv("DB_NAME", "crowdflow"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "postgres"),
    )


def close_pool() -> None:
    global _pool
    if _pool is not None:
        _pool.closeall()
        _pool = None


@contextmanager
def get_conn():
    """Context manager that lends a pooled connection."""
    if _pool is None:
        init_pool()
    assert _pool is not None
    conn = _pool.getconn()
    try:
        yield conn
    finally:
        _pool.putconn(conn)


@contextmanager
def get_cursor(commit: bool = False):
    """Context manager that yields a DictCursor.

    If `commit` is True the transaction is committed on success and
    rolled back on any exception.
    """
    with get_conn() as conn:
        cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        try:
            yield cur
            if commit:
                conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            cur.close()


def query(sql: str, params: Iterable[Any] | None = None) -> list[dict]:
    """Execute a SELECT and return all rows as a list of dicts."""
    with get_cursor() as cur:
        cur.execute(sql, params or ())
        return [dict(row) for row in cur.fetchall()]


def query_one(sql: str, params: Iterable[Any] | None = None) -> dict | None:
    """Execute a SELECT and return at most one row."""
    with get_cursor() as cur:
        cur.execute(sql, params or ())
        row = cur.fetchone()
        return dict(row) if row else None


def execute(sql: str, params: Iterable[Any] | None = None) -> dict | None:
    """Execute INSERT/UPDATE/DELETE; returns first row if RETURNING is used."""
    with get_cursor(commit=True) as cur:
        cur.execute(sql, params or ())
        if cur.description is not None:
            row = cur.fetchone()
            return dict(row) if row else None
        return None

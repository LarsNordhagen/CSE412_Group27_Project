"""
crowdflow.app.queries
---------------------
All SQL the app issues lives here. Keeping queries in one module makes
auditing easy and ensures every user-supplied value is parameterized.

Phase 02's required CRUD set is preserved verbatim; Phase 03 adds the
extra reads/writes the front-end needs to be useful.
"""
from __future__ import annotations

from . import db


# ============================================================
# READ — events, venues, users, seats, bookings
# ============================================================

def list_events() -> list[dict]:
    """Every event with its venue and organizer joined in."""
    return db.query("""
        SELECT
            e.event_id,
            e.event_name,
            e.event_date,
            e.status,
            v.venue_id,
            v.venue_name,
            v.address,
            u.user_id   AS organizer_id,
            u.full_name AS organizer_name,
            (
                SELECT COUNT(*)
                FROM crowdflow.bookings b
                WHERE b.event_id = e.event_id
                  AND b.status IN ('reserved', 'confirmed')
            ) AS active_bookings
        FROM crowdflow.events e
        JOIN crowdflow.venues v ON e.venue_id = v.venue_id
        JOIN crowdflow.users  u ON e.organizer_id = u.user_id
        ORDER BY e.event_date;
    """)


def get_event(event_id: int) -> dict | None:
    return db.query_one("""
        SELECT e.*, v.venue_name, v.address, u.full_name AS organizer_name
        FROM crowdflow.events e
        JOIN crowdflow.venues v ON e.venue_id = v.venue_id
        JOIN crowdflow.users  u ON e.organizer_id = u.user_id
        WHERE e.event_id = %s;
    """, (event_id,))


def list_venues() -> list[dict]:
    return db.query("""
        SELECT venue_id, venue_name, address, capacity
        FROM crowdflow.venues
        ORDER BY venue_name;
    """)


def list_users() -> list[dict]:
    return db.query("""
        SELECT user_id, full_name, email, created_at
        FROM crowdflow.users
        ORDER BY user_id;
    """)


def list_seats_for_venue(venue_id: int) -> list[dict]:
    return db.query("""
        SELECT seat_id, section, seat_number
        FROM crowdflow.seats
        WHERE venue_id = %s
        ORDER BY section, seat_number;
    """, (venue_id,))


def list_taken_seats_for_event(event_id: int) -> list[int]:
    """Seat IDs already held by an active (reserved/confirmed) booking."""
    rows = db.query("""
        SELECT DISTINCT unnest(seat_ids) AS seat_id
        FROM crowdflow.bookings
        WHERE event_id = %s
          AND status IN ('reserved', 'confirmed');
    """, (event_id,))
    return [r["seat_id"] for r in rows]


def list_bookings() -> list[dict]:
    """All bookings, joined with user and event for display."""
    return db.query("""
        SELECT
            b.booking_id,
            b.seat_ids,
            b.status,
            b.reserved_at,
            b.confirmed_at,
            array_length(b.seat_ids, 1) AS seat_count,
            u.user_id,
            u.full_name,
            e.event_id,
            e.event_name,
            e.event_date,
            v.venue_name,
            p.amount,
            p.payment_method,
            p.paid_at
        FROM crowdflow.bookings b
        JOIN crowdflow.users  u ON b.user_id  = u.user_id
        JOIN crowdflow.events e ON b.event_id = e.event_id
        JOIN crowdflow.venues v ON e.venue_id = v.venue_id
        LEFT JOIN crowdflow.payments p ON p.booking_id = b.booking_id
        ORDER BY b.booking_id DESC;
    """)


def bookings_for_event(event_name: str) -> list[dict]:
    """Phase 02 §4.1 — bookings for a specific event with payment details."""
    return db.query("""
        SELECT
            e.event_name,
            u.full_name,
            b.booking_id,
            b.seat_ids,
            b.status AS booking_status,
            p.amount,
            p.payment_method
        FROM crowdflow.bookings b
        JOIN crowdflow.users  u ON b.user_id  = u.user_id
        JOIN crowdflow.events e ON b.event_id = e.event_id
        LEFT JOIN crowdflow.payments p ON b.booking_id = p.booking_id
        WHERE e.event_name = %s
        ORDER BY b.booking_id;
    """, (event_name,))


def seat_counts_per_booking() -> list[dict]:
    """Phase 02 §4.2 — seat count per booking."""
    return db.query("""
        SELECT
            booking_id,
            user_id,
            array_length(seat_ids, 1) AS number_of_seats,
            status
        FROM crowdflow.bookings
        ORDER BY number_of_seats DESC;
    """)


# ============================================================
# CREATE — bookings, payments
# ============================================================

def create_booking(event_id: int, seat_ids: list[int], user_id: int) -> dict:
    """Phase 02 §4.3 — INSERT a new booking and RETURN the row."""
    return db.execute("""
        INSERT INTO crowdflow.bookings (event_id, seat_ids, user_id, status)
        VALUES (%s, %s, %s, 'reserved')
        RETURNING booking_id, event_id, seat_ids, user_id, status,
                  reserved_at, confirmed_at;
    """, (event_id, seat_ids, user_id))


def create_payment(booking_id: int, amount: float, method: str) -> dict:
    """Record a payment and confirm the parent booking in the same transaction."""
    with db.get_cursor(commit=True) as cur:
        cur.execute("""
            INSERT INTO crowdflow.payments (booking_id, amount, payment_method)
            VALUES (%s, %s, %s)
            RETURNING payment_id, booking_id, amount, payment_method, paid_at;
        """, (booking_id, amount, method))
        payment = dict(cur.fetchone())

        cur.execute("""
            UPDATE crowdflow.bookings
            SET status = 'confirmed',
                confirmed_at = CURRENT_TIMESTAMP
            WHERE booking_id = %s
            RETURNING booking_id, status, confirmed_at;
        """, (booking_id,))
        return {"payment": payment, "booking": dict(cur.fetchone())}


# ============================================================
# UPDATE — booking status
# ============================================================

def confirm_booking(booking_id: int) -> dict | None:
    """Mark a booking confirmed (Phase 02 §4.4 style)."""
    return db.execute("""
        UPDATE crowdflow.bookings
        SET status = 'confirmed',
            confirmed_at = CURRENT_TIMESTAMP
        WHERE booking_id = %s
        RETURNING booking_id, event_id, seat_ids, user_id, status,
                  reserved_at, confirmed_at;
    """, (booking_id,))


def cancel_booking(booking_id: int) -> dict | None:
    return db.execute("""
        UPDATE crowdflow.bookings
        SET status = 'cancelled'
        WHERE booking_id = %s
        RETURNING booking_id, status;
    """, (booking_id,))


# ============================================================
# DELETE — booking (cascade removes payment + attendance)
# ============================================================

def delete_booking(booking_id: int) -> dict | None:
    """Phase 02 §4.5 — delete and RETURN."""
    return db.execute("""
        DELETE FROM crowdflow.bookings
        WHERE booking_id = %s
        RETURNING booking_id, event_id, seat_ids, user_id, status;
    """, (booking_id,))


# ============================================================
# ANALYTICS — referenced in Phase 01 implementation plan
# ============================================================

def analytics_summary() -> dict:
    """Top-line numbers shown on the dashboard."""
    totals = db.query_one("""
        SELECT
            (SELECT COUNT(*) FROM crowdflow.events)             AS total_events,
            (SELECT COUNT(*) FROM crowdflow.users)              AS total_users,
            (SELECT COUNT(*) FROM crowdflow.bookings
                WHERE status = 'confirmed')                     AS confirmed_bookings,
            (SELECT COALESCE(SUM(amount), 0) FROM crowdflow.payments) AS total_revenue,
            (SELECT COUNT(*) FROM crowdflow.attendance)         AS total_checkins;
    """)
    return totals or {}


def revenue_per_event() -> list[dict]:
    return db.query("""
        SELECT
            e.event_id,
            e.event_name,
            COUNT(DISTINCT b.booking_id) FILTER (WHERE b.status = 'confirmed')
                                          AS confirmed_bookings,
            COALESCE(SUM(p.amount), 0)    AS revenue
        FROM crowdflow.events e
        LEFT JOIN crowdflow.bookings b ON b.event_id = e.event_id
        LEFT JOIN crowdflow.payments p ON p.booking_id = b.booking_id
        GROUP BY e.event_id, e.event_name
        ORDER BY revenue DESC;
    """)

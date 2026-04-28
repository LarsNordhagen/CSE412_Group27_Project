"""
crowdflow.app
-------------
Flask application factory for CrowdFlow (CSE 412 Phase 03).
"""
from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv
from flask import Flask

# Load .env from the project root before any module reads os.environ
ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")

from . import db  # noqa: E402  (intentional — env must be loaded first)


def create_app() -> Flask:
    app = Flask(
        __name__,
        template_folder="templates",
        static_folder="static",
    )
    app.config["SECRET_KEY"] = os.getenv("FLASK_SECRET_KEY", "dev-secret")
    app.config["JSON_SORT_KEYS"] = False

    # Initialize the connection pool eagerly so a misconfigured DB
    # surfaces at startup rather than on the first request.
    db.init_pool()

    from .routes import bp
    app.register_blueprint(bp)

    @app.teardown_appcontext
    def _release(_exc):  # pragma: no cover
        # Pooled connections are released per request inside get_conn();
        # nothing extra to do here, but the hook is wired for future use.
        return None

    return app

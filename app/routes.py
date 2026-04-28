"""
crowdflow.app.routes
--------------------
HTTP endpoints. Pages render Jinja templates; the /api/* routes return
JSON for AJAX-driven interactions (Phase 01 implementation plan).
"""
from __future__ import annotations

from flask import Blueprint, jsonify, render_template, request

from . import queries

bp = Blueprint("crowdflow", __name__)


# ============================================================
# Pages
# ============================================================

@bp.get("/")
def home():
    summary = queries.analytics_summary()
    revenue = queries.revenue_per_event()
    return render_template("dashboard.html", summary=summary, revenue=revenue)


@bp.get("/events")
def events_page():
    events = queries.list_events()
    return render_template("events.html", events=events)


@bp.get("/events/<int:event_id>")
def event_detail(event_id: int):
    event = queries.get_event(event_id)
    if not event:
        return render_template("404.html"), 404
    seats = queries.list_seats_for_venue(event["venue_id"])
    taken = set(queries.list_taken_seats_for_event(event_id))
    users = queries.list_users()
    return render_template(
        "event_detail.html",
        event=event,
        seats=seats,
        taken=taken,
        users=users,
    )


@bp.get("/bookings")
def bookings_page():
    bookings = queries.list_bookings()
    return render_template("bookings.html", bookings=bookings)


# ============================================================
# JSON API — used by the front-end's AJAX layer
# ============================================================

@bp.get("/api/events")
def api_events():
    return jsonify(queries.list_events())


@bp.get("/api/events/<int:event_id>/taken-seats")
def api_taken_seats(event_id: int):
    return jsonify(queries.list_taken_seats_for_event(event_id))


@bp.get("/api/bookings")
def api_bookings():
    return jsonify(queries.list_bookings())


@bp.post("/api/bookings")
def api_create_booking():
    """CREATE — insert a new booking from form data."""
    data = request.get_json(silent=True) or request.form
    try:
        event_id = int(data["event_id"])
        user_id = int(data["user_id"])
        seat_ids = [int(s) for s in data.getlist("seat_ids")] \
            if hasattr(data, "getlist") else [int(s) for s in data["seat_ids"]]
    except (KeyError, ValueError, TypeError):
        return jsonify({"error": "event_id, user_id and seat_ids[] are required"}), 400

    if not seat_ids:
        return jsonify({"error": "Pick at least one seat."}), 400

    # Server-side double-booking guard (defense in depth on top of UI filtering)
    taken = set(queries.list_taken_seats_for_event(event_id))
    conflicts = sorted(set(seat_ids) & taken)
    if conflicts:
        return jsonify({
            "error": f"Seat(s) already taken: {conflicts}"
        }), 409

    booking = queries.create_booking(event_id, seat_ids, user_id)
    return jsonify(booking), 201


@bp.post("/api/bookings/<int:booking_id>/confirm")
def api_confirm_booking(booking_id: int):
    """UPDATE — confirm a booking (no payment recorded)."""
    row = queries.confirm_booking(booking_id)
    if row is None:
        return jsonify({"error": "Booking not found."}), 404
    return jsonify(row)


@bp.post("/api/bookings/<int:booking_id>/cancel")
def api_cancel_booking(booking_id: int):
    """UPDATE — flip status to 'cancelled' without removing the row."""
    row = queries.cancel_booking(booking_id)
    if row is None:
        return jsonify({"error": "Booking not found."}), 404
    return jsonify(row)


@bp.post("/api/bookings/<int:booking_id>/pay")
def api_pay_booking(booking_id: int):
    """UPDATE — record a payment and confirm the booking atomically."""
    data = request.get_json(silent=True) or request.form
    try:
        amount = float(data["amount"])
        method = str(data["payment_method"]).lower()
    except (KeyError, ValueError, TypeError):
        return jsonify({"error": "amount and payment_method are required"}), 400

    if method not in {"credit", "debit", "cash"}:
        return jsonify({"error": "payment_method must be credit, debit, or cash"}), 400

    if amount <= 0:
        return jsonify({"error": "amount must be > 0"}), 400

    result = queries.create_payment(booking_id, amount, method)
    return jsonify(result), 201


@bp.delete("/api/bookings/<int:booking_id>")
def api_delete_booking(booking_id: int):
    """DELETE — remove a booking (payment + attendance cascade)."""
    row = queries.delete_booking(booking_id)
    if row is None:
        return jsonify({"error": "Booking not found."}), 404
    return jsonify(row)


# ============================================================
# Errors
# ============================================================

@bp.app_errorhandler(404)
def not_found(_e):
    return render_template("404.html"), 404

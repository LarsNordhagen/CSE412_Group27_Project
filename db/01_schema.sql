-- ============================================================
-- CrowdFlow Event Booking System - Phase 02 Schema
-- Group 27: Lars Nordhagen, Megan Tricia Ng,
--           Satya Neriyanuru, Vanshika Parihar
-- CSE 412 Database Management - Spring 2026
-- ============================================================

DROP SCHEMA IF EXISTS crowdflow CASCADE;
CREATE SCHEMA crowdflow;

-- ---------- Custom ENUM types ----------
CREATE TYPE crowdflow.event_status   AS ENUM ('upcoming', 'ongoing', 'completed', 'cancelled');
CREATE TYPE crowdflow.booking_status AS ENUM ('reserved', 'confirmed', 'cancelled', 'expired');
CREATE TYPE crowdflow.payment_method AS ENUM ('credit', 'debit', 'cash');

-- ---------- Users ----------
CREATE TABLE crowdflow.users (
    user_id     SERIAL PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    password    VARCHAR(255) NOT NULL
);

-- ---------- Venues ----------
CREATE TABLE crowdflow.venues (
    venue_id    SERIAL PRIMARY KEY,
    venue_name  VARCHAR(100) NOT NULL,
    address     VARCHAR(255) NOT NULL,
    capacity    INTEGER      NOT NULL DEFAULT 1 CHECK (capacity >= 1)
);

-- ---------- Seats ----------
CREATE TABLE crowdflow.seats (
    seat_id      SERIAL PRIMARY KEY,
    venue_id     INTEGER NOT NULL REFERENCES crowdflow.venues(venue_id) ON DELETE CASCADE,
    section      VARCHAR(50) NOT NULL,
    seat_number  VARCHAR(10) NOT NULL,
    UNIQUE (venue_id, section, seat_number)
);

-- ---------- Events ----------
CREATE TABLE crowdflow.events (
    event_id      SERIAL PRIMARY KEY,
    event_name    VARCHAR(200) NOT NULL,
    venue_id      INTEGER NOT NULL REFERENCES crowdflow.venues(venue_id),
    organizer_id  INTEGER NOT NULL REFERENCES crowdflow.users(user_id),
    event_date    TIMESTAMP NOT NULL,
    status        crowdflow.event_status NOT NULL DEFAULT 'upcoming',
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------- Bookings ----------
CREATE TABLE crowdflow.bookings (
    booking_id    SERIAL PRIMARY KEY,
    event_id      INTEGER NOT NULL REFERENCES crowdflow.events(event_id),
    seat_ids      INTEGER[] NOT NULL,
    user_id       INTEGER NOT NULL REFERENCES crowdflow.users(user_id),
    status        crowdflow.booking_status NOT NULL DEFAULT 'reserved',
    reserved_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    confirmed_at  TIMESTAMP NULL,
    CHECK (array_length(seat_ids, 1) >= 1)
);

-- ---------- Payments ----------
CREATE TABLE crowdflow.payments (
    payment_id      SERIAL PRIMARY KEY,
    booking_id      INTEGER UNIQUE REFERENCES crowdflow.bookings(booking_id) ON DELETE CASCADE,
    amount          DECIMAL(10,2) NOT NULL,
    payment_method  crowdflow.payment_method NOT NULL,
    paid_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------- Attendance ----------
CREATE TABLE crowdflow.attendance (
    attendance_id   SERIAL PRIMARY KEY,
    booking_id      INTEGER UNIQUE NOT NULL REFERENCES crowdflow.bookings(booking_id) ON DELETE CASCADE,
    checked_in_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

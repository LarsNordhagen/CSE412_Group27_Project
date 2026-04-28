-- ============================================================
-- CrowdFlow Seed Data
-- Counts (per Phase 02 report):
--   Users: 15, Venues: 5, Seats: 30, Events: 8,
--   Bookings: 12, Payments: 9, Attendance: 5
-- ============================================================

-- ---------- Users (15) ----------
INSERT INTO crowdflow.users (full_name, email, password) VALUES
    ('Alice Johnson',   'alice.johnson@asu.edu',   'hashed_pw_01'),
    ('Bob Martinez',    'bob.martinez@asu.edu',    'hashed_pw_02'),
    ('Clara Chen',      'clara.chen@gmail.com',    'hashed_pw_03'),
    ('David Kim',       'david.kim@yahoo.com',     'hashed_pw_04'),
    ('Emily Torres',    'emily.torres@asu.edu',    'hashed_pw_05'),
    ('Frank Nguyen',    'frank.nguyen@asu.edu',    'hashed_pw_06'),
    ('Grace Patel',     'grace.patel@gmail.com',   'hashed_pw_07'),
    ('Henry Wright',    'henry.wright@asu.edu',    'hashed_pw_08'),
    ('Isabella Garcia', 'isabella.g@yahoo.com',    'hashed_pw_09'),
    ('Jake Thompson',   'jake.thompson@asu.edu',   'hashed_pw_10'),
    ('Kavya Reddy',     'kavya.reddy@gmail.com',   'hashed_pw_11'),
    ('Liam Brown',      'liam.brown@asu.edu',      'hashed_pw_12'),
    ('Mia Robinson',    'mia.robinson@asu.edu',    'hashed_pw_13'),
    ('Noah Davis',      'noah.davis@gmail.com',    'hashed_pw_14'),
    ('Olivia Walker',   'olivia.walker@asu.edu',   'hashed_pw_15');

-- ---------- Venues (5) ----------
INSERT INTO crowdflow.venues (venue_name, address, capacity) VALUES
    ('Desert Financial Arena', '600 E Veterans Way, Tempe, AZ',          14000),
    ('Gammage Auditorium',     '1200 S Forest Ave, Tempe, AZ',           3000),
    ('Mullett Arena',          '411 E Orange St, Tempe, AZ',             5000),
    ('Sun Devil Stadium',      '500 E Veterans Way, Tempe, AZ',          53000),
    ('MU Ventana Ballroom',    '301 E Orange St, Tempe, AZ',             500);

-- ---------- Seats (30) — 6 per venue ----------
INSERT INTO crowdflow.seats (venue_id, section, seat_number) VALUES
    -- Venue 1: Desert Financial Arena
    (1, 'A',   '1'),  (1, 'A',   '2'),  (1, 'A',   '3'),
    (1, 'B',   '1'),  (1, 'B',   '2'),  (1, 'B',   '3'),
    -- Venue 2: Gammage Auditorium
    (2, 'Orchestra', '1'), (2, 'Orchestra', '2'), (2, 'Orchestra', '3'),
    (2, 'Balcony',   '1'), (2, 'Balcony',   '2'), (2, 'Balcony',   '3'),
    -- Venue 3: Mullett Arena
    (3, 'Lower', '1'), (3, 'Lower', '2'), (3, 'Lower', '3'),
    (3, 'Upper', '1'), (3, 'Upper', '2'), (3, 'Upper', '3'),
    -- Venue 4: Sun Devil Stadium
    (4, 'North', '1'), (4, 'North', '2'), (4, 'North', '3'),
    (4, 'South', '1'), (4, 'South', '2'), (4, 'South', '3'),
    -- Venue 5: MU Ventana Ballroom
    (5, 'Main',  '1'), (5, 'Main',  '2'), (5, 'Main',  '3'),
    (5, 'VIP',   '1'), (5, 'VIP',   '2'), (5, 'VIP',   '3');

-- ---------- Events (8) ----------
INSERT INTO crowdflow.events (event_name, venue_id, organizer_id, event_date, status) VALUES
    ('ASU Spring Concert 2026',    1, 1, '2026-05-12 19:00:00', 'upcoming'),
    ('Sun Devils vs UCLA',         3, 2, '2026-05-18 18:30:00', 'upcoming'),
    ('Tempe Symphony Gala',        2, 3, '2026-05-22 20:00:00', 'upcoming'),
    ('Founders Day Lecture',       5, 4, '2026-05-25 14:00:00', 'upcoming'),
    ('AZ Tech Fest 2026',          1, 5, '2026-06-04 10:00:00', 'upcoming'),
    ('Cybersecurity Career Fair',  5, 1, '2026-04-15 09:00:00', 'completed'),
    ('Rock Festival West',         4, 6, '2026-04-08 17:00:00', 'completed'),
    ('Indie Film Showcase',        2, 7, '2026-04-20 19:30:00', 'cancelled');

-- ---------- Bookings (12) ----------
-- Mix of confirmed, reserved, and cancelled across multiple events/users
INSERT INTO crowdflow.bookings (event_id, seat_ids, user_id, status, reserved_at, confirmed_at) VALUES
    (1, ARRAY[1,2],     6,  'confirmed', '2026-04-01 10:15:00', '2026-04-01 10:18:00'),
    (1, ARRAY[4],       8,  'confirmed', '2026-04-02 11:20:00', '2026-04-02 11:22:00'),
    (1, ARRAY[6,7,8],  10,  'reserved',  '2026-04-25 09:00:00',  NULL),
    (2, ARRAY[13,14],  11,  'confirmed', '2026-04-03 12:00:00', '2026-04-03 12:05:00'),
    (2, ARRAY[15],     13,  'reserved',  '2026-04-25 14:30:00',  NULL),
    (3, ARRAY[7,8,9],  14,  'confirmed', '2026-04-05 16:45:00', '2026-04-05 16:50:00'),
    (3, ARRAY[10,11],   2,  'cancelled', '2026-04-06 09:30:00',  NULL),
    (4, ARRAY[25,26],  12,  'confirmed', '2026-04-07 13:10:00', '2026-04-07 13:15:00'),
    (5, ARRAY[5,6],     4,  'confirmed', '2026-04-08 18:00:00', '2026-04-08 18:05:00'),
    (6, ARRAY[28],     15,  'confirmed', '2026-04-10 08:45:00', '2026-04-10 08:50:00'),
    (7, ARRAY[19,20],   3,  'confirmed', '2026-04-02 19:00:00', '2026-04-02 19:03:00'),
    (3, ARRAY[12],      9,  'confirmed', '2026-04-12 11:00:00', '2026-04-12 11:05:00');

-- ---------- Payments (9) — only against confirmed bookings ----------
INSERT INTO crowdflow.payments (booking_id, amount, payment_method) VALUES
    (1,  75.00, 'credit'),
    (2,  40.00, 'debit'),
    (4,  90.00, 'credit'),
    (6, 180.00, 'credit'),
    (8,  60.00, 'cash'),
    (9,  50.00, 'credit'),
    (10, 25.00, 'debit'),
    (11, 70.00, 'credit'),
    (12, 35.00, 'debit');

-- ---------- Attendance (5) — confirmed bookings that checked in ----------
INSERT INTO crowdflow.attendance (booking_id, checked_in_at) VALUES
    (10, '2026-04-15 09:12:00'),
    (11, '2026-04-08 17:30:00'),
    (1,  '2026-05-12 18:45:00'),
    (4,  '2026-05-18 18:00:00'),
    (6,  '2026-05-22 19:30:00');

-- ---------- Verification ----------
SELECT 'users'       AS table_name, COUNT(*) AS rows FROM crowdflow.users
UNION ALL SELECT 'venues',    COUNT(*) FROM crowdflow.venues
UNION ALL SELECT 'seats',     COUNT(*) FROM crowdflow.seats
UNION ALL SELECT 'events',    COUNT(*) FROM crowdflow.events
UNION ALL SELECT 'bookings',  COUNT(*) FROM crowdflow.bookings
UNION ALL SELECT 'payments',  COUNT(*) FROM crowdflow.payments
UNION ALL SELECT 'attendance', COUNT(*) FROM crowdflow.attendance;

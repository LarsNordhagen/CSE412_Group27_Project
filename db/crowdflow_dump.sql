--
-- PostgreSQL database dump
--

\restrict bl5OtGIj1NpwIhxtMajf5HeFubU75X6Vw2ORUfcJQ9an1GYdAqYeBlopw8I0Mkm

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY crowdflow.seats DROP CONSTRAINT IF EXISTS seats_venue_id_fkey;
ALTER TABLE IF EXISTS ONLY crowdflow.payments DROP CONSTRAINT IF EXISTS payments_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY crowdflow.events DROP CONSTRAINT IF EXISTS events_venue_id_fkey;
ALTER TABLE IF EXISTS ONLY crowdflow.events DROP CONSTRAINT IF EXISTS events_organizer_id_fkey;
ALTER TABLE IF EXISTS ONLY crowdflow.bookings DROP CONSTRAINT IF EXISTS bookings_user_id_fkey;
ALTER TABLE IF EXISTS ONLY crowdflow.bookings DROP CONSTRAINT IF EXISTS bookings_event_id_fkey;
ALTER TABLE IF EXISTS ONLY crowdflow.attendance DROP CONSTRAINT IF EXISTS attendance_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY crowdflow.venues DROP CONSTRAINT IF EXISTS venues_pkey;
ALTER TABLE IF EXISTS ONLY crowdflow.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY crowdflow.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY crowdflow.seats DROP CONSTRAINT IF EXISTS seats_venue_id_section_seat_number_key;
ALTER TABLE IF EXISTS ONLY crowdflow.seats DROP CONSTRAINT IF EXISTS seats_pkey;
ALTER TABLE IF EXISTS ONLY crowdflow.payments DROP CONSTRAINT IF EXISTS payments_pkey;
ALTER TABLE IF EXISTS ONLY crowdflow.payments DROP CONSTRAINT IF EXISTS payments_booking_id_key;
ALTER TABLE IF EXISTS ONLY crowdflow.events DROP CONSTRAINT IF EXISTS events_pkey;
ALTER TABLE IF EXISTS ONLY crowdflow.bookings DROP CONSTRAINT IF EXISTS bookings_pkey;
ALTER TABLE IF EXISTS ONLY crowdflow.attendance DROP CONSTRAINT IF EXISTS attendance_pkey;
ALTER TABLE IF EXISTS ONLY crowdflow.attendance DROP CONSTRAINT IF EXISTS attendance_booking_id_key;
ALTER TABLE IF EXISTS crowdflow.venues ALTER COLUMN venue_id DROP DEFAULT;
ALTER TABLE IF EXISTS crowdflow.users ALTER COLUMN user_id DROP DEFAULT;
ALTER TABLE IF EXISTS crowdflow.seats ALTER COLUMN seat_id DROP DEFAULT;
ALTER TABLE IF EXISTS crowdflow.payments ALTER COLUMN payment_id DROP DEFAULT;
ALTER TABLE IF EXISTS crowdflow.events ALTER COLUMN event_id DROP DEFAULT;
ALTER TABLE IF EXISTS crowdflow.bookings ALTER COLUMN booking_id DROP DEFAULT;
ALTER TABLE IF EXISTS crowdflow.attendance ALTER COLUMN attendance_id DROP DEFAULT;
DROP SEQUENCE IF EXISTS crowdflow.venues_venue_id_seq;
DROP TABLE IF EXISTS crowdflow.venues;
DROP SEQUENCE IF EXISTS crowdflow.users_user_id_seq;
DROP TABLE IF EXISTS crowdflow.users;
DROP SEQUENCE IF EXISTS crowdflow.seats_seat_id_seq;
DROP TABLE IF EXISTS crowdflow.seats;
DROP SEQUENCE IF EXISTS crowdflow.payments_payment_id_seq;
DROP TABLE IF EXISTS crowdflow.payments;
DROP SEQUENCE IF EXISTS crowdflow.events_event_id_seq;
DROP TABLE IF EXISTS crowdflow.events;
DROP SEQUENCE IF EXISTS crowdflow.bookings_booking_id_seq;
DROP TABLE IF EXISTS crowdflow.bookings;
DROP SEQUENCE IF EXISTS crowdflow.attendance_attendance_id_seq;
DROP TABLE IF EXISTS crowdflow.attendance;
DROP TYPE IF EXISTS crowdflow.payment_method;
DROP TYPE IF EXISTS crowdflow.event_status;
DROP TYPE IF EXISTS crowdflow.booking_status;
DROP SCHEMA IF EXISTS crowdflow;
--
-- Name: crowdflow; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA crowdflow;


ALTER SCHEMA crowdflow OWNER TO postgres;

--
-- Name: booking_status; Type: TYPE; Schema: crowdflow; Owner: postgres
--

CREATE TYPE crowdflow.booking_status AS ENUM (
    'reserved',
    'confirmed',
    'cancelled',
    'expired'
);


ALTER TYPE crowdflow.booking_status OWNER TO postgres;

--
-- Name: event_status; Type: TYPE; Schema: crowdflow; Owner: postgres
--

CREATE TYPE crowdflow.event_status AS ENUM (
    'upcoming',
    'ongoing',
    'completed',
    'cancelled'
);


ALTER TYPE crowdflow.event_status OWNER TO postgres;

--
-- Name: payment_method; Type: TYPE; Schema: crowdflow; Owner: postgres
--

CREATE TYPE crowdflow.payment_method AS ENUM (
    'credit',
    'debit',
    'cash'
);


ALTER TYPE crowdflow.payment_method OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: attendance; Type: TABLE; Schema: crowdflow; Owner: postgres
--

CREATE TABLE crowdflow.attendance (
    attendance_id integer NOT NULL,
    booking_id integer NOT NULL,
    checked_in_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE crowdflow.attendance OWNER TO postgres;

--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE; Schema: crowdflow; Owner: postgres
--

CREATE SEQUENCE crowdflow.attendance_attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE crowdflow.attendance_attendance_id_seq OWNER TO postgres;

--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: crowdflow; Owner: postgres
--

ALTER SEQUENCE crowdflow.attendance_attendance_id_seq OWNED BY crowdflow.attendance.attendance_id;


--
-- Name: bookings; Type: TABLE; Schema: crowdflow; Owner: postgres
--

CREATE TABLE crowdflow.bookings (
    booking_id integer NOT NULL,
    event_id integer NOT NULL,
    seat_ids integer[] NOT NULL,
    user_id integer NOT NULL,
    status crowdflow.booking_status DEFAULT 'reserved'::crowdflow.booking_status NOT NULL,
    reserved_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT bookings_seat_ids_check CHECK ((array_length(seat_ids, 1) >= 1))
);


ALTER TABLE crowdflow.bookings OWNER TO postgres;

--
-- Name: bookings_booking_id_seq; Type: SEQUENCE; Schema: crowdflow; Owner: postgres
--

CREATE SEQUENCE crowdflow.bookings_booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE crowdflow.bookings_booking_id_seq OWNER TO postgres;

--
-- Name: bookings_booking_id_seq; Type: SEQUENCE OWNED BY; Schema: crowdflow; Owner: postgres
--

ALTER SEQUENCE crowdflow.bookings_booking_id_seq OWNED BY crowdflow.bookings.booking_id;


--
-- Name: events; Type: TABLE; Schema: crowdflow; Owner: postgres
--

CREATE TABLE crowdflow.events (
    event_id integer NOT NULL,
    event_name character varying(200) NOT NULL,
    venue_id integer NOT NULL,
    organizer_id integer NOT NULL,
    event_date timestamp without time zone NOT NULL,
    status crowdflow.event_status DEFAULT 'upcoming'::crowdflow.event_status NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE crowdflow.events OWNER TO postgres;

--
-- Name: events_event_id_seq; Type: SEQUENCE; Schema: crowdflow; Owner: postgres
--

CREATE SEQUENCE crowdflow.events_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE crowdflow.events_event_id_seq OWNER TO postgres;

--
-- Name: events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: crowdflow; Owner: postgres
--

ALTER SEQUENCE crowdflow.events_event_id_seq OWNED BY crowdflow.events.event_id;


--
-- Name: payments; Type: TABLE; Schema: crowdflow; Owner: postgres
--

CREATE TABLE crowdflow.payments (
    payment_id integer NOT NULL,
    booking_id integer,
    amount numeric(10,2) NOT NULL,
    payment_method crowdflow.payment_method NOT NULL,
    paid_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE crowdflow.payments OWNER TO postgres;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: crowdflow; Owner: postgres
--

CREATE SEQUENCE crowdflow.payments_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE crowdflow.payments_payment_id_seq OWNER TO postgres;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: crowdflow; Owner: postgres
--

ALTER SEQUENCE crowdflow.payments_payment_id_seq OWNED BY crowdflow.payments.payment_id;


--
-- Name: seats; Type: TABLE; Schema: crowdflow; Owner: postgres
--

CREATE TABLE crowdflow.seats (
    seat_id integer NOT NULL,
    venue_id integer NOT NULL,
    section character varying(50) NOT NULL,
    seat_number character varying(10) NOT NULL
);


ALTER TABLE crowdflow.seats OWNER TO postgres;

--
-- Name: seats_seat_id_seq; Type: SEQUENCE; Schema: crowdflow; Owner: postgres
--

CREATE SEQUENCE crowdflow.seats_seat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE crowdflow.seats_seat_id_seq OWNER TO postgres;

--
-- Name: seats_seat_id_seq; Type: SEQUENCE OWNED BY; Schema: crowdflow; Owner: postgres
--

ALTER SEQUENCE crowdflow.seats_seat_id_seq OWNED BY crowdflow.seats.seat_id;


--
-- Name: users; Type: TABLE; Schema: crowdflow; Owner: postgres
--

CREATE TABLE crowdflow.users (
    user_id integer NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    password character varying(255) NOT NULL
);


ALTER TABLE crowdflow.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: crowdflow; Owner: postgres
--

CREATE SEQUENCE crowdflow.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE crowdflow.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: crowdflow; Owner: postgres
--

ALTER SEQUENCE crowdflow.users_user_id_seq OWNED BY crowdflow.users.user_id;


--
-- Name: venues; Type: TABLE; Schema: crowdflow; Owner: postgres
--

CREATE TABLE crowdflow.venues (
    venue_id integer NOT NULL,
    venue_name character varying(100) NOT NULL,
    address character varying(255) NOT NULL,
    capacity integer DEFAULT 1 NOT NULL,
    CONSTRAINT venues_capacity_check CHECK ((capacity >= 1))
);


ALTER TABLE crowdflow.venues OWNER TO postgres;

--
-- Name: venues_venue_id_seq; Type: SEQUENCE; Schema: crowdflow; Owner: postgres
--

CREATE SEQUENCE crowdflow.venues_venue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE crowdflow.venues_venue_id_seq OWNER TO postgres;

--
-- Name: venues_venue_id_seq; Type: SEQUENCE OWNED BY; Schema: crowdflow; Owner: postgres
--

ALTER SEQUENCE crowdflow.venues_venue_id_seq OWNED BY crowdflow.venues.venue_id;


--
-- Name: attendance attendance_id; Type: DEFAULT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.attendance ALTER COLUMN attendance_id SET DEFAULT nextval('crowdflow.attendance_attendance_id_seq'::regclass);


--
-- Name: bookings booking_id; Type: DEFAULT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.bookings ALTER COLUMN booking_id SET DEFAULT nextval('crowdflow.bookings_booking_id_seq'::regclass);


--
-- Name: events event_id; Type: DEFAULT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.events ALTER COLUMN event_id SET DEFAULT nextval('crowdflow.events_event_id_seq'::regclass);


--
-- Name: payments payment_id; Type: DEFAULT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.payments ALTER COLUMN payment_id SET DEFAULT nextval('crowdflow.payments_payment_id_seq'::regclass);


--
-- Name: seats seat_id; Type: DEFAULT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.seats ALTER COLUMN seat_id SET DEFAULT nextval('crowdflow.seats_seat_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.users ALTER COLUMN user_id SET DEFAULT nextval('crowdflow.users_user_id_seq'::regclass);


--
-- Name: venues venue_id; Type: DEFAULT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.venues ALTER COLUMN venue_id SET DEFAULT nextval('crowdflow.venues_venue_id_seq'::regclass);


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: crowdflow; Owner: postgres
--

COPY crowdflow.attendance (attendance_id, booking_id, checked_in_at) FROM stdin;
1	10	2026-04-15 09:12:00
2	11	2026-04-08 17:30:00
3	1	2026-05-12 18:45:00
4	4	2026-05-18 18:00:00
5	6	2026-05-22 19:30:00
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: crowdflow; Owner: postgres
--

COPY crowdflow.bookings (booking_id, event_id, seat_ids, user_id, status, reserved_at, confirmed_at) FROM stdin;
1	1	{1,2}	6	confirmed	2026-04-01 10:15:00	2026-04-01 10:18:00
2	1	{4}	8	confirmed	2026-04-02 11:20:00	2026-04-02 11:22:00
3	1	{6,7,8}	10	reserved	2026-04-25 09:00:00	\N
4	2	{13,14}	11	confirmed	2026-04-03 12:00:00	2026-04-03 12:05:00
5	2	{15}	13	reserved	2026-04-25 14:30:00	\N
6	3	{7,8,9}	14	confirmed	2026-04-05 16:45:00	2026-04-05 16:50:00
7	3	{10,11}	2	cancelled	2026-04-06 09:30:00	\N
8	4	{25,26}	12	confirmed	2026-04-07 13:10:00	2026-04-07 13:15:00
9	5	{5,6}	4	confirmed	2026-04-08 18:00:00	2026-04-08 18:05:00
10	6	{28}	15	confirmed	2026-04-10 08:45:00	2026-04-10 08:50:00
11	7	{19,20}	3	confirmed	2026-04-02 19:00:00	2026-04-02 19:03:00
12	3	{12}	9	confirmed	2026-04-12 11:00:00	2026-04-12 11:05:00
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: crowdflow; Owner: postgres
--

COPY crowdflow.events (event_id, event_name, venue_id, organizer_id, event_date, status, created_at) FROM stdin;
1	ASU Spring Concert 2026	1	1	2026-05-12 19:00:00	upcoming	2026-04-28 04:58:15.381617
2	Sun Devils vs UCLA	3	2	2026-05-18 18:30:00	upcoming	2026-04-28 04:58:15.381617
3	Tempe Symphony Gala	2	3	2026-05-22 20:00:00	upcoming	2026-04-28 04:58:15.381617
4	Founders Day Lecture	5	4	2026-05-25 14:00:00	upcoming	2026-04-28 04:58:15.381617
5	AZ Tech Fest 2026	1	5	2026-06-04 10:00:00	upcoming	2026-04-28 04:58:15.381617
6	Cybersecurity Career Fair	5	1	2026-04-15 09:00:00	completed	2026-04-28 04:58:15.381617
7	Rock Festival West	4	6	2026-04-08 17:00:00	completed	2026-04-28 04:58:15.381617
8	Indie Film Showcase	2	7	2026-04-20 19:30:00	cancelled	2026-04-28 04:58:15.381617
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: crowdflow; Owner: postgres
--

COPY crowdflow.payments (payment_id, booking_id, amount, payment_method, paid_at) FROM stdin;
1	1	75.00	credit	2026-04-28 04:58:15.392946
2	2	40.00	debit	2026-04-28 04:58:15.392946
3	4	90.00	credit	2026-04-28 04:58:15.392946
4	6	180.00	credit	2026-04-28 04:58:15.392946
5	8	60.00	cash	2026-04-28 04:58:15.392946
6	9	50.00	credit	2026-04-28 04:58:15.392946
7	10	25.00	debit	2026-04-28 04:58:15.392946
8	11	70.00	credit	2026-04-28 04:58:15.392946
9	12	35.00	debit	2026-04-28 04:58:15.392946
\.


--
-- Data for Name: seats; Type: TABLE DATA; Schema: crowdflow; Owner: postgres
--

COPY crowdflow.seats (seat_id, venue_id, section, seat_number) FROM stdin;
1	1	A	1
2	1	A	2
3	1	A	3
4	1	B	1
5	1	B	2
6	1	B	3
7	2	Orchestra	1
8	2	Orchestra	2
9	2	Orchestra	3
10	2	Balcony	1
11	2	Balcony	2
12	2	Balcony	3
13	3	Lower	1
14	3	Lower	2
15	3	Lower	3
16	3	Upper	1
17	3	Upper	2
18	3	Upper	3
19	4	North	1
20	4	North	2
21	4	North	3
22	4	South	1
23	4	South	2
24	4	South	3
25	5	Main	1
26	5	Main	2
27	5	Main	3
28	5	VIP	1
29	5	VIP	2
30	5	VIP	3
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: crowdflow; Owner: postgres
--

COPY crowdflow.users (user_id, full_name, email, created_at, password) FROM stdin;
1	Alice Johnson	alice.johnson@asu.edu	2026-04-28 04:58:15.361674	hashed_pw_01
2	Bob Martinez	bob.martinez@asu.edu	2026-04-28 04:58:15.361674	hashed_pw_02
3	Clara Chen	clara.chen@gmail.com	2026-04-28 04:58:15.361674	hashed_pw_03
4	David Kim	david.kim@yahoo.com	2026-04-28 04:58:15.361674	hashed_pw_04
5	Emily Torres	emily.torres@asu.edu	2026-04-28 04:58:15.361674	hashed_pw_05
6	Frank Nguyen	frank.nguyen@asu.edu	2026-04-28 04:58:15.361674	hashed_pw_06
7	Grace Patel	grace.patel@gmail.com	2026-04-28 04:58:15.361674	hashed_pw_07
8	Henry Wright	henry.wright@asu.edu	2026-04-28 04:58:15.361674	hashed_pw_08
9	Isabella Garcia	isabella.g@yahoo.com	2026-04-28 04:58:15.361674	hashed_pw_09
10	Jake Thompson	jake.thompson@asu.edu	2026-04-28 04:58:15.361674	hashed_pw_10
11	Kavya Reddy	kavya.reddy@gmail.com	2026-04-28 04:58:15.361674	hashed_pw_11
12	Liam Brown	liam.brown@asu.edu	2026-04-28 04:58:15.361674	hashed_pw_12
13	Mia Robinson	mia.robinson@asu.edu	2026-04-28 04:58:15.361674	hashed_pw_13
14	Noah Davis	noah.davis@gmail.com	2026-04-28 04:58:15.361674	hashed_pw_14
15	Olivia Walker	olivia.walker@asu.edu	2026-04-28 04:58:15.361674	hashed_pw_15
\.


--
-- Data for Name: venues; Type: TABLE DATA; Schema: crowdflow; Owner: postgres
--

COPY crowdflow.venues (venue_id, venue_name, address, capacity) FROM stdin;
1	Desert Financial Arena	600 E Veterans Way, Tempe, AZ	14000
2	Gammage Auditorium	1200 S Forest Ave, Tempe, AZ	3000
3	Mullett Arena	411 E Orange St, Tempe, AZ	5000
4	Sun Devil Stadium	500 E Veterans Way, Tempe, AZ	53000
5	MU Ventana Ballroom	301 E Orange St, Tempe, AZ	500
\.


--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE SET; Schema: crowdflow; Owner: postgres
--

SELECT pg_catalog.setval('crowdflow.attendance_attendance_id_seq', 5, true);


--
-- Name: bookings_booking_id_seq; Type: SEQUENCE SET; Schema: crowdflow; Owner: postgres
--

SELECT pg_catalog.setval('crowdflow.bookings_booking_id_seq', 12, true);


--
-- Name: events_event_id_seq; Type: SEQUENCE SET; Schema: crowdflow; Owner: postgres
--

SELECT pg_catalog.setval('crowdflow.events_event_id_seq', 8, true);


--
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: crowdflow; Owner: postgres
--

SELECT pg_catalog.setval('crowdflow.payments_payment_id_seq', 9, true);


--
-- Name: seats_seat_id_seq; Type: SEQUENCE SET; Schema: crowdflow; Owner: postgres
--

SELECT pg_catalog.setval('crowdflow.seats_seat_id_seq', 30, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: crowdflow; Owner: postgres
--

SELECT pg_catalog.setval('crowdflow.users_user_id_seq', 15, true);


--
-- Name: venues_venue_id_seq; Type: SEQUENCE SET; Schema: crowdflow; Owner: postgres
--

SELECT pg_catalog.setval('crowdflow.venues_venue_id_seq', 5, true);


--
-- Name: attendance attendance_booking_id_key; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.attendance
    ADD CONSTRAINT attendance_booking_id_key UNIQUE (booking_id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (attendance_id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (booking_id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (event_id);


--
-- Name: payments payments_booking_id_key; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.payments
    ADD CONSTRAINT payments_booking_id_key UNIQUE (booking_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: seats seats_pkey; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.seats
    ADD CONSTRAINT seats_pkey PRIMARY KEY (seat_id);


--
-- Name: seats seats_venue_id_section_seat_number_key; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.seats
    ADD CONSTRAINT seats_venue_id_section_seat_number_key UNIQUE (venue_id, section, seat_number);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (venue_id);


--
-- Name: attendance attendance_booking_id_fkey; Type: FK CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.attendance
    ADD CONSTRAINT attendance_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES crowdflow.bookings(booking_id) ON DELETE CASCADE;


--
-- Name: bookings bookings_event_id_fkey; Type: FK CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.bookings
    ADD CONSTRAINT bookings_event_id_fkey FOREIGN KEY (event_id) REFERENCES crowdflow.events(event_id);


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES crowdflow.users(user_id);


--
-- Name: events events_organizer_id_fkey; Type: FK CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.events
    ADD CONSTRAINT events_organizer_id_fkey FOREIGN KEY (organizer_id) REFERENCES crowdflow.users(user_id);


--
-- Name: events events_venue_id_fkey; Type: FK CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.events
    ADD CONSTRAINT events_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES crowdflow.venues(venue_id);


--
-- Name: payments payments_booking_id_fkey; Type: FK CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.payments
    ADD CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES crowdflow.bookings(booking_id) ON DELETE CASCADE;


--
-- Name: seats seats_venue_id_fkey; Type: FK CONSTRAINT; Schema: crowdflow; Owner: postgres
--

ALTER TABLE ONLY crowdflow.seats
    ADD CONSTRAINT seats_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES crowdflow.venues(venue_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict bl5OtGIj1NpwIhxtMajf5HeFubU75X6Vw2ORUfcJQ9an1GYdAqYeBlopw8I0Mkm


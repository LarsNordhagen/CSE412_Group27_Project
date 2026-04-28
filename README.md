# CSE412 Group 27 Project: CrowdFlow

**Course:** CSE 412 Database Management (Spring 2026)  
**Team:** Lars Nordhagen, Megan Tricia Ng, Satya Neriyanuru, Vanshika Parihar

CrowdFlow is a PostgreSQL-backed event booking system built with Flask. The UI
supports full booking lifecycle actions (create, read, update, delete), and
each action maps directly to parameterized SQL in the backend.

## Tech Stack

- PostgreSQL 16 (`crowdflow` schema, relational model from earlier phases)
- Python 3.12
- Flask 3
- `psycopg2-binary` with connection pooling
- Jinja templates + vanilla JavaScript

## Repository Layout

```text
.
├── app/                      # Flask app package
│   ├── __init__.py           # app factory + env loading
│   ├── db.py                 # DB pool + query helpers
│   ├── queries.py            # SQL operations
│   ├── routes.py             # pages + JSON API endpoints
│   ├── templates/            # HTML templates
│   └── static/               # CSS + JS
├── db/
│   ├── 01_schema.sql         # DDL
│   ├── 02_seed.sql           # seed data
│   └── crowdflow_dump.sql    # dump snapshot
├── docs/
│   ├── Group27.pdf
│   └── screenshots/
├── run.py                    # app entrypoint
├── requirements.txt
└── .env.example
```

## Local Setup

### 1) Clone and enter project

```bash
git clone https://github.com/LarsNordhagen/CSE412_Group27_Project.git
cd CSE412_Group27_Project
```

### 2) Create virtual environment and install dependencies

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3) Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` to match your PostgreSQL setup.

### 4) Create and initialize database

```bash
createdb crowdflow
psql -d crowdflow -f db/01_schema.sql
psql -d crowdflow -f db/02_seed.sql
```

## Run the App

```bash
source .venv/bin/activate
python run.py
```

The app runs at [http://127.0.0.1:5000](http://127.0.0.1:5000).

## CRUD Coverage

- **Create:** reserve seats and create a booking
- **Read:** dashboard metrics, events, event details, booking ledger
- **Update:** confirm/cancel bookings, add payment records
- **Delete:** remove bookings (with cascading related records)

## Security Notes

- All SQL uses parameter binding (`%s`) through psycopg2.
- No raw user input is string-concatenated into SQL statements.
- `.env` is ignored by git; use `.env.example` as the template.

## Sample Seed Totals

After loading `db/02_seed.sql`, expected counts are:

- 15 users
- 5 venues
- 30 seats
- 8 events
- 12 bookings
- 9 payments
- 5 attendance rows

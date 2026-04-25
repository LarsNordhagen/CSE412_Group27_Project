import psycopg2
import random
from os import getenv
from dotenv import load_dotenv

load_dotenv()

dbname = getenv("DB_NAME", "")
user = getenv("DB_USERNAME", "")
password = getenv("DB_PASSWORD", "")
host = getenv("DB_HOST", "")
port = getenv("DB_PORT", "")

# Database connection function
def get_db_connection():
    conn = psycopg2.connect(
        dbname=dbname, user=user, password=password, host=host, port=port
    )
    return conn

conn = get_db_connection()
cursor = conn.cursor()

# Populate Data here


cursor.close()
conn.commit()

conn.close()
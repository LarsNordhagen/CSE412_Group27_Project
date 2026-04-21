from flask import Flask, render_template, request
import psycopg2
from os import getenv
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

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

@app.route("/", methods=["GET", "POST"])
def index():
    search_results = []

    if request.method == "POST":
        keyword = request.form["keyword"]

        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
            SELECT * users;
        """
        cursor.execute(query, (keyword,))
        search_results = cursor.fetchall()[:5]

        
        cursor.close()
        conn.close()
    
    return render_template("index.html", search_results=search_results)

if __name__ == "__main__":
    app.run(debug=True)

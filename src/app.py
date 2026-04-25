from flask import Flask, render_template, request, redirect, session
import psycopg2
from os import getenv
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.secret_key = 'SECRET_KEY'


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

def isLoggedIn():
    if (not 'email' in session):
        return False
    return True


@app.route("/register-login", methods=["GET", "POST"])
def registerLoginPage():
    
    if request.method == "POST":
        if (request.args.get('register') == '1'):
            full_name = request.form["full_name"]
            email = request.form['email']
            password = request.form['password']

            conn = get_db_connection()
            cursor = conn.cursor()

            query = """
                SELECT COUNT(*) FROM crowdflow.users
                WHERE email = %s
            """
            cursor.execute(query, (email,))

            existingUserCount = cursor.fetchone()[0]
            if (existingUserCount > 0):
                cursor.close()
                conn.close()
                session['register-error'] = True
                return redirect('/register-login')



            query = """
                INSERT INTO crowdflow.users (full_name, email, password)
                VALUES (%s, %s, %s)
            """
            cursor.execute(query, (full_name, email, password))

            
            cursor.close()
            conn.commit()
            conn.close()

            session['email'] = email

            return redirect('/')
        
        if (request.args.get('login') == '1'):
            email = request.form['email']
            password = request.form['password']

            conn = get_db_connection()
            cursor = conn.cursor()

            query = """
                SELECT COUNT(*) FROM crowdflow.users
                WHERE email = %s and password = %s
            """
            cursor.execute(query, (email, password))

            existingUserCount = cursor.fetchone()[0]
            if (existingUserCount == 0):
                cursor.close()
                conn.close()
                session['login-error'] = True
                return redirect('/register-login')
        
            cursor.close()
            conn.close()

            session['email'] = email
            return redirect('/')

    loginError = session.setdefault('login-error', False)
    registerError = session.setdefault('register-error', False)

    session['login-error'] = False
    session['register-error'] = False

    return render_template("register-login.html", loginError=loginError, registerError=registerError)

@app.route("/", methods=["GET", "POST"])
def index():
    if (not isLoggedIn()):
        return redirect('/register-login')

    return render_template("index.html", email=session['email'])

@app.route("/logout", methods=["GET"])
def logout():
    session.pop('email', default=None)

    return redirect('/register-login')

if __name__ == "__main__":
    app.run(debug=True)

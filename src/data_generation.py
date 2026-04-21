import psycopg2
import random

# Database connection function
def get_db_connection():
    conn = psycopg2.connect(
        dbname="Music", user="postgres", password="pw", host="localhost", port="5432"
    )
    return conn

conn = get_db_connection()
cursor = conn.cursor()

for i in range(10000):
    full_name = "ArtistName" + str(i)
    birth_year = random.randint(1950, 2005)
    genres = ["rock", "country", "pop", "r&b", "jazz"]
    main_genre = random.choice(genres)
    albums_released = random.randint(0, 10)
    total_streams = random.randint(0, 30000)
    countries = ["USA", "UK", "Canada", "Mexico", "Japan"]
    birth_country = random.choice(countries)
    bools = [True, False]
    is_alive = random.choice(bools)
    is_married = random.choice(bools)
    instruments = ["Guitar", "Vocals", "Piano", "Drums", "Bass"]
    main_instrument = random.choice(instruments)

    cursor.execute("""
        INSERT INTO public."Artist" (full_name, birth_year, main_genre, albums_released, total_streams, birth_country, is_alive, is_married, main_instrument)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """,
    (full_name, birth_year, main_genre, albums_released, total_streams, birth_country, is_alive, is_married, main_instrument))


cursor.close()
conn.commit()

conn.close()
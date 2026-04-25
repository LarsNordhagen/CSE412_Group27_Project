# CSE412_Group27_Project

This repository is for Group 27 in the CSE 412 class of the Spring 2026 semester.

Group Members:
- Lars Nordhagen
- Megan Tricia Ng
- Satya Neriyanuru
- Vanshika Parihar

## Instal Dependencies
Make sure you have flask, psycopg2, and dotenv installed on your computer

    pip install flask psycopg2 python-dotenv

## .env File
Run the command in the 'src' folder to create your own .env file from the template

    cp template.env .env

Then, fill in and/or correct the fields as needed.

# Seting up the database
Create a database in pgadmin.

Then, run the crowdflowInit.sql code in the query tool for that database to add the schema and tables.

Next, run data_generation.py to populate the database with the initial data.

    python3 data_generation.py

## Running
Run app.py from the 'src' folder

    python3 app.py

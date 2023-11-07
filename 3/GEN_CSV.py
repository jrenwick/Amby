import pyodbc
import snowflake.connector as sc
from dotenv import load_dotenv
from os import environ as env
from faker import Faker
from uuid import uuid4
import random
from datetime import datetime
import csv

fake = Faker()
load_dotenv()
SF_USER = env["SF_USER"]
SF_PW = env["SF_PW"]
SF_ACC = env["SF_ACC"]
SF_ROLE = env["SF_ROLE"]
SF_WH = env["SF_WH"]


def open_sf_connection():
    conn = sc.connect(user=SF_USER, password=SF_PW, account=SF_ACC, warehouse=SF_WH, role=SF_ROLE)
    return conn


def load_to_sf(filename):
    with open_sf_connection() as conn:
        with conn.cursor() as cursor:
            SQL = f"""PUT file://load/{filename} @JASON.RAW.%NETFLIX"""
            cursor.execute(SQL)


def get_id():
    return str(uuid4())


# load_to_sf("netflix_titles.csv")
def gen_rows(row_count, row_type="new"):
    rows = []
    for i in range(row_count):
        if row_type == "new":
            sid = get_id()
        else:
            sid = f"s{random.randrange(1, 7787)}"
        stype = random.choice(["TV Show", "Movie"])
        stitle = " ".join([x.capitalize() for x in fake.words()])
        director = fake.name()
        num_cast = random.randrange(1, 5)
        cast_list = ", ".join([fake.name() for x in range(num_cast)])
        country = random.choice(["India", "Brazil", "Canada", "Mexico", "Turkey", "Egypt"])
        fake_date = fake.date_time_this_decade()
        date_added = datetime.strftime(fake_date, "%B %d, %Y")
        release_year = int(datetime.strftime(fake_date, "%Y"))
        rating = random.choice(["R", "TV-MA", "PG-13"])
        if stype == "Movie":
            duration = f"{random.randrange(60,150)} min"
            listed_in = ", ".join(random.choices(["Dramas", "Horror Movies", "Thrillers", "Independent Movies", "Sci-Fi & Fantasy"], k=random.randrange(1, 3)))
        else:
            duration = f"{random.randrange(2,10)} Seasons"
            listed_in = ", ".join(random.choices(["Reality TV", "TV Dramas", "TV Mysteries", "Korean TV Shows", "International TV Shows"], k=random.randrange(1, 3)))
        sdescription = fake.text()

        rows.append([sid, stype, stitle, director, cast_list, country, date_added, release_year, rating, duration, listed_in, sdescription])

    return rows


rows = gen_rows(10)
rows.extend(gen_rows(2, row_type="existing"))

CSV_HEADER = ["show_id", "type", "title", "director", "cast", "date_added", "release_year", "rating", "duration", "listed_in", "description"]
file_name = get_id()
csv_file = f"load/{file_name}.csv"

with open(csv_file, "w", newline="") as f:
    wr = csv.writer(f)
    wr.writerow(CSV_HEADER)

    for row in rows:
        wr.writerow(row)

    f.flush()

load_to_sf(f"{file_name}.csv")

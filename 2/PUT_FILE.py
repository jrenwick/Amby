import pyodbc
import snowflake.connector as sc
from dotenv import load_dotenv
from os import environ as env

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


load_to_sf("netflix_titles.csv")

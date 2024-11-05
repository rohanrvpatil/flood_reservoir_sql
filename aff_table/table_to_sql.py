from dotenv import load_dotenv
import os
from io import StringIO
from bs4 import BeautifulSoup
import pandas as pd
from sqlalchemy import create_engine

load_dotenv()

hostname=os.getenv("mysql_hostname")
username=os.getenv("mysql_username")
rootpassword=os.getenv("mysql_rootpassword")
database=os.getenv("mysql_database")

# print(hostname, username, rootpassword, database)

with open("response.html") as file:
    soup = BeautifulSoup(file, "html.parser")

headertop_table = soup.find("table", {"id": "headertop"})
flood1_table = soup.find("table", {"id": "Flood1"})

# Expand headertop headers according to colspan
expanded_headertop_headers = []
for cell in headertop_table.find("tr").find_all("td"):
    colspan = int(cell.get("colspan", 1))
    header_text = cell.get_text()
    expanded_headertop_headers.extend([header_text] * colspan)

# Combine expanded headertop headers with Flood1 headers
combined_header = []
flood1_cells = flood1_table.find("tr").find_all("td")
for i, flood1_cell in enumerate(flood1_cells):
    headertop_text = expanded_headertop_headers[i] if i < len(expanded_headertop_headers) else ""
    flood1_text = flood1_cell.get_text()
    combined_header.append(f"{headertop_text} - {flood1_text}")

# Create dataframe from Flood1 table and set the new combined header
df = pd.read_html(StringIO(str(flood1_table)))[0]
df.columns = combined_header
df = df.iloc[1:]



# print(df.columns.values)
engine = create_engine(f"mysql+pymysql://{username}:{rootpassword}@{hostname}:3306/{database}")
df.to_sql('staging_flood_data', con=engine, if_exists='replace', index=False)

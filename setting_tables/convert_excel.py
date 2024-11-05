import pandas as pd

text_file_path = "D:\Downloads\ghi_v2409\stations_ghi.txt"
excel_file_path = "D:\Downloads\ghi_v2409\stations_ghi_excel.xlsx"

df = pd.read_csv(text_file_path, delimiter="|")

df.to_excel(excel_file_path, index=False)
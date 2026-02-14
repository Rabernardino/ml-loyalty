

# %%
import sqlalchemy
import pandas as pd
import requests
import json

# %%
conn = sqlalchemy.create_engine("sqlite:///../../data/analytical/database.db")


# %%
# Unico request
df = pd.read_sql("SELECT * FROM fs_all LIMIT 1", con=conn)
data = {'data': df.to_dict(orient='records')[0]}


resp = requests.post('http://127.0.0.1:5001/predict', json=data)
resp.json()


# %%
#Multiplos request
df2 = pd.read_sql("SELECT * FROM fs_all LIMIT 10", con=conn)
data2 = {'data': json.loads(df2.to_json(orient='records'))}


# %%
resp = requests.post('http://127.0.0.1:5001/predict_many', json=data2)
resp.json()


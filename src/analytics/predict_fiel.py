

# %%
import pandas as pd
import sqlalchemy
import mlflow

# %%
conn = sqlalchemy.create_engine("sqlite:///../../data/analytical/database.db")
mlflow.set_tracking_uri('http://127.0.0.1:5000')


# %%
# versions = mlflow.search_model_versions(filter_string='name="Fiel"')
# last_version = max([i.version for i in versions])

# %%
last_version = '4'
model = mlflow.sklearn.load_model(f'models:///Fiel/{last_version}')
 

# %%
data = pd.read_sql('SELECT * FROM fs_all', conn)
data.head()


# %%
predict = model.predict_proba(
    data[model.feature_names_in_]
)[:,1]

data['predictFiel'] = predict


# %%
data = data[['dtRef', 'IdCliente', 'predictFiel']]
data.to_sql('score_fiel', conn, index=False, if_exists='replace')
# %%

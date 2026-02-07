

# %%
import pandas as pd
import sqlalchemy
import mlflow

# %%
conn = sqlalchemy.create_engine("sqlite:///../../data/analytical/database.db")

data = pd.read_sql('SELECT * FROM abt_fiel', conn)
data.head()

# %%
mlflow.set_tracking_uri('http://127.0.0.1:5000')


# %%
versions = mlflow.search_model_versions(filter_string='name="Fiel"')
last_version = max([i.version for i in versions])

# %%
last_version

# %%
model = mlflow.sklearn.load_model(f'models:///Fiel/{last_version}')
 

# %%
model.feature_names_in_

# %%
predict = model.predict_proba(
    data[model.feature_names_in_]
)[:,1]

predict
# %%
data['Predict'] = predict

# %%
data.head().sort_values(by='Predict', ascending=False)


# %%

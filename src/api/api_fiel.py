

from flask import Flask, request
import pandas as pd
import mlflow

mlflow.set_tracking_uri('http://127.0.0.1:5000')
last_version = '4'
model = mlflow.sklearn.load_model(f'models:///Fiel/{last_version}')


app = Flask(__name__)

@app.route("/health_check")
def health_check():
    return {'status':'Ok'}


#Predict um cliente
@app.route("/predict", methods=['POST'])
def predict():
    
    try:
        data = request.json['data']
        df = pd.DataFrame([data])
        X = df[model.feature_names_in_]
        predict = model.predict_proba(X)[:,1]

        return {'score':float(predict)}

    except Exception as err:
        return {'err':str(err)}
    

#Predict um multiplos clientes
@app.route("/predict_many", methods=['POST'])
def predict_many():
    
    try:
        data = request.json['data']
        df = pd.DataFrame(data)
        X = df[model.feature_names_in_]
        df['Predict'] = model.predict_proba(X)[:,1]
        resp = df[['IdCliente', 'Predict']].to_dict(orient='records')

        return {'resp':resp}

    except Exception as err:
        return {'err':str(err)}
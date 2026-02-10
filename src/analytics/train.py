

# %%
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt
from sklearn import model_selection
from feature_engine import selection, imputation, encoding, pipeline

from sklearn import tree, metrics, ensemble

import mlflow
import mlflow.sklearn
from mlflow.models.signature import infer_signature

mlflow.sklearn.autolog(disable=True)

mlflow.set_tracking_uri('http://127.0.0.1:5000')
mlflow.set_experiment(experiment_id=635752848251905413)


pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)
pd.set_option('display.float_format', '{:.6f}'.format)

#PADRAO EXIBICAO PANDAS
# pd.reset_option('display.float_format')

# %%
conn = sqlalchemy.create_engine("sqlite:///../../data/analytical/database.db")

# %%
# SAMPLE

df = pd.read_sql("select * from abt_fiel", conn)
df.head()

# %%
df = df[df['idadeDias']>0]

# %%
# Out of Time
df_oot = df[df['dtRef'] == df['dtRef'].max()].reset_index(drop=True)

# %%
target = 'flFiel'
features = df.columns.to_list()[3:]


# %%
df_train_test = df[df['dtRef'] < df['dtRef'].max()].reset_index(drop=True)

# %%
X = df_train_test[features]
y = df_train_test[target]

# %%
X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

print(f'Base Treino:{y_train.shape[0]} - Tx. Target: {100 * y_train.mean():.2f}')
print(f'Base Treino:{y_test.shape[0]} - Tx. Target: {100 * y_test.mean():.2f}')

# %%
# EXPLORE

s_nas = X_train.isna().mean()
s_nas = s_nas[s_nas>0]
s_nas

# %%
# EXPLORE BIVARIADA
cat_features = ['descLifeCycleAtual', 'descLifeCycleD28']
num_features = list(set(features) - set(cat_features))
num_features

# %%
X_train[num_features] = X_train[num_features].astype(float)

# %%
df_train = X_train.copy()
df_train['target'] = y_train.copy()

df_train[num_features] = df_train[num_features].astype(float)

# %%
bivariada_num = df_train.groupby('target')[num_features].median().T
bivariada_num

# %%
bivariada_num['ratio'] = (0.001 + bivariada_num[1]) / (0.001 + bivariada_num[0])
bivariada_num.sort_values('ratio', ascending=False)

# %%
df_train.groupby('descLifeCycleAtual')['target'].mean()

# %%
df_train.groupby('descLifeCycleD28')['target'].mean()


# %%
bivariada_num = df_train.groupby('target')[num_features].median().T
bivariada_num

# %%
bivariada_num['ratio'] = (0.001 + bivariada_num[1]) / (0.001 + bivariada_num[0])
bivariada_num.sort_values('ratio', ascending=False)

# %%
# MODIFY - DROP
to_remove = bivariada_num[bivariada_num['ratio'] == 1].index.tolist()
to_remove

drop_features = selection.DropFeatures(to_remove)


# MOIDFY - MISSING
fill_0 = ['python2025', 'qtedCursosCompletos']
input_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0, variables=fill_0)
input_new = imputation.CategoricalImputer(fill_value='Nao-usuario', variables='descLifeCycleD28')
input_1000 = imputation.ArbitraryNumberImputer(arbitrary_number=1000, variables=['avgIntervaloDiasVida', 'avgIntervaloDiasD28', 'qtdeDiasUltimaInteracao'])


# MODIFY - ONEHOT
onehot = encoding.OneHotEncoder(variables=['descLifeCycleAtual','descLifeCycleD28'])


# MODEL
# model = tree.DecisionTreeClassifier(
#     random_state=42,
#     min_samples_leaf=50
# )

# model = ensemble.RandomForestClassifier(
#     random_state=42,
#     n_estimators=150,
#     n_jobs=1,
#     min_samples_leaf=50
#     )

model = ensemble.AdaBoostClassifier(
    random_state=42
)


params = {
        'n_estimators':[100,200,300,400,500,1000],
        'learning_rate':[0.001, 0.01, 0.05, 0.1, 0.2, 0.5, 0.9, 0.99]
        # 'min_samples_leaf':[10,20,30,50,75,100]

    }


grid = model_selection.GridSearchCV(
    estimator=model,
    param_grid=params,
    cv=3,
    scoring='roc_auc',
    refit=True,
    verbose=3,
    n_jobs=-1
)


model_pipeline = pipeline.Pipeline(steps=[
        ("Remocao de Features", drop_features),
        ("Imputacao de Zeros", input_0),
        ("Imputacao de Nao-Usuario", input_new),
        ("Imputacao de 1000", input_1000),
        ("OneHot Encoding", onehot),
        ("Algoritmo", grid),
    ])


# %%
with mlflow.start_run() as r:

    # mlflow.sklearn.autolog() 

    model_pipeline.fit(X_train, y_train)

    signature = infer_signature(X_train, model_pipeline.predict_proba(X_train))

    # Log do pipeline inteiro
    mlflow.sklearn.log_model(
        sk_model=model_pipeline,
        artifact_path="model_fiel_rev1",
        signature=signature,
        input_example=X_train.head(5),
        registered_model_name='Fiel',
    )

    # ASSESS - Métricas

    y_pred_train = model_pipeline.predict(X_train)
    y_proba_train = model_pipeline.predict_proba(X_train)

    acc_train = metrics.accuracy_score(y_train, y_pred_train)
    auc_train = metrics.roc_auc_score(y_train, y_proba_train[:,1])

    print("Acurácia Treino:", acc_train)
    print("AUC Treino:", auc_train)

    y_pred_test = model_pipeline.predict(X_test)
    y_proba_test = model_pipeline.predict_proba(X_test)

    acc_test = metrics.accuracy_score(y_test, y_pred_test)
    auc_test = metrics.roc_auc_score(y_test, y_proba_test[:,1])

    print("Acurácia Teste:", acc_test)
    print("AUC Teste:", auc_test)

    X_oot = df_oot[features]
    y_oot = df_oot[target]

    y_pred_oot = model_pipeline.predict(X_oot)
    y_proba_oot = model_pipeline.predict_proba(X_oot)

    acc_oot = metrics.accuracy_score(y_oot, y_pred_oot)
    auc_oot = metrics.roc_auc_score(y_oot, y_proba_oot[:,1])

    print("Acurácia OOT:", acc_oot)
    print("AUC OOT:", auc_oot)
    
    mlflow.log_metrics({
        "acc_train":acc_train,
        "auc_train":auc_train,
        "acc_test":acc_test,
        "auc_test":auc_test,
        "acc_oot":acc_oot,
        "auc_oot":auc_oot,
    })


    roc_train = metrics.roc_curve(y_train, y_proba_train[:,1])
    roc_test = metrics.roc_curve(y_test, y_proba_test[:,1])
    roc_oot =  metrics.roc_curve(y_oot, y_proba_oot[:,1])

    plt.plot(roc_train[0], roc_train[1])
    plt.plot(roc_test[0], roc_test[1])
    plt.plot(roc_oot[0], roc_oot[1])
    plt.legend([f"Treino: {auc_train:.4f}",
                f"Teste: {auc_test:.4f}",
                f"OOT: {auc_oot:.4f}"])

    plt.plot([0,1], [0,1], '--', color='black')
    plt.grid(True)
    plt.title("Curva ROC")
    plt.savefig("curva_roc.png")
    
    mlflow.log_artifact('curva_roc.png')


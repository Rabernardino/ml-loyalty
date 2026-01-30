

# %%
import pandas as pd
import sqlalchemy
from sklearn import model_selection

pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)

# %%
conn = sqlalchemy.create_engine("sqlite:///../../data/analytical/database.db")

# %%
# SAMPLE

df = pd.read_sql("abt_fiel", conn)
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
# Apos analise exploratoria, removido as num_features com o ratio
# igual a um, ou seja, sem apresentar diferença entre as classes da target

to_remove = bivariada_num[bivariada_num['ratio'] == 1].index.tolist()
to_remove

# %%
for i in to_remove:
    features.remove(i)
    num_features.remove(i)

# %%
bivariada_num = df_train.groupby('target')[num_features].median().T
bivariada_num

# %%
bivariada_num['ratio'] = (0.001 + bivariada_num[1]) / (0.001 + bivariada_num[0])
bivariada_num.sort_values('ratio', ascending=False)

# %%

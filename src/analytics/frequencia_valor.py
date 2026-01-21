


# %%
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn import cluster
from sklearn import preprocessing

# %%
engine_transacional = sqlalchemy.create_engine('sqlite:///../../data/loyalty-system/database.db')


# %%
def import_query(path):

    with open(path) as file:
        query = file.read()

    return query

# %%
query_transac = import_query('./frequencia_valor.sql')


# %%
df = pd.read_sql(query_transac, engine_transacional)
df.head()

# %%
df = df[df['qtdePontosPos'] < 4000]

# %%
plt.plot(df['qtdeFrequencia'], df['qtdePontosPos'], 'o')
plt.grid(True)
plt.xlabel('Frequencia')
plt.ylabel('Valor')
plt.show()


# %%
#Para realizar o cluster dos dados é necessario primeiro realizar a padronização dos dados
#no exemplo as variaveis estão em escalas muito diferentes, o que para o método de cluster
#impacta negativamente

minmax = preprocessing.MinMaxScaler()

X = minmax.fit_transform(df[['qtdeFrequencia','qtdePontosPos']])


# %%

kmean = cluster.KMeans(
    n_clusters=5,
    random_state=42,
    max_iter=1000
)

kmean.fit(X)

df['cluser'] = kmean.labels_


# %%
df.head()

# %%
sns.scatterplot(
    data=df,
    x='qtdeFrequencia',
    y='qtdePontosPos',
    hue='cluser',
    palette='deep'
)
# %%
X
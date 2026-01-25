


# %%
import pandas as pd
import sqlalchemy
from datetime import datetime, timedelta
from tqdm import tqdm


# %%
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()

    return query

def data_ranges(start, stop, monthly=False):
    
    dates = []
    while start <= stop:
        dates.append(start)
        dt_start = (datetime.strptime(start, '%Y-%m-%d') + timedelta(days=1)).strftime('%Y-%m-%d')
        start = dt_start
        

    if monthly:
        return [i for i in dates if i.endswith('01')]


    return dates

# %%
engine_transacional = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
engine_analytical = sqlalchemy.create_engine("sqlite:///../../data/analytical/database.db")


# %%
query = import_query('./life_cycle.sql')


# %%
datas = data_ranges('2024-09-01','2025-10-01')

# %%
for i in tqdm(datas):

    with engine_analytical.connect() as conn_analytical:
  
        try:
            query_delete = f"DELETE FROM life_cycle WHERE dtRef = date('{i}','-1 day')"
            conn_analytical.execute(sqlalchemy.text(query_delete))
            conn_analytical.commit()

        except Exception as err:
            print(err)

    query_import = query.format(date=i)

    df = pd.read_sql(query_import, engine_transacional)
    df.to_sql('life_cycle', engine_analytical, index=False, if_exists='append')
# %%

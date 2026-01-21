


# %%
import pandas as pd
import sqlalchemy
from datetime import datetime, timedelta

# %%
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()

    return query

def data_ranges(start, stop, monthly=False):
    
    dates = []
    while start <= stop:

        dt_start = (datetime.strptime(start, '%Y-%m-%d') + timedelta(days=1)).strftime('%Y-%m-%d')
        start = dt_start
        dates.append(start)

    if monthly:
        return [i for i in dates if i.endswith('01')]


    return dates

# %%
query = import_query('./life_cycle.sql')


# %%
engine_transacional = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
engine_analytical = sqlalchemy.create_engine("sqlite:///../../data/analytical/database.db")


# %%
datas = [
    '2024-03-01',
    '2024-04-01',
    '2024-05-01',
    '2024-06-01',
    '2024-07-01',
    '2024-08-01',
    '2024-09-01',
    '2024-10-01',
    '2024-11-01',
    '2024-12-01',
    '2025-01-01',
    '2025-02-01',
    '2025-03-01',
    '2025-04-01',
    '2025-05-01',
    '2025-06-01',
    '2025-07-01',
    '2025-08-01',
    '2025-09-01'
]

# %%
for i in datas:

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

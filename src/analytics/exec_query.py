


# %%
import pandas as pd
import sqlalchemy
from datetime import datetime, timedelta
from tqdm import tqdm
import argparse

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


def exec_query(table, db_origin, db_target, dt_start, dt_stop, monthly):

    engine_transacional = sqlalchemy.create_engine(f"sqlite:///../../data/{db_origin}/database.db")
    engine_analytical = sqlalchemy.create_engine(f"sqlite:///../../data/{db_target}/database.db")
    datas = data_ranges(dt_start, dt_stop)
    query = import_query(f'./{table}.sql')

    for i in tqdm(datas):

        with engine_analytical.connect() as conn_analytical:
    
            try:
                query_delete = f"DELETE FROM {table} WHERE dtRef = date('{i}','-1 day')"
                conn_analytical.execute(sqlalchemy.text(query_delete))
                conn_analytical.commit()

            except Exception as err:
                print(err)

        query_import = query.format(date=i)

        df = pd.read_sql(query_import, engine_transacional)
        df.to_sql(table, engine_analytical, index=False, if_exists='append')


# %%
def main():

    parser = argparse.ArgumentParser()

    parser.add_argument('--db_origin', default='loyalty-system', choices=['loyalty-system', 'education-plataform', 'analytical'])
    parser.add_argument('--db_target', default='analytical', choices=['analytical'])
    parser.add_argument('--table', type=str, help='Tabela a ser processada.')
    
    now = datetime.now().strftime('%Y-%m-%d')
    parser.add_argument('--start', type=str, default=now)
    parser.add_argument('--stop', type=str, default=now)
    parser.add_argument('--monthly', action='store_true')


    args = parser.parse_args()

    exec_query(args.table, args.db_origin, args.db_target, args.start, args.stop, args.monthly)


if __name__ == '__main__':
    main()


    

# %%
import os
from dotenv import load_dotenv
import shutil

load_dotenv('../../.env')

from kaggle import api


datasets = [
    'teocalvo/teomewhy-loyalty-system',
    'teocalvo/teomewhy-education-platform',
]

for dataset in datasets:

    
    dataset_name = dataset.split('/teomewhy-')[-1]
    path = f'../../data/{dataset_name}/database.db'

    api.dataset_download_file(f'teocalvo/teomewhy-{dataset_name}', 'database.db')
    shutil.move('database.db', path)

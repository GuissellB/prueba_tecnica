import pandas as pd
from dotenv import load_dotenv
import os
from sqlalchemy import create_engine

load_dotenv()

db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
db_host = os.getenv('DB_HOST', 'localhost')
db_name = os.getenv('DB_NAME')

if not db_user or not db_password or not db_name:
    raise ValueError(
        'Faltan variables de entorno para la conexion a MySQL. '
        'Configura DB_USER, DB_PASSWORD y DB_NAME en el archivo .env.'
    )

# Conectar a MySQL usando variables de entorno
engine = create_engine(f'mysql+pymysql://{db_user}:{db_password}@{db_host}/{db_name}')

# Cargar todos los CSV
stores            = pd.read_csv('Datasets/stores.csv')
vendors           = pd.read_csv('Datasets/vendors.csv')
products          = pd.read_csv('Datasets/products.csv')
transactions      = pd.read_csv('Datasets/transactions.csv')
transaction_items = pd.read_csv('Datasets/transaction_items.csv')
store_promotions  = pd.read_csv('Datasets/store_promotions.csv')

# Insertar en MySQL
stores.to_sql('stores', engine, if_exists='replace', index=False)
vendors.to_sql('vendors', engine, if_exists='replace', index=False)
products.to_sql('products', engine, if_exists='replace', index=False)
transactions.to_sql('transactions', engine, if_exists='replace', index=False)
transaction_items.to_sql('transaction_items', engine, if_exists='replace', index=False, chunksize=10000)
store_promotions.to_sql('store_promotions', engine, if_exists='replace', index=False)

print('¡Datos cargados!')

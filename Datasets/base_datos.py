import pandas as pd
from sqlalchemy import create_engine

# Conectar a MySQL
engine = create_engine('mysql+pymysql://root:123Queso@localhost/retail_prueba')

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
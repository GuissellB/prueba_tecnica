# Prueba Tecnica

Este repositorio contiene la solucion de una prueba tecnica de analisis de datos con Python, Jupyter y MySQL. El flujo principal del proyecto es:

1. Cargar los archivos CSV desde `Datasets/` hacia una base de datos MySQL.
2. Ejecutar el bloque 1 desde `Prueba_tecnica.sql`.
3. Revisar los notebooks y documentos de soporte de los bloques 0 y 2.

## Estructura del proyecto

- `Bloque_0.ipynb`: exploracion y analisis inicial de datos.
- `Prueba_tecnica.sql`: desarrollo del bloque 1 con consultas SQL.
- `bloque2_decisiones.md`: decisiones de modelado y pipeline.
- `bloque2_modelo.pdf`: soporte visual del bloque 2.
- `Datasets/base_datos.py`: script para cargar los CSV en MySQL.
- `Datasets/*.csv`: archivos fuente.

## Requisitos

- Python 3.11 o compatible
- MySQL Server corriendo en local
- PowerShell o terminal compatible

## Instalacion

Si quieres crear un entorno virtual desde cero:

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Si ya existe la carpeta `venv`, puedes activar ese entorno:

```powershell
.\venv\Scripts\Activate.ps1
```

## Configurar la base de datos

El script `Datasets/base_datos.py` se conecta actualmente a esta base:

```python
mysql+pymysql://root:123Queso@localhost/retail_prueba
```

Antes de correr el codigo, crea la base de datos en MySQL:

```sql
CREATE DATABASE retail_prueba;
```

Si tu usuario, password o nombre de base son distintos, edita la cadena de conexion en [Datasets/base_datos.py](/c:/Users/guiss/Documents/Prueba_tecnica/Datasets/base_datos.py:1).

## Cargar los datos en MySQL

Con el entorno virtual activado, ejecuta:

```powershell
python .\Datasets\base_datos.py
```

Si todo sale bien, el script cargara estas tablas en MySQL:

- `stores`
- `vendors`
- `products`
- `transactions`
- `transaction_items`
- `store_promotions`

## Bloque 1: SQL

El bloque 1 de la prueba esta resuelto en [Prueba_tecnica.sql](/c:/Users/guiss/Documents/Prueba_tecnica/Prueba_tecnica.sql:1).

Una vez cargadas las tablas, abre tu cliente de MySQL preferido y ejecuta ese archivo.

Ese archivo incluye consultas para:

- ventas comparables YoY
- productividad por metro cuadrado
- cohortes de clientes
- GMROI por proveedor y categoria
- posibles quiebres de stock
- impacto de promociones

## Abrir los notebooks

Para trabajar con los notebooks:

```powershell
jupyter notebook
```

Luego abre:

- [Bloque_0.ipynb](/c:/Users/guiss/Documents/Prueba_tecnica/Bloque_0.ipynb:1)

## Notas

- Los archivos CSV dentro de `Datasets/` estan ignorados en `.gitignore`.
- El bloque 1 esta en `Prueba_tecnica.sql`.
- El script de carga usa `if_exists='replace'`, por lo que reemplaza las tablas si ya existen.

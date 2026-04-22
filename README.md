# Prueba tecnica

Este repositorio contiene la entrega parcial de una prueba tecnica de analisis de datos con Python, Jupyter y MySQL.

## Archivos disponibles

Actualmente el proyecto contiene estos entregables:

- `Bloque_0.ipynb`: auditoria y exploracion inicial de los datos.
- `Bloque_1.sql`: queries SQL comentadas del bloque 1.
- `bloque2_modelo.pdf`: diagrama del modelo de datos.
- `bloque2_decisiones.md`: decisiones de diseno, ETL y gobernanza.
- `Datasets/base_datos.py`: script para cargar los CSV en MySQL.
- `Datasets/*.csv`: archivos fuente necesarios para la carga en MySQL.
- `.env.example`: ejemplo de variables para la conexion a MySQL.
- `requirements.txt`: dependencias de Python.

## Entregables pendientes

Segun la estructura esperada que compartiste, estos entregables aun no existen en el repositorio:

- `bloque3_analisis.*`
- `bloque3_visualizaciones/`
- `bloque4_kpi_framework.md`
- `bloque5_dashboard.*`
- `bloque5_presentacion_EN.pdf`

## Requisitos

- Python 3.11 recomendado
- MySQL Server en local
- PowerShell o una terminal compatible

## Instalacion

Si quieres crear el entorno virtual desde cero:

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Si ya tienes la carpeta `venv`, solo activala:

```powershell
.\venv\Scripts\Activate.ps1
```

## Configuracion de la base de datos

Antes de ejecutar la carga, crea la base de datos que vayas a usar. Por ejemplo:

```sql
CREATE DATABASE retail_prueba;
```

Luego crea un archivo `.env` en la raiz del proyecto tomando como base `.env.example` y completa tus credenciales de MySQL.

## Como correr el codigo

1. Activa el entorno virtual.
2. Asegurate de que MySQL este corriendo.
3. Crea la base de datos que vayas a usar.
4. Configura el archivo `.env` con tus credenciales y el nombre de esa base.
5. Ejecuta la carga de datos:

```powershell
python .\Datasets\base_datos.py
```

Importante: este comando debe ejecutarse desde la raiz del proyecto, porque `base_datos.py` lee los archivos usando rutas como `Datasets/stores.csv`.

Ese script carga estas tablas:

- `stores`
- `vendors`
- `products`
- `transactions`
- `transaction_items`
- `store_promotions`

## Como revisar los entregables

Para abrir el notebook del bloque 0:

```powershell
jupyter notebook
```

Luego abre `Bloque_0.ipynb`.

El bloque 1 esta en `Bloque_1.sql`, que contiene las consultas SQL comentadas.

Los documentos del bloque 2 disponibles son:

- `bloque2_decisiones.md`
- `bloque2_modelo.pdf`

## Notas

- Los archivos CSV dentro de `Datasets/` estan ignorados en `.gitignore`, por lo que puede que no vengan incluidos al clonar el repositorio.
- Si los CSV no estan presentes, debes agregarlos manualmente dentro de `Datasets/` antes de ejecutar `Datasets/base_datos.py`.
- El archivo `.env` tambien esta ignorado en `.gitignore`, por lo que tus credenciales no se suben al repositorio.
- `Datasets/base_datos.py` debe ejecutarse desde la raiz del proyecto.
- El script de carga usa `if_exists='replace'`, por lo que reemplaza las tablas si ya existen.
- El README describe el estado actual del repositorio, no una entrega completa final.

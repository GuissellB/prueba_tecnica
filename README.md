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

Segun la estructura esperada 

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

## Como revisar los entregables

### Notebook del bloque 0

Para revisar `Bloque_0.ipynb`:

1. Activa el entorno virtual.
2. Asegurate de haber instalado las dependencias con `pip install -r requirements.txt`.
3. Abre Jupyter desde la raiz del proyecto:

```powershell
jupyter notebook
```

Luego abre `Bloque_0.ipynb`.

### Bloque 1

El bloque 1 esta en `Bloque_1.sql`, que contiene las consultas SQL comentadas.

### Bloque 2

Los documentos del bloque 2 disponibles son:

- `bloque2_decisiones.md`
- `bloque2_modelo.pdf`

## Configuracion de la base de datos

Si quieres ejecutar la carga hacia MySQL:

1. Asegurate de que MySQL este corriendo.
2. Crea la base de datos que vayas a usar. Por ejemplo:

```sql
CREATE DATABASE retail_prueba;
```

3. Crea un archivo `.env` en la raiz del proyecto tomando como base `.env.example`.
4. Completa en ese archivo tus credenciales y el nombre de la base de datos.

## Como cargar los datos en MySQL

Con el entorno virtual activado, ejecuta:

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

## Notas

- Los archivos CSV dentro de `Datasets/` estan ignorados en `.gitignore`, por lo que puede que no vengan incluidos al clonar el repositorio.
- Si los CSV no estan presentes, debes agregarlos manualmente dentro de `Datasets/` antes de ejecutar `Datasets/base_datos.py`.
- El archivo `.env` tambien esta ignorado en `.gitignore`, por lo que tus credenciales no se suben al repositorio.
- `Datasets/base_datos.py` debe ejecutarse desde la raiz del proyecto.
- El script de carga usa `if_exists='replace'`, por lo que reemplaza las tablas si ya existen.
- El README describe el estado actual del repositorio, no una entrega completa final.

## Uso de IA

Utilice Claude como asistente durante el desarrollo de la prueba, principalmente para:

- Interpretar conceptos de negocio: aclarar terminos como GMV, GMROI, Comp Sales, YoY, cohortes y percentil 25 que no eran familiares antes de implementarlos en SQL.
- Resolver dudas tecnicas puntuales: diferencias de sintaxis entre MySQL y BigQuery, comportamiento de window functions, manejo de `NULL` y tolerancia de redondeo en comparaciones.
- Validar mi razonamiento: confirmar decisiones de diseno como el modelo cabecera-detalle, el manejo de clientes anonimos y la eleccion de herramientas.

## Lo que hice yo

- Escribi todas las queries SQL.
- Identifique y corregi errores en mi propio codigo.
- Tome todas las decisiones de criterio: umbrales, filtros y definiciones de negocio.
- Valide los resultados contra los datos reales.
- Redacte el analisis y las conclusiones.

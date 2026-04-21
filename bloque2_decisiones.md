# Bloque 2 — Modelado de Datos + Diseño de Pipeline

## Tablas y Campos

### Tablas de Hechos

#### fact_transactions
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `transaction_id` | STRING | PK — ID único de la transacción |
| `customer_id` | STRING | FK → dim_customer (`ANON_000` si no tiene loyalty) |
| `store_id` | STRING | FK → dim_store |
| `date_id` | STRING | FK → dim_date |
| `total_amount` | FLOAT | Monto total de la transacción |
| `payment_method` | STRING | CASH, CARD, DIGITAL |
| `loyalty_card` | BOOLEAN | Si el cliente usó tarjeta de lealtad |
| `status` | STRING | COMPLETED, RETURNED |

#### fact_transaction_items
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `transaction_item_id` | STRING | PK — ID único del ítem |
| `transaction_id` | STRING | FK → fact_transactions |
| `item_id` | STRING | FK → dim_product |
| `quantity` | INT | Unidades compradas |
| `unit_price` | FLOAT | Precio al momento de la venta |
| `was_on_promo` | BOOLEAN | Si el ítem estaba en promoción |

---

### Tablas de Dimensiones

#### dim_store
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `store_id` | STRING | PK — ID único de la tienda |
| `store_name` | STRING | Nombre de la tienda |
| `country` | STRING | CR, GT, HN, SV, NI |
| `city` | STRING | Ciudad |
| `format` | STRING | HIPERMERCADO, SUPERMERCADO, DESCUENTO, EXPRESS |
| `region` | STRING | Capital, Norte, Sur, Oriente, Occidente |
| `size_sqm` | INT | Tamaño en metros cuadrados |
| `opening_date` | DATE | Fecha de apertura |

#### dim_date
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `date_id` | STRING | PK — ID único de la fecha |
| `date` | DATE | Fecha completa |
| `year` | INT | Año |
| `month` | INT | Mes |
| `quarter` | INT | Trimestre |
| `week` | INT | Semana del año |
| `day_of_week` | STRING | Lunes, Martes, etc. |

#### dim_customer
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `customer_id` | STRING | PK — `ANON_000` para clientes anónimos |
| `loyalty_card` | BOOLEAN | FALSE para clientes anónimos |
| `first_purchase_date` | DATE | NULL para clientes anónimos |
| `cohort` | STRING | Mes de primera compra (YYYY-MM). NULL para anónimos |

#### dim_product
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `item_id` | STRING | PK — ID único del producto |
| `vendor_id` | STRING | FK → dim_vendor |
| `item_name` | STRING | Nombre del producto |
| `brand` | STRING | Marca |
| `category` | STRING | Alimentos, Bebidas, Hogar, etc. |
| `department` | STRING | Departamento |
| `cost` | FLOAT | Costo unitario del producto |

#### dim_vendor
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `vendor_id` | STRING | PK — ID único del proveedor |
| `vendor_name` | STRING | Nombre del proveedor |
| `country` | STRING | País de origen |
| `tier` | STRING | A, B, C |
| `is_shared_catalog` | BOOLEAN | Si el producto está disponible en todos los formatos |

#### dim_promotion
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `promotion_id` | STRING | PK — ID único de la promoción |
| `store_id` | STRING | FK → dim_store |
| `promo_name` | STRING | Nombre de la promoción |
| `variant` | STRING | CONTROL, TREATMENT |
| `promo_type` | STRING | PRECIO, EXHIBICION, COMBO |
| `start_date` | DATE | Inicio de la promoción |
| `end_date` | DATE | Fin de la promoción |

---

## Decisiones de Diseño

### Decisión 1 — Modelo cabecera-detalle
Se mantienen `fact_transactions` y `fact_transaction_items` separadas. Unirlas duplicaría campos como `total_amount` y `customer_id` por cada ítem (~3 ítems por transacción en promedio), incrementando innecesariamente el volumen de datos y dificultando el análisis a nivel de transacción.

### Decisión 2 — dim_vendor como extensión de dim_product
`dim_vendor` no se relaciona directamente con la fact table — se accede a través de `dim_product` via `vendor_id`. Esto evita redundancia y sigue el modelo de copo de nieve para la relación producto-proveedor. Para análisis de GMROI se navega: `fact_transaction_items → dim_product → dim_vendor`.

### Decisión 3 — Manejo de clientes anónimos
El 60% de transacciones no tiene `customer_id` (auditado en Bloque 0). Se crea un registro especial `ANON_000` en `dim_customer` para evitar NULLs en la fact table. Los atributos `first_purchase_date` y `cohort` quedan NULL para este registro. Este patrón se conoce como surrogate key para valores desconocidos.

### Decisión 4 — first_purchase_date como atributo pre-calculado
Aunque es un valor derivado, se pre-calcula y almacena en `dim_customer` para evitar recalcularlo en cada análisis de cohortes. Esto mejora el rendimiento de queries que segmentan clientes por cohorte de primera compra.

### Decisión 5 — dim_date como tabla de calendario
El período no se almacena en la fact — se deriva de `transaction_date`. Sin embargo se crea `dim_date` para facilitar filtros por año, mes y quarter sin recalcular en cada consulta, y para soportar análisis de estacionalidad y comparaciones YoY de forma eficiente.

---

## Diseño del Pipeline ETL/ELT

### Retraso de 2 horas en reportes de tiendas
Ante un retraso en la llegada de datos, el primer paso sería identificar el cuello de botella en el proceso ETL — si el problema está en la calidad de los datos, en la eficiencia de las queries o en la capacidad de procesamiento. Si es un problema de calidad de datos se aplicarían las reglas de validación definidas en la auditoría del Bloque 0. Si el pipeline está tardando más de lo esperado se revisaría si se necesita mayor capacidad de cómputo o si las transformaciones pueden optimizarse. Como medida preventiva el pipeline se ejecutaría con una ventana de tolerancia de 2 horas, incluyendo transacciones con `transaction_date` hasta 2 horas antes del momento de carga, más una carga de reconciliación que reprocese el último período para capturar registros tardíos.

### Detección automática de tiendas sin datos
Dependiendo de la criticidad del dato se implementarían dos niveles de alerta. Para monitoreo en tiempo real se usarían herramientas de notificación como bots o alertas automáticas que notifiquen inmediatamente al equipo de operaciones cuando una tienda deje de reportar. Para seguimiento operativo diario se construiría un dashboard de monitoreo del pipeline que muestre el estado de carga por tienda, permitiendo identificar gaps de forma visual sin necesidad de intervención técnica. Este control se alinea con el hallazgo del Bloque 0 donde se detectó que `TIENDA_012` tuvo un gap de 8 días sin transacciones.

### Cargas incrementales sin duplicar transacciones
Se implementarían múltiples mecanismos de deduplicación. Primero, se agregarían campos de bitácora a cada tabla como `fecha_carga` y `fecha_ultima_actualizacion` para rastrear cuándo fue insertado o modificado cada registro. Segundo, se usaría `transaction_id` como clave de deduplicación junto con técnicas de hashing que generen un hash del registro completo — si el hash ya existe en la tabla destino el registro no se inserta. En BigQuery esto se implementaría con `MERGE` usando `transaction_id` como clave de coincidencia.

### Frecuencia del pipeline
El pipeline correría una vez al día en horario de baja actividad, preferiblemente a primera hora de la mañana cuando el tráfico transaccional es menor. Si las fuentes de datos se actualizan durante el día se consideraría aumentar la frecuencia a múltiples cargas diarias, balanceando el costo de procesamiento con la necesidad de frescura del dato para el dashboard.

---

## Gobernanza

### Protección de customer_id
Se ocultaría o encriptaría la información sensible del cliente antes de almacenarla en el data warehouse. Los analistas trabajarían únicamente con identificadores anonimizados y solo roles con permisos especiales tendrían acceso al dato original. En BigQuery esto se implementaría con políticas de acceso a nivel de columna (Column-level security) y enmascaramiento dinámico de datos.

### Data owner de la tabla de transacciones
El área de Finanzas o su equivalente en la organización debería ser el data owner, al ser el área responsable del negocio que genera esos datos. El equipo de datos actuaría como data steward — responsable de la calidad técnica y el mantenimiento del pipeline, pero sin autoridad sobre las definiciones de negocio.

### Proceso para resolver discrepancias de GMV
1. Identificar las fuentes de datos que usa cada reporte y determinar cuáles son las fuentes oficiales
2. Verificar si se está aplicando algún tipo de transformación diferente durante el proceso de carga en cada reporte
3. Validar si alguno incluye transacciones con `status = RETURNED` o montos negativos que el otro excluye
4. Revisar si hay diferencia en el filtro de fechas — `transaction_date` vs fecha de carga
5. Documentar la causa raíz, estandarizar la definición de GMV en un glosario de métricas y actualizar ambos reportes para usar la misma fuente y lógica

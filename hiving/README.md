hiving
==============================

Vamos a predecir el clima para venderles predicciones de Big Data a las compañías eólicas. 

# Prerrequisitos

Los prerrequisistos para utilizar este paquete son: 
- R y RStudio
- Python todavía no, pero pronto... y a través de Anaconda. 
- Postgres
- Google Cloud Platform tal vez, ya que de momento se usa aparte

## R y RStudio

Después de instalarlos, hay que hacer la siguiente configuración. 
1. Instala los siguientes paquetes con la instrucción `> install.packages("paquete")`:
    - `tidyverse`
    - `lubridate`
    - `feather`
    - `lazyeval`
    - `magrittr`
    - `glue`
    - `readxl`
    - `RPostgres`
    - ... otros que vayan surgiendo en los módulos

2. Activa archivos de variables de ambiente:
    - Abre `scriptsR\template.Renv` y sigue esas instrucciones.
    - Todavía no usamos `template.env` para otras variables fuera de R. 

3. Abre el archivo `scriptsR\hiving.Rproj` con RStudio y verifica que funcionen...
    - `> Sys.getenv("PSQL_HOST")`
    - `> conexion <- conectar_postgres("mediciones")` 

4. Seguimos con el análisis. 


# Organización

Los fólders y archivos en este proyecto siguen tienen la organización de `cookicutter` para Python.  
Y algunas modificaciones para integrar el análisis de R. 

------------

    ├── LICENSE
    ├── README.md          <- The top-level README for developers using this project.
    ├── data
    │   ├── external       <- Data from third party sources.
    │   ├── interim        <- Intermediate data that has been transformed.
    │   ├── processed      <- The final, canonical data sets for modeling.
    │   └── raw            <- The original, immutable data dump.
    │
    ├── docs               <- A default Sphinx project; see sphinx-doc.org for details
    │
    ├── models             <- Trained and serialized models, model predictions, or model summaries
    │
    ├── notebooks          <- Jupyter notebooks. Naming convention is a number (for ordering),
    │                         the creator's initials, and a short `-` delimited description, e.g.
    │                         `1.0-jqp-initial-data-exploration`.
    │
    ├── references         <- Data dictionaries, manuals, and all other explanatory materials.
    │
    ├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
    │   └── figures        <- Generated graphics and figures to be used in reporting
    │
    ├── requirements.txt   <- The requirements file for reproducing the analysis environment, e.g.
    │                         generated with `pip freeze > requirements.txt`
    |
    ├── setup.py           <- makes project pip installable (pip install -e .) so src can be imported
    ├── src                <- Source code for use in this project.
    │   ├── __init__.py    <- Makes src a Python module
    │   │
    │   ├── data           <- Scripts to download or generate data
    │   │   └── make_dataset.py
    │   │
    │   ├── features       <- Scripts to turn raw data into features for modeling
    │   │   └── build_features.py
    │   │
    │   ├── models         <- Scripts to train models and then use trained models to make
    │   │   │                 predictions
    │   │   ├── predict_model.py
    │   │   └── train_model.py
    │   │
    │   └── visualization  <- Scripts to create exploratory and results oriented visualizations
    │       └── visualize.py
    │
    └── tox.ini            <- tox file with settings for running tox; see tox.testrun.org


--------

<p><small>Project based on the <a target="_blank" href="https://drivendata.github.io/cookiecutter-data-science/">cookiecutter data science project template</a>. #cookiecutterdatascience</small></p>

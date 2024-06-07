import pandas as pd
import pyodbc
import numpy as np

# Ruta del archivo Excel
excel_file = 'C:/Users/Jhonathan/Desktop/Horarios.xlsx'

# Leer el archivo Excel
df = pd.read_excel(excel_file)

# Reemplazar los valores nan con None
df.replace({np.nan: None}, inplace=True)
# Conexión a SQL Server
conn = pyodbc.connect(
   'DRIVER={ODBC Driver 17 for SQL Server};'
   'SERVER=DESKTOP-4IS01D1\\SQLEXPRESS;'
   'DATABASE=BD2_Clase3;'
   'Trusted_Connection=yes;'
)

cursor = conn.cursor()

#conn.commit()

# Insertar los datos en la tabla temporal
for index, row in df.iterrows():
    print("Valores a insertar:", row['Nombre_de_Curso'], row['Sección'], row['Modalidad'], row['Edificio'], row['Salon'], row['Inicio'], row['Final'], row['Catedrático'], row['Auxiliar'])

    cursor.execute("""
    INSERT INTO Temp_Cursos (Nombre_de_Curso, Seccion, Modalidad, Edificio, Salon, Inicio, Final, Catedratico, Auxiliar)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
    row['Nombre_de_Curso'], row['Sección'], row['Modalidad'], row['Edificio'], row['Salon'], row['Inicio'], row['Final'], row['Catedrático'], row['Auxiliar'])

    
conn.commit()
cursor.close()
conn.close()

print("Datos insertados exitosamente en la tabla temporal.")

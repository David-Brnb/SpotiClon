import pymysql
import os
from dotenv import load_dotenv

# Carga las variables del archivo .env
load_dotenv()

# Obtén la contraseña de la variable de entorno
db_password = os.getenv('MYSQL_PASSWORD')


# Configura la conexión usando la contraseña de la variable de entorno
db = pymysql.connect(
    host='localhost',  # o '127.0.0.1' para conexiones locales
    user='root',  # reemplaza con tu nombre de usuario de MySQL
    password=db_password,  # usa la variable de entorno para la contraseña
    database='demo'  # nombre de tu base de datos local (si ya existe)
)

cursor = db.cursor()

print(cursor)

# Ejecuta una consulta para obtener la versión de MySQL
cursor.execute("SELECT VERSION()")
data = cursor.fetchone()
print(data)

# Asegúrate de seleccionar la base de datos
sql = '''USE demo'''
cursor.execute(sql)

# Crea la tabla 'person' si no existe
sql = '''
CREATE TABLE IF NOT EXISTS person (
    id INT NOT NULL AUTO_INCREMENT,
    fname TEXT,
    lname TEXT,
    PRIMARY KEY (id)
)
'''
cursor.execute(sql)

# Inserta un valor en la tabla 'person'
sql = '''
INSERT INTO person (fname, lname)
VALUES ('John', 'Doe')
'''
cursor.execute(sql)

# Confirma los cambios
cursor.connection.commit()

# Verifica que el valor fue insertado correctamente
cursor.execute("SELECT * FROM person")
data = cursor.fetchall()
print(data)  # Esto mostrará los registros en la tabla 'person'

# Cierra la conexión
cursor.close()
db.close()

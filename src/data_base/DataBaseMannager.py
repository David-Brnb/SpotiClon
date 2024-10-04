import pymysql

db = pymysql.connect(
    host='database-1.cvua82cqyh7n.us-east-2.rds.amazonaws.com',
    user='admin',
    password='PYMroot2024'
)

cursor = db.cursor()

print(cursor)

cursor.execute("select version()")

data = cursor.fetchone()

print(data)

# sql = '''drop database kgptalkie'''
# cursor.execute(sql)

# sql = '''create database kgptalkie'''
# cursor.execute(sql)

cursor.connection.commit()

sql = '''use kgptalkie'''
cursor.execute(sql)


# sql = '''
# create table person (
# id int not null auto_increment,
# fname text,
# lname text,
# primary key (id)
# )
# '''
# cursor.execute(sql)

# sql = '''show tables'''
# cursor.execute(sql)
# cursor.fetchall()

# Selecciona la base de datos
# cursor.execute("USE kgptalkie")


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
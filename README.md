# Flutter Music Miner & Database System

Este proyecto implementa **Minería de Metadatos y Base de Datos** en Flutter utilizando MySQL. El programa es capaz de leer un directorio, extraer metadatos de archivos MP3, y subirlos a una base de datos MySQL. También incluye un motor de búsqueda avanzado que permite filtrar los resultados con un lenguaje personalizado y una interfaz que permite visualizar y editar la información.

## Características
- Minería de metadatos de archivos MP3 utilizando FFMpeg.
- Almacenamiento y gestión de canciones, álbumes, intérpretes y personas en una base de datos MySQL.
- Visualización y edición de la información directamente desde la aplicación Flutter.
- Motor de búsqueda avanzada con soporte para múltiples filtros.
  
## Estructura del Proyecto

### Flutter App (Minería de Datos y Base de Datos)

- `lib/`: Contiene el código fuente de la aplicación Flutter.
  - `mp3_miner.dart`: Clase que maneja la minería de archivos MP3 utilizando FFMpeg para extraer metadatos y subirlos a la base de datos.
  - `my_sql_connection.dart`: Maneja la conexión y consultas a la base de datos MySQL.
  - `song_manager.dart`: Gestiona las operaciones relacionadas con la obtención y actualización de datos en la base de datos.
  - `songs_page.dart`: Página que permite ver, editar y buscar canciones.
  - `albums_page.dart`: Página que permite gestionar álbumes.
  - `performers_page.dart`: Página dedicada a la gestión de intérpretes.
  - `persons_page.dart`: Página para gestionar personas en la base de datos.
  - `groups_page.dart`: Página para gestionar grupos en la base de datos.
- `pubspec.yaml`: Archivo de configuración que lista las dependencias necesarias como `mysql1`, `intl`, y `provider`.

### Motor de Búsqueda

El motor de búsqueda permite filtrar canciones en la base de datos utilizando un lenguaje personalizado. Los usuarios pueden hacer búsquedas combinando letras con operadores lógicos como `AND` o `OR` para aplicar filtros a los campos de la base de datos.

#### Ejemplo de búsqueda:
```bash
-p "Performer Name" AND -t "Song Title"
```

#### Letra y su significado:
- **`-p`**: Busca por el nombre del intérprete (`p.name`).
- **`-t`**: Busca por el título de la canción (`r.title`).
- **`-a`**: Busca por el nombre del álbum (`a.name`).
- **`-y`**: Busca por el año de la canción (`r.year`).
- **`-g`**: Busca por el género de la canción (`r.genre`).
- **`-n`**: Busca por el número de pista (`r.track`).

Cada letra corresponde a un campo en la base de datos y permite búsquedas avanzadas utilizando combinaciones de condiciones.

## Requisitos

### Para la aplicación Flutter:
- Flutter SDK
- MySQL 8.0 o superior
- FFMpeg para la extracción de metadatos de archivos MP3.

## Compilación

### Aplicación Flutter

Primero, asegúrate de tener el entorno de Flutter configurado. Luego, navega al directorio raíz del proyecto y ejecuta:

```bash
flutter pub get
```

Para iniciar la aplicación, usa (agregando una bandera '-d' y adelante su sistema operativo):

```bash
flutter run
```
tambien se puede generar un ejecutable

## Funcionalidades Principales

### Minería de Metadatos

El módulo `mp3_miner.dart` se encarga de extraer información relevante de los archivos MP3 dentro de un directorio especificado, utilizando FFMpeg. Los metadatos obtenidos (como título, artista, álbum, género, año, etc.) se suben a una base de datos MySQL para su gestión.

### Motor de Búsqueda

El motor de búsqueda permite a los usuarios encontrar canciones en la base de datos utilizando el lenguaje de búsqueda descrito arriba. Es compatible con la combinación de filtros, y utiliza operadores lógicos para refinar los resultados.

### Visualización y Edición de Datos

La aplicación incluye varias páginas para gestionar la información almacenada:
- **Songs Page**: Permite ver, buscar y editar canciones.
- **Albums Page**: Gestiona la información relacionada con los álbumes.
- **Performers Page**: Gestiona los intérpretes y permite editar sus datos.
- **Persons Page**: Página dedicada a las personas involucradas en las canciones.

## Notas

- La aplicación Flutter se integra con una base de datos MySQL y permite editar y visualizar información de manera fluida.
- Utiliza FFMpeg para extraer metadatos de archivos MP3 y almacenarlos en la base de datos.
- El motor de búsqueda permite filtrar datos utilizando un lenguaje flexible y fácil de entender, lo que facilita encontrar información específica en grandes bases de datos.

## Créditos

Este proyecto fue desarrollado por **David Leónidas Bernabe Torres** como parte de un ejercicio para integrar minería de datos con un sistema de base de datos utilizando Flutter y MySQL.

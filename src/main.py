from miner import MP3minner

# Crear una instancia del MP3Minner
mp3_minner = MP3minner()

# Pedir al usuario la ruta del directorio que quiere minar
# directory = input("Ingresa la ruta del directorio con archivos MP3: ")

# Minar la música en el directorio proporcionado
songs = mp3_minner.mine("/Users/leonibernabe/Downloads")

# Mostrar los resultados
if songs:
    for song in songs:
        print("Artista: " + song['artist'])
        print("Título: " + song['title'])
        print("Álbum: " + song['album'])
        print("Banda del Álbum: " + song['album_artist'])
        print("Año: " + str(song['year']))
        print("Pista: " + f"{song['track']} de {song['track_total']}")
        print("Disco número: " + f"{song['disc_number']} de {song['disc_total']}")
        print("Género: " + song['genre'])
        print("Comentario: " + song['comment'])
        print("Compositor: " + song['composer'])
        print("Artista original: " + song['original_artist'])
        print("\n" + "-"*40 + "\n")  # Separador entre canciones


        
else:
    print("No se encontraron archivos MP3 en el directorio proporcionado.")



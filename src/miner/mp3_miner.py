import os
import eyed3
import sys
import time
import json

class MP3minner:
    def __init__(self):
        pass

    def mine(self, directory):
        songs = []
        files = [f for f in os.listdir(directory) if f.endswith('.mp3')]
        total_files = len(files)

        print(total_files)

        for index, file_name in enumerate(files):
            file_path = os.path.join(directory, file_name)
            audio_file = eyed3.load(file_path)

            if audio_file and audio_file.tag:
                # Extraer etiquetas ID3 con valores por defecto si faltan
                title = audio_file.tag.title if audio_file.tag.title else "Unknown"
                artist = audio_file.tag.artist if audio_file.tag.artist else "Unknown"
                album = audio_file.tag.album if audio_file.tag.album else os.path.basename(directory)
                album_artist = audio_file.tag.album_artist if audio_file.tag.album_artist else "Unknown"
                year = audio_file.tag.getBestDate().year if audio_file.tag.getBestDate() else "Unknown"
                genre = audio_file.tag.genre.name if audio_file.tag.genre else "Unknown"
                track_number = audio_file.tag.track_num[0] if audio_file.tag.track_num else 0
                track_total = audio_file.tag.track_num[1] if len(audio_file.tag.track_num) > 1 else "Unknown"
                disc_number = audio_file.tag.disc_num[0] if audio_file.tag.disc_num else 0
                disc_total = audio_file.tag.disc_num[1] if len(audio_file.tag.disc_num) > 1 else "Unknown"
                comment = audio_file.tag.comments[0].text if audio_file.tag.comments else "Unknown"
                composer = audio_file.tag.composer if audio_file.tag.composer else "Unknown"
                original_artist = audio_file.tag.original_artist if audio_file.tag.original_artist else "Unknown"

                # Almacenar la información en un diccionario
                song = {
                    "title": title,
                    "artist": artist,
                    "album": album,
                    "album_artist": album_artist,
                    "year": year,
                    "genre": genre,
                    "track": track_number,
                    "track_total": track_total,
                    "disc_number": disc_number,
                    "disc_total": disc_total,
                    "comment": comment,
                    "composer": composer,
                    "original_artist": original_artist,
                    "file_path": file_path
                }
                
                songs.append(song)

            # Progreso de minería
            progress = (index + 1) / total_files
            sys.stdout.write(f"Minando {file_name}: {progress * 100:.2f}% completado\n")
            sys.stdout.flush()
            time.sleep(3)  # Simula tiempo de procesamiento
            
        # Devolver la lista de canciones como JSON
        sys.stdout.write(json.dumps(songs, indent=2) + "\n")
        sys.stdout.flush()
        print("hi")
        sys.stdout.write("completado")
        sys.stdout.flush()

if __name__ == "__main__":
    miner = MP3minner()
    print(sys.argv)
    if len(sys.argv) > 1:
        miner.mine(sys.argv[1])
    else:
        print("No se proporcionó un directorio.")

import os 
import eyed3

class MP3minner:
    def __init__(self):
        pass

    def mine(slef, directory):
        songs = []

        for dirPath, dirName, fileNames in os.walk(directory):
            for file in fileNames:
                if(file.endswith(".mp3")):
                    filePath = os.path.join(dirPath, file)
                    audioFile = eyed3.load(filePath)

                    if(audioFile and audioFile.tag):
                        # Extraer etiquetas ID3 con valores por defecto si faltan
                        title = audioFile.tag.title if audioFile.tag.title else "Unknown"
                        artist = audioFile.tag.artist if audioFile.tag.artist else "Unknown"
                        album = audioFile.tag.album if audioFile.tag.album else os.path.basename(dirPath)
                        album_artist = audioFile.tag.album_artist if audioFile.tag.album_artist else "Unknown"
                        year = audioFile.tag.getBestDate().year if audioFile.tag.getBestDate() else "Unknown"
                        genre = audioFile.tag.genre.name if audioFile.tag.genre else "Unknown"
                        track_number = audioFile.tag.track_num[0] if audioFile.tag.track_num else 0
                        track_total = audioFile.tag.track_num[1] if len(audioFile.tag.track_num) > 1 else "Unknown"
                        disc_number = audioFile.tag.disc_num[0] if audioFile.tag.disc_num else 0
                        disc_total = audioFile.tag.disc_num[1] if len(audioFile.tag.disc_num) > 1 else "Unknown"
                        comment = audioFile.tag.comments[0].text if audioFile.tag.comments else "Unknown"
                        composer = audioFile.tag.composer if audioFile.tag.composer else "Unknown"
                        original_artist = audioFile.tag.original_artist if audioFile.tag.original_artist else "Unknown"

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
                            "file_path": filePath
                        }
                        
                        songs.append(song)
        
        return songs


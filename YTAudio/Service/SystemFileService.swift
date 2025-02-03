//
//  SystemFileService.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import UIKit
import AVFoundation
class SystemFileService {
    /**
        dir -  directory
        dirs -  directories
     
        The `AlbumsList` dir will be created in the Documents dir, the `AlbumsList` contain albums dirs. `AlbumsList ->
                                                                                        `Album1 ->`
                                                                                            `Audio1`
                                                                                            `Audio2`
                                                                                            `Audio3`
                                                                                        `Album2 ->`
                                                                                            `Audio1`
                                                                                            `Audio2`
        Each new created album inside`AlbumsList` will have its own dir, named after the album.
        Each album’s dir will contain `music files` in all audio formats supported by iOS System.
     */

    static func createAlbum(albumName: String) {
        let fileManager = FileManager.default
        guard let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let newAlbumDir = docURL.appendingPathComponent("AlbumsList").appendingPathComponent(albumName)
        ///Create new album dir
        do {
            try fileManager.createDirectory(atPath: newAlbumDir.path, withIntermediateDirectories: true)
            /// Notify the `AlbumsListVC` via `AppManager` after creating a new album dir
            NotificationCenter.default.post(name: .reloadAlbumListContent, object: nil)
        } catch {
            print("\(#file) Failed create album directory \(error.localizedDescription)")
        }
    }

    static func getAlbum(withName albumName: String) -> AlbumModel {
        let fileManager = FileManager.default

        /// Get Album Folder Path
        guard let albumDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("AlbumsList")
            .appendingPathComponent(albumName)
            else {
            return AlbumModel(title: albumName, audios: [])
        }
        var audiosArray: [AudioModel] = []

        /// Check if Album Folder Path exist in file system
        if !fileManager.fileExists(atPath: albumDir.path) {
            do {
                try fileManager.createDirectory(at: albumDir, withIntermediateDirectories: true)
                return AlbumModel(title: albumName, audios: [])

            } catch {
                print("\(#filePath) Failed create Album Directory \(error.localizedDescription)")
            }

        } else {
            /// If I have `Album dir` already created, means that I may have some audios, so i try to read content inside.



            do {
                // Is foder is empty return empty audio array
                if try fileManager.contentsOfDirectory(atPath: albumDir.path).isEmpty {
                    return AlbumModel(title: albumName, audios: [])
                }

                let albumContent = try fileManager.contentsOfDirectory(atPath: albumDir.path)


                for audio in albumContent {
                    let audioURL = albumDir.appendingPathComponent(audio)
                    let audio = self.processPickedAudioURL(at: audioURL)
                    audiosArray.append(audio ?? AudioModel(title: "Unknown", artist: "Unknown", duration: 0.0, url: audioURL, image: nil))
                }

            } catch {
                print("\(#filePath) Failed to get content of album: \(albumName), \(error.localizedDescription)")
            }

        }
        return AlbumModel(title: albumName, audios: audiosArray)

    }

    static func deleteAudio(audioName: String, from albumName: String) {
        let fileManager = FileManager.default

        // Construct the directory path for the album
        guard let albumDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("AlbumsList")
            .appendingPathComponent(albumName) else {
            print("\(#file): Failed to construct album directory URL.")
            return
        }

        // Check if the album directory exists
        guard fileManager.fileExists(atPath: albumDir.path) else {
            print("\(#file): Album directory does not exist at: \(albumDir.path)")
            return
        }

        do {
            // List all files in the directory
            let files = try fileManager.contentsOfDirectory(atPath: albumDir.path)

            // Look for a matching file
            guard let matchingFile = files.first(where: { $0.hasPrefix(audioName) }) else {
                print("\(#file): No matching audio file found for name: \(audioName)")
                return
            }

            // Construct the full path of the matching file
            let audioFileURL = albumDir.appendingPathComponent(matchingFile)

            print("Found matching file: \(audioFileURL.path)")

            // Delete the file
            try fileManager.removeItem(at: audioFileURL)
            print("Audio file deleted successfully.")

        } catch {
            print("Error accessing or deleting audio file: \(error.localizedDescription)")
        }
    }

    static func deleteAlbum(atDir albumName: String) {
        let fileManager = FileManager.default
        if let albumDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("AlbumsList").appendingPathComponent(albumName) {
            do {
                if fileManager.fileExists(atPath: albumDir.path) {
                    try fileManager.removeItem(at: albumDir)
                }
            } catch {
                print("Error deleting album directory \(error.localizedDescription)")
                return
            }
        } else {
            print("\(#file): Failed to locate the album directory.")
        }
    }

    static func getAlbumsList() -> [AlbumModel] {
        let fileManager = FileManager.default
        guard let docURl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        let albumsListDir = docURl.appendingPathComponent("AlbumsList")

        if !fileManager.fileExists(atPath: albumsListDir.path) {
            do {
                /**
                    If `AlbumsList dir` dosen't exist it mean that i have no other album dirs inside so I create the` AlbumsList dir` and return an `empty array`.
                 */
                try fileManager.createDirectory(atPath: albumsListDir.path, withIntermediateDirectories: true)
                return []
            } catch {
                print("\(#filePath) Failed create Albums Directory \(error.localizedDescription)")
            }
        } else {
            /// If I have `AlbumsList dir` already created, means that I may have some album dirs inside so i try to read content inside.
            do {
                let albumsListContent = try fileManager.contentsOfDirectory(atPath: albumsListDir.path)
                var albumsArray: [AlbumModel] = [] /// Initialize an empty array for `album dirs` in the current `AlbumsList` dir

                /// Iterate through `AlbumsList` in order to get `album dirs`
                for album in albumsListContent {
                    /// Check if the album has a prefix to exclude `wrong selections` such as `album` or `.DS_Store`, which is a hidden file generated by the macOS system.
                    if !album.hasPrefix(".") {
                        let currentAlbumDir = albumsListDir.appendingPathComponent(album) /// Get album dir
                        let currentAlbumName = currentAlbumDir.lastPathComponent /// Get album name
                        var audioArray: [AudioModel] = [] /// Init `audioArray` an empty array `to stock` audio files in the `current album dir`

                        do {
                            if try !fileManager.contentsOfDirectory(atPath: currentAlbumDir.path).isEmpty {
                                /// `audio` in for loop is just a string name of file from currentAlbumDir`
                                for audio in try fileManager.contentsOfDirectory(atPath: currentAlbumDir.path) {

                                    let audioURL = currentAlbumDir.appendingPathComponent(audio)
                                    let audio = self.processPickedAudioURL(at: audioURL)
                                    audioArray.append(audio ?? AudioModel(title: "Unknown", artist: "Unknown", duration: 0.0, url: audioURL, image: nil))
                                }

                            }
                        } catch {
                            print("Faield to get contents of \(currentAlbumName), \(error.localizedDescription)")
                        }

                        /// Apend album to albumsArray
                        albumsArray.append(AlbumModel(title: currentAlbumName, audios: audioArray, cover: nil))
                    }
                }
                print("\(#file) AlbumsList content: \(albumsArray)")
                return albumsArray
            } catch {
                print("\(#file) Faield to get AlbumsList content \(error.localizedDescription)")
            }
        }
        /// Return an empty array if nothing is returned for some reason. This might be a bug or an unexpected scenario, as all situations have been handled.
        return []
    }


    static func copyAudioFileToSelectedAlbum(audio: AudioModel, albumName: String) {
        print(audio, albumName)
        let fileManager = FileManager.default

        /// Access the `album dir` intended for moving the audio file.
        let pickedAlbumDir = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("AlbumsList")
            .appendingPathComponent(albumName)

        /// Ensure the album directory exists
        if !fileManager.fileExists(atPath: pickedAlbumDir.path) {
            do {
                try fileManager.createDirectory(at: pickedAlbumDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating album directory: \(error.localizedDescription)")
                return
            }
        }

        let audioDestination = pickedAlbumDir.appendingPathComponent(audio.url.lastPathComponent)

        /// Move audio file to selected album dir
        do {
//            if audio.url.startAccessingSecurityScopedResource() {
//                defer {
//                    audio.url.stopAccessingSecurityScopedResource()
//                }
            try fileManager.copyItem(at: audio.url, to: audioDestination)
            /// If i was on the AlbumList Page the `reloadAlbumListContent` will be trigered other wise if i am on AudioList Page the `reloadAudioListContent` will be trigered 
            NotificationCenter.default.post(name: .reloadAlbumListContent, object: nil)
            NotificationCenter.default.post(name: .reloadAudioListContent, object: nil)
            print("Audio file moved successfully to \(audioDestination.path)")
//            } else {
//                print("Failed to access the file resource securely.")
//            }
        } catch {
            print("Error copying audio file: \(error.localizedDescription)")
        }
    }

    /// Extract all `metaData` from an audio file.
    static func processPickedAudioURL(at url: URL) -> AudioModel? {
        // Ensure the file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Audio file does not exist at URL: \(url.path)")
            return nil
        }

        // Extract the title
        guard let title = url.lastPathComponent.split(separator: ".").first else {
            print("Could not extract title from file name")
            return nil
        }

        // Create an asset for `audio metadata analysis`
        let audioAsset = AVURLAsset(url: url)

        // Extract duration
        let duration: TimeInterval = audioAsset.duration.seconds
        guard duration > 0 else {
            print("Invalid or zero duration in audio file")
            return nil
        }

        // Extract artist name (if available)
        let artist = audioAsset.metadata.first(where: { $0.commonKey?.rawValue == AVMetadataKey.commonKeyArtist.rawValue })?.value as? String ?? "Unknown"

        // Extract the audio image (if available)
        var audioImage: UIImage?
        if let audioImageData = audioAsset.metadata.first(where: { $0.commonKey?.rawValue == AVMetadataKey.commonKeyArtwork.rawValue })?.value as? Data {
            audioImage = UIImage(data: audioImageData)
        }

        // Successfully return the constructed `AudioModel`
        return AudioModel(title: String(title), artist: artist, duration: duration, url: url, image: audioImage)
    }
}


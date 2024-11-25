//
//  AudioImportService.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import Foundation
import AVFoundation
class SystemFileService {
    /**
        dir -  directory
        dirs -  directories
     
        The `PlayList` dir will be created in the Documents dir, the `PlayList` contain albums dirs. `PlayList ->
                                                                                        `Album1 ->`
                                                                                            `Audio1`
                                                                                            `Audio2`
                                                                                            `Audio3`
                                                                                        `Album2 ->`
                                                                                            `Audio1`
                                                                                            `Audio2`
        Each new created album inside`PlayList` will have its own dir, named after the album.
        Each album’s dir will contain `music files` in all audio formats supported by iOS System.
     */

    static func createAlbum(albumName: String) {
        let fileManager = FileManager.default
        guard let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let newAlbumDir = docURL.appendingPathComponent("PlayList").appendingPathComponent(albumName)
        ///Create new album dir
        do {
            try fileManager.createDirectory(atPath: newAlbumDir.path, withIntermediateDirectories: true)
            /// Notify the `PlayListVC` via `PlayListManager` after creating a new album dir
            NotificationCenter.default.post(name: .reloadPlayListContent, object: nil)
        } catch {
            print("\(#file) Failed create album directory \(error.localizedDescription)")
        }
    }

    static func getPlayList() -> [AlbumModel] {
        let fileManager = FileManager.default
        guard let docURl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        let playListDir = docURl.appendingPathComponent("PlayList")

        if !fileManager.fileExists(atPath: playListDir.path) {
            do {
                /**
                    If `PlayList dir` dosen't exist it mean that i have no other album dirs inside so I create the` PlayList dir` and return an `empty array`.
                 */
                try fileManager.createDirectory(atPath: playListDir.path, withIntermediateDirectories: true)
                return []
            } catch {
                print("\(#file) Failed create Albums directory \(error.localizedDescription)")
            }
        } else {
            /// If I have `PlayList dir` already created, means that I may have some album dirs inside so i try to read content inside.
            do {
                let playListContents = try fileManager.contentsOfDirectory(atPath: playListDir.path)
                var albumsArray: [AlbumModel] = [] /// Initialize an empty array for `album dirs` in the current `PlayList` dir

                // Iterate through playlist in order to get album dirs
                for album in playListContents {
                    if !album.hasPrefix(".") {
                        let currentAlbumDir = playListDir.appendingPathComponent(album) /// Get album dir
                        let currentAlbumName = currentAlbumDir.lastPathComponent /// Get album name
                        var audioArray: [AudioModel] = [] /// Initialize an empty array for audio files in the current album dir

                        /// Add all `audio files` in the currentAlbumDir  to the `audioArray`
                        /// `audio` in for loop is just a string name of file from currentAlbumDir`

                        do {
                            if try !fileManager.contentsOfDirectory(atPath: currentAlbumDir.path).isEmpty {
                                for audio in try fileManager.contentsOfDirectory(atPath: currentAlbumDir.path) {
                                    if audio != ".DS_Store" {
                                        let audioURL = currentAlbumDir.appendingPathComponent(audio)
                                        let audio = self.processPickedAudioURL(at: audioURL)
                                        audioArray.append(audio ?? AudioModel(title: "Unknown", artist: "Unknown", duration: 0.0, url: audioURL))
                                    }
                                }
                            }
                        } catch {
                            print("Faield to get contents of \(currentAlbumName), \(error.localizedDescription)")
                        }

                        /// Apend album to albumsArray
                        albumsArray.append(AlbumModel(title: currentAlbumName, songs: audioArray, cover: nil))
                    }
                }
                print("\(#file) PlayList contents: \(albumsArray)")
                return albumsArray
            } catch {
                print("\(#file) Faield to get PlayList contents \(error.localizedDescription)")
            }
        }
        /// Return empty array if somehow didn't return anything before, maybe it's just a bug or something beacuse all situation has been trated
        return []

    }

    static func copyAudioFileToSandbox(audio: AudioModel, albumName: String) {
        print(audio, albumName)
        let fileManager = FileManager.default

        /// Acces album directory where you want to move audio file
        let pickedAlbumDirectory = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("PlayList")
            .appendingPathComponent(albumName)

        /// Ensure the album directory exists
        if !fileManager.fileExists(atPath: pickedAlbumDirectory.path) {
            do {
                try fileManager.createDirectory(at: pickedAlbumDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating album directory: \(error.localizedDescription)")
                return
            }
        }
        
        let audioDestination = pickedAlbumDirectory.appendingPathComponent(audio.url.lastPathComponent)

        /// Move audio file to selected album dir
        /// Acces secured sandbox
        if audio.url.startAccessingSecurityScopedResource() {
            defer { audio.url.stopAccessingSecurityScopedResource() }

            do {
                try fileManager.copyItem(at: audio.url, to: audioDestination)
                NotificationCenter.default.post(name: .reloadPlayListContent, object: nil)
                print("Audio file moved successfully to \(audioDestination.path)")
            } catch {
                print("Error copying audio file: \(error.localizedDescription)")
            }
            
        }
    }

    static func processPickedAudioURL(at url: URL) -> AudioModel? {
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            /// Extracts the `title` from the selected audio file. If the file has no title, it is considered invalid, and the method returns `nil`.
            guard let title = url.lastPathComponent.split(separator: ".").first else {
                print("Could not extract title from file name")
                return nil
            }

            ///Create an asset for `audio metadata analysis`
            let audioAsset = AVURLAsset(url: url)

            /// Extract duraion

            let duration: TimeInterval = audioAsset.duration.seconds
            let artist: String = audioAsset.metadata.first(where: { $0.commonKey?.rawValue == "artist" })?.value as? String ?? "Unknown"

            /// Extracts the `duration` from the selected audio file. If the file has invalid duration,  the method returns `nil`.
            guard duration.isFinite && duration > 0 else {
                print("Error in extracting duration")
                return nil
            }

            /// If all cases have been passed successfully, it means a valid `AudioModel` has been created, which can now be returned.
            return AudioModel(title: String(title), artist: artist, duration: duration, url: url)
        } else {
            print("Failed to access security-scoped resource")
            return nil
        }
    }
}

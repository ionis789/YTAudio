//
//  AlbumsListManager.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import Foundation

class AppManager {

    static func getAlbumsList() -> [AlbumModel] {
        print("\(#file) Getting albums list...")
        return SystemFileService.getAlbumsList()
    }

    static func reloadAlbumsList() {
        print("Reloading albums list...")
        print(#file, #line, SystemFileService.getAlbumsList())
    }
    static func reloadAudiosList() {
        print("Realoading audio list...")
        
    }
}

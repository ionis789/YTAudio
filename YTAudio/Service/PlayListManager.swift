//
//  PlayListManager.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import Foundation

class PlayListManager {

    static func getPlayList() -> [AlbumModel] {
        print("\(#file) Getting play list...")
        return SystemFileService.getPlayList()
    }

    static func reloadPlayList() {
        print("Reloading play list...")
        print(#file, #line, SystemFileService.getPlayList())
    }
}

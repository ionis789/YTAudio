//
//  NotificationService.swift
//  YTAudio
//
//  Created by Ion Socol on 11/13/24.
//

import Foundation

extension Notification.Name {
    static let reloadAlbumListContent = Notification.Name("reloadAlbumListContent")
    static let reloadAudioListContent = Notification.Name("reloadAudioListContent")
    static let didRemoveAudioFromAlbum = Notification.Name("didRemoveAudioFromAlbum")
}

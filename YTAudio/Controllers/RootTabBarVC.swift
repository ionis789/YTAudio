//
//  RootTabBarVC.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import UIKit

class RootTabBarVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the color of the tab bar items (both selected and unselected)
        UITabBar.appearance().tintColor = .myRed // For selected items
        UITabBar.appearance().unselectedItemTintColor = .gray // For unselected items


        let albumVC = AlbumsVC()
        let ImportAudioVC = ImportAudioVC()
        let settingsVC = SettingsVC()

        albumVC.tabBarItem = UITabBarItem(title: "Albums", image: UIImage(systemName: "music.note.list"), tag: 0)
        ImportAudioVC.tabBarItem = UITabBarItem(title: "Import", image: UIImage(systemName: "plus"), tag: 1)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 2)

        self.viewControllers = [albumVC, ImportAudioVC, settingsVC]
    }
}

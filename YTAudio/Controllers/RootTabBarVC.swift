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

        // Set the color of the tab bar items (selected and unselected)
        UITabBar.appearance().tintColor = .myRed // Color for selected tab items
        UITabBar.appearance().unselectedItemTintColor = .gray // Color for unselected tab items

        // Wrap AlbumsListVC inside a UINavigationController to enable a navigation bar
        let albumVC = AlbumsListVC(albums: AppManager.getAlbumsList())
        let albumNavController = UINavigationController(rootViewController: albumVC)
        albumNavController.tabBarItem = UITabBarItem(title: "Albums", image: UIImage(systemName: "rectangle.stack"), tag: 0)

        // Wrap ImportAudioVC inside a UINavigationController if a navigation bar is needed
        let importAudioVC = ImportAudioVC()
        let importNavController = UINavigationController(rootViewController: importAudioVC)
        importNavController.tabBarItem = UITabBarItem(title: "Import", image: UIImage(systemName: "plus"), tag: 1)

        // Wrap SettingsVC inside a UINavigationController for consistent navigation behavior
        let settingsVC = SettingsVC()
        let settingsNavController = UINavigationController(rootViewController: settingsVC)
        settingsNavController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 2)

        // Assign view controllers to the tab bar
        self.viewControllers = [albumNavController, importNavController, settingsNavController]
    }
}

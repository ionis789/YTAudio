//
//  ViewController.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import UIKit

class AlbumsVC: UIViewController {
    
    
    
    private lazy var tableView: UITableView = {
        let vc = UITableView()
        vc.translatesAutoresizingMaskIntoConstraints = false
        vc.dataSource = self
        vc.delegate = self
        vc.estimatedRowHeight = 100
        vc.rowHeight = UITableView.automaticDimension
        vc.tableFooterView = UIView()
        vc.register(AlbumCell.self, forCellReuseIdentifier: "albumCell")
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        // Do any additional setup after loading the view.
    }

}

extension AlbumsVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as? AlbumCell else {
            return AlbumCell()
        }


        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}

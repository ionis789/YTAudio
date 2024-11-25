//
//  AlbumList.swift
//  YTAudio
//
//  Created by Ion Socol on 11/24/24.
//

import UIKit

class AlbumVC: UIViewController {
    
    var albumAudio: [AudioModel] {
        didSet {
            print("\(#file) didSet")
        }
    }
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        v.dataSource = self
        v.register(AudioCell.self, forCellReuseIdentifier: "audioCell")
        v.estimatedRowHeight = 90
        v.rowHeight = UITableView.automaticDimension
        v.tableFooterView = UIView()
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        }
    
    init(album: AlbumModel) {
        self.albumAudio = album.songs
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        view.addSubview(tableView)
        setupContraints()
    }
    private func setupContraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
extension AlbumVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(albumAudio[indexPath.row].title)
        
        let popupVC = AudioPlayer(pickedAudio: albumAudio[indexPath.row].url)
        
        present(popupVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioCell else { return UITableViewCell() }
        cell.pickedAudio = albumAudio[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albumAudio.count
    }
}

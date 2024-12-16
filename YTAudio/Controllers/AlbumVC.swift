//
//  AlbumVC.swift
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

    private lazy var albumTableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        v.dataSource = self
        v.register(AudioCell.self, forCellReuseIdentifier: "audioCell")
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 120
        v.tableFooterView = UIView()
        return v
    }()
    private lazy var emptyAlbumLabel: UILabel = {
        let v = UILabel()
        v.text = "Nothing here..."
        v.textAlignment = .center
        v.font = .systemFont(ofSize: 32, weight: .bold)
        v.numberOfLines = 0
        return v
    }()
    private lazy var editAudiosButton: UIBarButtonItem = {
        let v = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editAudiosButtonTapped))
        v.tintColor = .myRed
        return v
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(requestToReloadAudiosList), name: .reloadAudiosListContent, object: nil)
    }

    init(album: AlbumModel) {
        self.albumAudio = album.songs
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        view.addSubview(albumTableView)
        navigationItem.rightBarButtonItem = editAudiosButton
        setupContraints()
    }
    private func setupContraints() {
        NSLayoutConstraint.activate([
            albumTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            albumTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            albumTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            albumTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func requestToReloadAudiosList() {
       
    }
    
    @objc private func editAudiosButtonTapped() {
        
    }
}
extension AlbumVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(albumAudio[indexPath.row].title)
        let popupVC = MediaPlayerVC(album: albumAudio, pickedAudioIndex: indexPath.row)
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

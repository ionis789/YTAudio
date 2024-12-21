//
//  AlbumVC.swift
//  YTAudio
//
//  Created by Ion Socol on 11/24/24.
//

import UIKit

class AlbumVC: UIViewController {

    var audiosAlbum: [AudioModel] {
        didSet {
            print("\(#file) audiosAlbum didSet")
        }
    }

    var albumTitle: String

    private lazy var audiosAlbumTableView: UITableView = {
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
    }

    init(album: AlbumModel) {
        self.audiosAlbum = album.audios
        self.albumTitle = album.title
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        view.addSubview(audiosAlbumTableView)
        navigationItem.rightBarButtonItem = editAudiosButton
        setupContraints()
    }
    private func setupContraints() {
        NSLayoutConstraint.activate([
            audiosAlbumTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            audiosAlbumTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            audiosAlbumTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            audiosAlbumTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }



    @objc private func editAudiosButtonTapped() {
        audiosAlbumTableView.setEditing(!audiosAlbumTableView.isEditing, animated: true)
        editAudiosButton.title = audiosAlbumTableView.isEditing ? "Done" : "Edit"
    }
}
extension AlbumVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.row
            SystemFileService.deleteAudio(audioName: audiosAlbum[index].title, from: albumTitle)
            audiosAlbum.remove(at: index)
            audiosAlbumTableView.deleteRows(at: [indexPath], with: .fade)
            NotificationCenter.default.post(name: .removeAudioFromAlbum, object: nil, userInfo: ["albumName": albumTitle, "audioIndex": index])

        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(audiosAlbum[indexPath.row].title)
        let popupVC = MediaPlayerVC(album: audiosAlbum, pickedAudioIndex: indexPath.row)
        present(popupVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioCell else { return UITableViewCell() }
        cell.pickedAudio = audiosAlbum[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        audiosAlbum.count
    }
}

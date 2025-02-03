//
//  AlbumVC.swift
//  YTAudio
//
//  Created by Ion Socol on 11/24/24.
//

import UIKit

class AlbumVC: UIViewController {

    var audios: [AudioModel] {
        didSet {
            print("\(#file) audios from album: \(self.albumTitle) didSet")
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
        NotificationCenter.default.addObserver(self, selector: #selector(requestToReloadAudioList), name: .reloadAudioListContent, object: nil)
    }

    init(album: AlbumModel) {
        self.audios = album.audios
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
    @objc private func requestToReloadAudioList() {
        self.audios = SystemFileService.getAlbum(withName: albumTitle).audios
        audiosAlbumTableView.reloadData()
    }
}
extension AlbumVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.row
            SystemFileService.deleteAudio(audioName: audios[index].title, from: albumTitle)
            audios.remove(at: index)
            audiosAlbumTableView.deleteRows(at: [indexPath], with: .fade)
            NotificationCenter.default.post(name: .didRemoveAudioFromAlbum, object: nil, userInfo: ["albumName": albumTitle, "audioIndex": index])

        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(audios[indexPath.row].title)
        let popupVC = MediaPlayerVC(album: audios, pickedAudioIndex: indexPath.row)
        present(popupVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioCell else { return UITableViewCell() }
        cell.pickedAudio = audios[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        audios.count
    }
}

//
//  AlbumsListVC.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import UIKit

class AlbumsListVC: UIViewController {

    //MARK: Albums Array
    var albumsList: [AlbumModel] {
        didSet {
            print("\(#file) didSet")
        }
    }

    private lazy var albumsListTableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.dataSource = self
        v.delegate = self
        v.register(AlbumCell.self, forCellReuseIdentifier: "albumCell")
        v.rowHeight = UITableView.automaticDimension
        v.rowHeight = 90
        v.tableFooterView = UIView()
        return v
    }()

    private lazy var emptyAlbumsListLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "Create your first album"
        v.textColor = .white
        v.textAlignment = .center
        v.font = .systemFont(ofSize: 16, weight: .bold)
        v.isHidden = true
        return v
    }()

    private lazy var createAlbumButton: UIBarButtonItem = {
        let v = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(didCreateAlbumTapped))
        v.tintColor = .myRed
        return v
    }()

    private lazy var editAlbumsButton: UIBarButtonItem = {
        let v = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editAlbumsButtonTapped))
        v.tintColor = .myRed
        return v

    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
//        checkAlbumsList()
        ///Add Notification observer in case of creating new album
        /**
         On viewDidLoad life cycle set listener for `reloadAlbumsListContent`
         When I create new album `didCreateAlbumTapped` it's called and then i notifiy the NotificationCenter about `reloadAlbumsListContent event` so then inside a `requestToReloadAlbumsList` function I set `updated` albumsList to my `albumsList` array
         */
        NotificationCenter.default.addObserver(self, selector: #selector(requestToReloadAlbumList), name: .reloadAlbumListContent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAudio), name: .didRemoveAudioFromAlbum, object: nil)
    }
    // Hide home indicator
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    //MARK: Init AlbumsListVC with params
    init(albums: [AlbumModel]) {
        self.albumsList = albums
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        /// Configure subviews ierarhi
        [albumsListTableView, emptyAlbumsListLabel].forEach { view.addSubview($0) }
        navigationItem.rightBarButtonItem = editAlbumsButton // assign edit button to tableview
        navigationItem.leftBarButtonItem = createAlbumButton // assign create button to tableview

        /// Add the createAlbumButtonView, editAlbumListLabel to the header
        ///         [editAlbumsButton, createAlbumButton].forEach { headerTableView.addSubview($0) }

        setupConstraints()
    }
    @objc private func editAlbumsButtonTapped() {
        albumsListTableView.setEditing(!albumsListTableView.isEditing, animated: true)
        editAlbumsButton.title = albumsListTableView.isEditing ? "Done" : "Edit" // Actualizează titlul
    }
    private func checkAlbumsList() {
        if albumsList.isEmpty {
            emptyAlbumsListLabel.isHidden = false
            albumsListTableView.isHidden = true
        } else {
            emptyAlbumsListLabel.isHidden = true
            albumsListTableView.isHidden = false
        }
    }
    private func setupConstraints() {
        /**
         Constraints for the tableView.
         The top of tableView starts from safeAreaLayoutGuide and go to screen bottom, to avoid UI problems.
         */
        if albumsList.isEmpty {
            emptyAlbumsListLabel.isHidden = false
            albumsListTableView.isHidden = true

        } else {
            emptyAlbumsListLabel.isHidden = true
            albumsListTableView.isHidden = false
        }
        NSLayoutConstraint.activate([
            albumsListTableView.topAnchor.constraint(equalTo: view.topAnchor),
            albumsListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            albumsListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            albumsListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        NSLayoutConstraint.activate([
            emptyAlbumsListLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyAlbumsListLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }

    //MARK: createAlbum Alert
    @objc private func didCreateAlbumTapped() {
        isEditing = false
        let alert = UIAlertController(title: "Create", message: "Insert album name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Album Name"
            textField.textColor = .label
        }

        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let textField = alert.textFields?.first else { return }
            if let inputText = textField.text, !inputText.isEmpty {
                /// If input isn't empty i create new album with this input
                SystemFileService.createAlbum(albumName: inputText)
                self.checkAlbumsList()
            } else {
                /// In case of empty inputText show on screen another alert with warnning message
                self.sayEmptyTextField()
            }
        }

        alert.addAction(createAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    /// Reload `albumsList` when new album has created
    @objc private func requestToReloadAlbumList() {
        self.albumsList = SystemFileService.getAlbumsList()
        albumsListTableView.reloadData()
    }
    @objc private func removeAudio(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let audioIndex = userInfo["audioIndex"] as? Int, let albumName = userInfo["albumName"] as? String {
                print("Trying remove audio with index: \(audioIndex) from album: \(albumName)")
                if let albumIndex = albumsList.firstIndex(where: { $0.title == albumName }) {
                    albumsList[albumIndex].audios.remove(at: audioIndex)
                    print("Successfully removed audio from album \(albumName)")
                } else {
                    print("Could not remove audio beacuse album with name \(albumName) not found")
                }
            }
        }
    }
    /// Text Field `validation`
    private func sayEmptyTextField() {
        let alert = UIAlertController(title: "Warning", message: "Empty text field, try again and insert album name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    private func sayDublicatedAlbum() {
        let alert = UIAlertController(title: "Warning", message: "Album with this name already exists, please try new one or modify existing album name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


extension AlbumsListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            // Delete album from system file
            if indexPath.row >= 0 {
                SystemFileService.deleteAlbum(atDir: albumsList[indexPath.row].title)
            }

            // Delete album from UI
            print("Deleted: ", albumsList[indexPath.row].title)
            albumsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            checkAlbumsList()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(albumsList[indexPath.row].title) Selected")
        /**
         Primitive Deselect function
         guard let cell = tableView.cellForRow(at: indexPath) as? AlbumCell else { return }
         cell.isSelected.toggle()
         */

        /// Swift provide `deselectRow - method for UITableView` witch deselects a row that an index path identifies, with an option to animate the deselection.

        let vc = AlbumVC(album: albumsList[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// `Custom cell` for tableView
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as? AlbumCell else { return UITableViewCell() }
        /// Each `cell` corespond to an album from `albumsListArray` (albumsList: [AlbumModel])
        cell.album = albumsList[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsList.count
    }
}

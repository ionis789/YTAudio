//
//  PlayListVC.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import UIKit

class PlayListVC: UIViewController {

    //MARK: Albums Array
    var playList: [AlbumModel] {
        didSet {
            print("\(#file) didSet")
        }
    }

    private lazy var playlistTableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.dataSource = self
        v.delegate = self
        v.register(AlbumCell.self, forCellReuseIdentifier: "albumCell")
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 90
        v.tableFooterView = UIView()
        return v
    }()
    private lazy var headerTableView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        /**
         In case need to check where is the position of  headerTableView
         v.backgroundColor = .blue // Add a background color to make it visible
         */
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
        ///Add Notification observer in case of creating new album
        /**
         On viewDidLoad life cycle set listener for `reloadPlayListContent`
         When I create new album `didCreateAlbumTapped` it's called and then i notifiy the NotificationCenter about `reloadPlayListContent event` so then inside a `requestToReloadPlayList` function I set `updated` PlayList to my `playList` array
         */
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestToReloadPlayList), name: .reloadPlayListContent, object: nil)
    }

    //MARK: Init PlayListVC with params
    init(albums: [AlbumModel]) {
        self.playList = albums
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        /// Configure subviews ierarhi
        [playlistTableView].forEach { view.addSubview($0) }
        navigationItem.rightBarButtonItem = editAlbumsButton // assign edit button to tableview
        navigationItem.leftBarButtonItem = createAlbumButton // assign create button to tableview

        /// Add the createAlbumButtonView, editAlbumListLabel to the header
//        [editAlbumsButton, createAlbumButton].forEach { headerTableView.addSubview($0) }

        setupConstraints()
    }
    @objc private func editAlbumsButtonTapped() {
        playlistTableView.setEditing(!playlistTableView.isEditing, animated: true)
        editAlbumsButton.title = playlistTableView.isEditing ? "Done" : "Edit" // Actualizează titlul
    }
    private func setupConstraints() {
        /**
         Constraints for the tableView.
         The top of tableView starts from safeAreaLayoutGuide and go to screen bottom, to avoid UI problems.
         */

        NSLayoutConstraint.activate([
            playlistTableView.topAnchor.constraint(equalTo: view.topAnchor),
            playlistTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playlistTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playlistTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
            } else {
                /// In case of empty inputText show on screen another alert with warnning message
                self.sayEmptyTextField()
            }
        }

        alert.addAction(createAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    /// Reload `playList` when new album has created
    @objc private func requestToReloadPlayList() {
        self.playList = SystemFileService.getPlayList()
        playlistTableView.reloadData()
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


extension PlayListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            // Delete album from system file
            if indexPath.row >= 0 {
                SystemFileService.deleteAlbum(atDir: playList[indexPath.row].title)
            }

            // Delete album from UI
            print(playList[indexPath.row].title)
            playList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(playList[indexPath.row].title) Selected")
        /**
         Primitive Deselect function
         guard let cell = tableView.cellForRow(at: indexPath) as? AlbumCell else { return }
         cell.isSelected.toggle()
         */

        /// Swift provide `deselectRow - method for UITableView` witch deselects a row that an index path identifies, with an option to animate the deselection.

        let vc = AlbumVC(album: playList[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// `Custom cell` for tableView
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as? AlbumCell else { return UITableViewCell() }
        /// Each `cell` corespond to an album from `playListArray` (playList: [AlbumModel])
        cell.album = playList[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playList.count
    }
}

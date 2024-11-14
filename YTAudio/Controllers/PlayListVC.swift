//
//  ViewController.swift
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
        willSet {
            print("\(#file) willSet")
        }
    }

    private lazy var tableView: UITableView = {
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
    private lazy var createAlbumButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .myRed
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        v.setImage(UIImage(systemName: "rectangle.stack.badge.plus", withConfiguration: config), for: .normal)
        v.addTarget(self, action: #selector(didCreateAlbumTapped), for: .touchUpInside)
        return v
    }()

    private lazy var editAlbumsButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("Edit", for: .normal)
        v.setTitleColor(.myRed, for: .normal)
        v.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
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
        [headerTableView, tableView].forEach { view.addSubview($0) }

        /// Add the createAlbumButtonView, editAlbumListLabel to the header
        [editAlbumsButton, createAlbumButton].forEach { headerTableView.addSubview($0) }

        setupConstraints()
    }
    private func setupConstraints() {
        /**
         Constraints for the tableView.
         The top of tableView starts from safeAreaLayoutGuide and go to screen bottom, to avoid UI problems.
         */

        /// Constraints for the headerTableView (custom header view)
        NSLayoutConstraint.activate([
            headerTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerTableView.heightAnchor.constraint(equalToConstant: 60)
        ])


        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerTableView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])


        /// Constraints for the editAlbumsButton (position it in the top-left corner)
        NSLayoutConstraint.activate([
            editAlbumsButton.centerYAnchor.constraint(equalTo: headerTableView.centerYAnchor),
            editAlbumsButton.leadingAnchor.constraint(equalTo: headerTableView.leadingAnchor, constant: 16),
        ])

        /// Constraints for the createAlbumButton (position it in the top-right corner)
        NSLayoutConstraint.activate([
            createAlbumButton.centerYAnchor.constraint(equalTo: headerTableView.centerYAnchor),
            createAlbumButton.trailingAnchor.constraint(equalTo: headerTableView.trailingAnchor, constant: -16),
        ])
    }

    //MARK: createAlbum Alert
    @objc private func didCreateAlbumTapped() {

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

    /// Reload playList when new album has created
    @objc private func requestToReloadPlayList() {
        self.playList = SystemFileService.getPlayList()
        tableView.reloadData()
    }

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(playList[indexPath.row].title) Selected")
        /**
         Primitive Deselect function
         guard let cell = tableView.cellForRow(at: indexPath) as? AlbumCell else { return }
         cell.isSelected.toggle()
         */

        /// Swift provide `deselectRow - method for UITableView` witch deselects a row that an index path identifies, with an option to animate the deselection.
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

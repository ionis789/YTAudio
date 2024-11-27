//
//  AudioDestinationPopup.swift
//  YTAudio
//
//  Created by Ion Socol on 11/16/24.
//

import UIKit

class AudioDestinationPopup: UIViewController {
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        v.dataSource = self
        v.tableFooterView = UIView()
        return v
    }()

    private lazy var albumNamesList: [String] = {
        return SystemFileService.getPlayList().map { $0.title }
    }()
    
    
    var pickedAudio: AudioModel {
        didSet {
            print(pickedAudio.title + " was picked")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    //MARK: Init
    init(audio: AudioModel) {
        self.pickedAudio = audio
        super.init(nibName: nil, bundle: nil)
    }
    
    required init (coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        view.backgroundColor = .black
        view.addSubview(tableView)
        setupConstraints()
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension AudioDestinationPopup: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albumNamesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = albumNamesList[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cell.backgroundColor = .clear
        cell.backgroundView?.backgroundColor = .clear   
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAlbum = albumNamesList[indexPath.row]
        SystemFileService.copyAudioFileToSelectedAlbum(audio: pickedAudio, albumName: selectedAlbum)
        dismiss(animated: true)
        print("Selected album for destination: \(selectedAlbum)")
    }
}

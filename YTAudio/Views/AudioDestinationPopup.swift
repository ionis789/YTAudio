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
        return SystemFileService.getAlbumsList().map { $0.title }
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
        //NotificationCenter.default.addObserver(self, selector: #selector(), name: .reloadAudioListContent, object: nil)
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

    func getTopViewController() -> UIViewController? {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow }) else { return nil }

        var topVC = window.rootViewController
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
}
extension UIViewController {
    func showSuccessAlert(for album: String, with audio: String) {
        let alert = UIAlertController(
            title: "Success",
            message: "\(audio) was successfully moved to \(album).",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
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
        // Dismiss view controller
        dismiss(animated: true) {
            if let topVC = self.getTopViewController() {
                topVC.showSuccessAlert(for: selectedAlbum, with: self.pickedAudio.title)
            }
        }
        print("Selected album for destination: \(selectedAlbum)")
    }
}

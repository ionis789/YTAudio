//
//  AlbumCell.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import UIKit

class AlbumCell: UITableViewCell {

    //MARK: Init AlbumCell with asociated AlbumModel
    var album: AlbumModel? {
        didSet {
            if let album = self.album {
                albumName.text = album.title
                albumSongsCount.text = "\(album.audios.count) audios"
                albumCover.image = album.cover ?? UIImage(named: "emptyAlbum")
            }
        }
    }

    //MARK: Views
    private lazy var albumCover: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    private lazy var albumName: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        v.textColor = .white
        return v
    }()

    private lazy var albumSongsCount: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        v.textColor = .gray
        return v
    }()
    private lazy var albumInfoStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [albumName, albumSongsCount])
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.alignment = .leading
        v.distribution = .fillEqually
        v.spacing = 8
        return v
    }()

    //MARK: Init cell, here comes the identifier `albumCell`
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(removeAudio), name: .removeAudioFromAlbum, object: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: Functions
    private func setupView() {
        ///Closure with trail notation (good practice)
        [albumCover, albumInfoStack].forEach { contentView.addSubview($0) }
        setupConstraints()

    }
    private func setupConstraints() {
        ///Album Cover
        NSLayoutConstraint.activate([
            albumCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            albumCover.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            albumCover.widthAnchor.constraint(equalToConstant: 80),
            albumCover.heightAnchor.constraint(equalToConstant: 80),
        ])

        ///AlbumInfoStack (contain `albumName`, `albumSongsCount`)
        NSLayoutConstraint.activate([
            albumInfoStack.leadingAnchor.constraint(equalTo: albumCover.trailingAnchor, constant: 16),
            albumInfoStack.centerYAnchor.constraint(equalTo: albumCover.centerYAnchor),
        ])
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        albumCover.layer.cornerRadius = 16
    }
    @objc func removeAudio(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let audioIndex = userInfo["audioIndex"] as? Int,
                let albumName = userInfo["albumName"] as? String,
                albumName == album?.title
            {
                album?.audios.remove(at: audioIndex)
            }
        }
    }
}

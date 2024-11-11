//
//  AlbumCell.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import UIKit

class AlbumCell: UITableViewCell {

    //MARK: Init AlbumCell with AlbumModel values
    var Album: AlbumModel? {
        didSet {
            albumName.text = Album?.title
            albumSongsCount.text = "\(Album?.songs.count ?? 0) Songs"
            albumCover.image = Album?.cover ?? UIImage(systemName: "music.quarternote.3")
        }
    }


    //MARK: Views
    private lazy var albumCover: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 10
        return v
    }()

    private lazy var albumName: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        v.textColor = .gray
        v.numberOfLines = 0
        return v
    }()

    private lazy var albumSongsCount: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        v.textColor = .gray
        v.numberOfLines = 0
    }()

    //MARK: Init cell, here comes the identifier `albumCell`
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: Functions
    private func setupView() {
        ///Closure with trail notation
        [albumCover, albumName, albumSongsCount].forEach { addSubview($0) }

        setupConstraints()

    }
    private func setupConstraints() {
        ///Album Cover
        NSLayoutConstraint.activate([
            albumCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            albumCover.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            albumCover.widthAnchor.constraint(equalToConstant: 70),
            albumCover.heightAnchor.constraint(equalToConstant: 70),
        ])
        ///Album Name
        NSLayoutConstraint.activate([
            albumName.leadingAnchor.constraint(equalTo: albumCover.trailingAnchor, constant: 16),
            albumName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
        ])
        ///Album Songs Count
        NSLayoutConstraint.activate([
            albumSongsCount.leadingAnchor.constraint(equalTo: albumCover.trailingAnchor, constant: 16),
            albumSongsCount.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 16),
        ])
    }
}

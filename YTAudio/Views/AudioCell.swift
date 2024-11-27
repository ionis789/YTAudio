//
//  AudioCell.swift
//  YTAudio
//
//  Created by Ion Socol on 11/24/24.
//

import UIKit

class AudioCell: UITableViewCell {
    
    
    //MARK: Set all propreties for audioCellView
    var pickedAudio: AudioModel? {
        didSet {
            if let audio = self.pickedAudio {
                audionameLabel.text = audio.title.count > 15 ? audio.title.prefix(15) + "..." : audio.title
                artistNameLabel.text = audio.artist
                durationLabel.text = "Duration " + String(audio.duration)
                audioImage.image = audio.image ?? UIImage(named: "emptyAlbum")
            } else {
                audionameLabel.text = "Unknown"
                artistNameLabel.text = "Unknown"
                durationLabel.text = "0.00"
                audioImage.image = UIImage(named: "emptyAlbum")
            }
        }
    }
    
    //MARK: Views
    private lazy var audioImage: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()
    
    private lazy var audionameLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = .systemFont(ofSize: 14, weight: .semibold)
        v.textColor = .white
        return v
    }()
    
    private lazy var artistNameLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = .systemFont(ofSize: 12, weight: .medium)
        v.textColor = .white
        return v
    }()
    
    private lazy var durationLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = .systemFont(ofSize: 12, weight: .medium)
        v.textColor = .white
        return v
    }()
    
    private lazy var moreOptionsButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        v.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        return v
    }()
    
    private lazy var audioPropretiesStack: UIStackView =  {
        let v = UIStackView(arrangedSubviews: [moreOptionsButton, durationLabel])
        v.axis = .vertical
        v.alignment = .trailing
        v.distribution = .fillEqually
        v.spacing = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var audioInfoStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [audionameLabel, artistNameLabel])
        v.axis = .vertical
        v.alignment = .leading
        v.distribution = .fillEqually
        v.spacing = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    //MARK: Init cell, here comes the identifier `audioCell`
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [audioImage, audioInfoStack, audioPropretiesStack].forEach { contentView.addSubview($0)}
        setupConstraints()
    }
    
    private func setupConstraints() {
        /// ThumbnailImageView
        NSLayoutConstraint.activate([
            audioImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            audioImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            audioImage.widthAnchor.constraint(equalToConstant: 40),
            audioImage.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        /// AudioInfoStack
        NSLayoutConstraint.activate([
            audioInfoStack.leadingAnchor.constraint(equalTo: audioImage.trailingAnchor, constant: 16),
            audioInfoStack.centerYAnchor.constraint(equalTo: audioImage.centerYAnchor),
        ])
        
        /// AudioPropretiesStack
        NSLayoutConstraint.activate([
            audioPropretiesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            audioPropretiesStack.centerYAnchor.constraint(equalTo: audioImage.centerYAnchor),
        ])
    }
}

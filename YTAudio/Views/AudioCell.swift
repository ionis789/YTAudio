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
                audioCover.image = audio.image ?? UIImage(named: "emptyAudio")
                audionameLabel.text = audio.title.count > 20 ? audio.title.prefix(20) + "..." : audio.title
                artistNameLabel.text = audio.artist
                durationLabel.text = String(Float(audio.duration / 60))
            }
        }
    }

    //MARK: Views
    private lazy var audioCover: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.masksToBounds = true
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
        v.font = .systemFont(ofSize: 12, weight: .regular)
        v.textColor = .lightGray
        return v
    }()

    private lazy var durationLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = .systemFont(ofSize: 12, weight: .bold)
        v.textColor = .lightGray
        return v
    }()

    private lazy var moreOptionsButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        v.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        return v
    }()

    private lazy var audioPropretiesStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [moreOptionsButton, durationLabel])
        v.axis = .vertical
        v.alignment = .trailing
        v.distribution = .fillEqually
        v.spacing = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var audioInfoStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [audionameLabel, artistNameLabel])
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.alignment = .leading
        v.distribution = .fillEqually
        v.spacing = 8
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
        [audioCover, audioInfoStack, audioPropretiesStack].forEach { contentView.addSubview($0) }
        setupConstraints()
    }
    private func setupConstraints() {
        // Image constraints
        NSLayoutConstraint.activate([
            audioCover.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            audioCover.widthAnchor.constraint(lessThanOrEqualToConstant: 60),
            audioCover.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
        ])

        NSLayoutConstraint.activate([
            audioInfoStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            audioInfoStack.leadingAnchor.constraint(equalTo: audioCover.trailingAnchor, constant: 8),
            audioInfoStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            audioPropretiesStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            audioPropretiesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            audioPropretiesStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        audioCover.layer.cornerRadius = 10
    }
}

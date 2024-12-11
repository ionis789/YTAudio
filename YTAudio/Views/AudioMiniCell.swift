//
//  AudioMiniCell.swift
//  YTAudio
//
//  Created by Ion Socol on 12/11/24.
//

import UIKit

class AudioMiniCell: UITableViewCell {
    var audio: AudioModel? {
        didSet {
            if let audio = self.audio {
                audionNameLabel.text = audio.title
                audioCover.image = audio.image ?? UIImage(named: "emptyAudio")
            }
        }
    }
    
    //MARK: Views
    private lazy var audionNameLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 18, weight: .semibold)
        v.textColor = .white
        v.numberOfLines = 0
        return v
    }()
    
    private lazy var audioCover: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 10
        return v
    }()
    
    //MARK: Init cell, here comes the identifier `audioMiniCell`
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        audioCover.layer.cornerRadius = audioCover.frame.size.width / 2
    }
    
    private func setupView() {
        [audioCover, audionNameLabel].forEach {contentView.addSubview($0)}
        setupConstraints()
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ///Audio Cover
            audioCover.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            audioCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            audioCover.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            audioCover.widthAnchor.constraint(lessThanOrEqualToConstant: 40),
            audioCover.heightAnchor.constraint(lessThanOrEqualToConstant: 40),
            
            //Audio Title
            audionNameLabel.leadingAnchor.constraint(equalTo: audioCover.trailingAnchor, constant: 10),
            audionNameLabel.centerYAnchor.constraint(equalTo: audioCover.centerYAnchor),
        ])
    }

}

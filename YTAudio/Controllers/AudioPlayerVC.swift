//
//  AudioPlayer.swift
//  YTAudio
//
//  Created by Ion Socol on 11/24/24.
//

import UIKit
import AVFoundation
import MediaPlayer
class AudioPlayerVC: UIViewController {

    //MARK: Init audioPlayer, audioURL
    var audioPlayer = AVAudioPlayer()
    //MARK: Timer playback for synhronization betwen audio play time and slider position
    var playBackTimer: Timer?
    var audio: AudioModel


    //MARK: Init views
    private lazy var audioCoverImage: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        return v
    }()

    private lazy var audioSlider: UISlider = {
        let v = UISlider()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.minimumValue = 0
        v.addTarget(self, action: #selector (sliderValueChanged(_:)), for: .valueChanged)
        return v
    }()

    private lazy var previousAudioButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold)
        v.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        v.tintColor = .myRed
        return v
    }()

    private lazy var nextAudioButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold)
        v.setImage(UIImage(systemName: "arrow.right", withConfiguration: config), for: .normal)
        v.tintColor = .myRed
        return v
    }()

    private lazy var playButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        v.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: config), for: .normal)
        v.tintColor = .myRed
        v.addTarget(self, action: #selector(toogleAudioPlayer), for: .touchUpInside)
        return v
    }()

    private lazy var playerStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [previousAudioButton, playButton, nextAudioButton])
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .horizontal
        v.distribution = .fillEqually
        return v
    }()

// MARK: Init Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        startPlayBackTimer()
    }

//MARK: Init audio file into player
    init(pickedAudio: AudioModel) {
        self.audio = pickedAudio
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: pickedAudio.url)
        } catch {
            print("Error playing audio file \(#file)")
        }
        super.init(nibName: nil, bundle: nil)
        self.audioCoverImage.image = pickedAudio.image
        configureAudioSession()
        setupNowPlayingInfo()
        audioPlayer.play()
        audioSlider.maximumValue = Float(audioPlayer.duration)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//MARK: Reset timer Audio on deinit
    deinit {
        cleanupPlayer()
        print("AudioPlayerVC: Deinitialized.")
    }

    private func setupNowPlayingInfo() {

        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: self.audio.title,
            MPMediaItemPropertyArtist: self.audio.artist ?? "Unknown Artist",
        ]

        // Setează o imagine pentru Lock Screen (dacă există)
        if let coverImage = self.audio.image {
            let artwork = MPMediaItemArtwork(boundsSize: coverImage.size) { _ in coverImage }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }


    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()

            // Setează categoria pentru redare în fundal
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)

            print("Audio session configured for background playback.")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    private func cleanupPlayer() {
        audioPlayer.delegate = nil
        audioPlayer.stop()
        playBackTimer?.invalidate()
        playBackTimer = nil
        print("AudioPlayerVC: Player resources cleaned up.")

    }

    private func setupViews() {
        view.backgroundColor = .black
        [playerStackView, audioSlider, audioCoverImage].forEach { view.addSubview($0) }
        setupConstraints()
    }
    private func setupConstraints() {

        NSLayoutConstraint.activate([
            audioCoverImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            audioCoverImage.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.5),
            audioCoverImage.heightAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.5),
            audioCoverImage.bottomAnchor.constraint(lessThanOrEqualTo: playerStackView.topAnchor)
        ])

        NSLayoutConstraint.activate([
            playerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playerStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120)
        ])
        NSLayoutConstraint.activate([
            audioSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            audioSlider.topAnchor.constraint(equalTo: playerStackView.bottomAnchor, constant: 20),
            audioSlider.widthAnchor.constraint(equalToConstant: view.frame.width - 120)
        ])
    }

//MARK: Actions

// Play and Pause audio
    @objc func toogleAudioPlayer() {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            playButton.setImage(UIImage(systemName: "play.circle", withConfiguration: config), for: .normal)
        } else {
            audioPlayer.play()
            playButton.setImage(UIImage(systemName: "pause.circle", withConfiguration: config), for: .normal)
        }
    }


    private func startPlayBackTimer() {
        playBackTimer?.invalidate()

//        playBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector (changeSliderPosition), userInfo: nil, repeats: true)
        playBackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.changeSliderPosition()
        }
    }
    @objc private func changeSliderPosition() {
        audioSlider.value = Float(audioPlayer.currentTime)
    }

//MARK: Change slider position acording to audio playing time
    @objc func sliderValueChanged(_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(sender.value)
    }
}

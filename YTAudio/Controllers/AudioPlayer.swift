//
//  AudioPlayer.swift
//  YTAudio
//
//  Created by Ion Socol on 11/24/24.
//

import UIKit
import AVFoundation
class AudioPlayer: UIViewController {

    //MARK: Init audioPlayer, audioURL
    var audioPlayer = AVAudioPlayer()
    var audioURL: URL?
    //MARK: Timer playback for synhronization betwen audio play time and slider position
    var playBackTimer: Timer?

    //MARK: Init views
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
    init(pickedAudio: URL) {
        self.audioURL = pickedAudio
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: pickedAudio)
        } catch {
            print("Error playing audio file \(#file)")
        }
        super.init(nibName: nil, bundle: nil)

        audioPlayer.play()
        audioSlider.maximumValue = Float(audioPlayer.duration)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Reset timer on deinit
    deinit {
        playBackTimer?.invalidate()
    }

    private func setupViews() {
        view.backgroundColor = .black
        [playerStackView, audioSlider].forEach { view.addSubview($0) }
        setupConstraints()
    }
    private func setupConstraints() {
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

    //MARK: Play and Pause audio
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

        playBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector (changeSliderPosition), userInfo: nil, repeats: true)
    }
    @objc private func changeSliderPosition() {
        audioSlider.value = Float(audioPlayer.currentTime)
    }

    //MARK: Change slider position acording to audio playing time
    @objc func sliderValueChanged(_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(sender.value)
    }
}

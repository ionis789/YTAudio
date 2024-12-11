//
//  MediaPlayerVC.swift
//  YTAudio
//
//  Created by Ion Socol on 11/24/24.
//

import UIKit
import AVFoundation
import MediaPlayer
class MediaPlayerVC: UIViewController {

    //MARK: Propreties

    ///Audio Model
    var album: [AudioModel]
    var pickedAudioIndex: Int
    var audioPlayer: AVAudioPlayer?
    
    /// `Timer` playback for `synhronization` betwen audio play time and slider position
    var playBackTimer: Timer?

    var isAudioPlaying: Bool = false {
        didSet {
            updatePLayPauseButtonUI(isPlaying: isAudioPlaying)
        }
    }
    
    var isLoop = false // check if for current audio is loop option activate
    var isSeeking = false // track slider change

    //MARK: Init views
    
    /// miniCell id
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.dataSource = self
        v.delegate = self
        v.register(AudioMiniCell.self, forCellReuseIdentifier: "audioMiniCell")
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 60
        v.tableFooterView = UIView()
        return v
    }()
    
    private lazy var audioCoverImage: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.layer.cornerRadius = 30
        v.clipsToBounds = true

        // Creează fundalul cu gradient (cețos) al imaginii
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = v.bounds
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.6).cgColor, // Alb transparent
            UIColor.gray.withAlphaComponent(0.4).cgColor // Gri transparent
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        v.layer.addSublayer(gradientLayer) // Adaugă gradientul ca sub-layer

        return v
    }()

    private lazy var audioSlider: CustomSlider = {
        let v = CustomSlider()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.minimumValue = 0
        // Track user interaction with audio
        /// On `sliderTouchBegan` event `isSeeking = true`(indicate that user start interact with slider)
        /// On `sliderValueChanged` event `update(synchronize)` audio curent time with slider value
        /// On `sliderTouchEnded` event `isSeeking = false` (indicate that user stoped interact with slider)
        v.addTarget(self, action: #selector(sliderTouchBegan(_:)), for: .touchDown)
        v.addTarget(self, action: #selector (sliderValueChanged(_:)), for: .valueChanged)
        v.addTarget(self, action: #selector (sliderTouchEnded(_:)), for: .touchUpInside)
        return v
    }()

    private lazy var previousAudioButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        v.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        v.tintColor = .myRed
        return v
    }()

    private lazy var nextAudioButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        v.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        v.tintColor = .myRed
        return v
    }()

    private lazy var playButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        v.setImage(UIImage(systemName: "pause", withConfiguration: config), for: .normal)
        v.tintColor = .myRed
        v.addTarget(self, action: #selector(togglePlayPlauseButton), for: .touchUpInside)
        return v
    }()
    private lazy var repeatButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setImage(UIImage(systemName: "repeat", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
        v.tintColor = .myRed
        return v
    }()
    private lazy var shuffleButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setImage(UIImage(systemName: "shuffle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
        v.tintColor = .myRed
        return v
    }()

    private lazy var playerControlStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [shuffleButton, playButton, repeatButton])
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .horizontal
        v.distribution = .fillProportionally
        return v
    }()


//    private lazy var playerNavigationStack: UIStackView = {
//        let v = UIStackView(arrangedSubviews: [previousAudioButton, playButton, nextAudioButton])
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.axis = .horizontal
//        v.distribution = .fillProportionally
//        return v
//    }()

// MARK: Init Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updatePlayBackTimer()
    }

//MARK: Init audio file into player
    init(album: [AudioModel], pickedAudioIndex: Int) {
        self.album = album
        self.pickedAudioIndex = pickedAudioIndex
        super.init(nibName: nil, bundle: nil)

        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: album[pickedAudioIndex].url)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.delegate = self
            self.audioPlayer?.play()
            audioSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
        } catch {
            print("Error initializing audioPlayer: \(#file), \(error)")
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//MARK: Clean up all data of Media Player on deinit
    deinit {
        cleanupPlayer()
        print("AudioPlayerVC: Deinitialized.")
    }


    // Configure audio player for background playing features
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth])
            try audioSession.setActive(true)
            print("Audio session configured for playback.")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    private func cleanupPlayer() {
        audioPlayer?.delegate = nil
        audioPlayer?.stop()
        playBackTimer?.invalidate()
        playBackTimer = nil
        print("AudioPlayerVC: Player resources cleaned up.")

    }

    private func setupViews() {
        view.backgroundColor = .black
        [previousAudioButton, nextAudioButton, playerControlStack, audioSlider, audioCoverImage, tableView].forEach { view.addSubview($0) }
        audioCoverImage.image = album[pickedAudioIndex].image ?? UIImage(named: "emptyAudio")
        setupConstraints()
    }
    private func setupConstraints() {

        NSLayoutConstraint.activate([
            audioCoverImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            audioCoverImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            audioCoverImage.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.7),
            audioCoverImage.heightAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.7),
        ])
        
        NSLayoutConstraint.activate([
            previousAudioButton.centerYAnchor.constraint(equalTo: audioCoverImage.centerYAnchor),
            previousAudioButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            nextAudioButton.centerYAnchor.constraint(equalTo: audioCoverImage.centerYAnchor),
            nextAudioButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])

        NSLayoutConstraint.activate([
            playerControlStack.topAnchor.constraint(equalTo: audioSlider.bottomAnchor, constant: 16),
            playerControlStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playerControlStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        NSLayoutConstraint.activate([
            audioSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            audioSlider.topAnchor.constraint(equalTo: audioCoverImage.bottomAnchor, constant: 16),
            audioSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            audioSlider.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: playerControlStack.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }



    // Call this function when audioPlayer.isPlaying proprety is changed in didSet
    private func updatePLayPauseButtonUI(isPlaying: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let image = isPlaying ? UIImage(systemName: "pause", withConfiguration: config) : UIImage(systemName: "play", withConfiguration: config)
        playButton.setImage(image, for: .normal)
    }



    // Shuffle audio
    @objc func shuffleAlbumAudios() {
        // shuffle audio array
    }
    @objc func loopCurrentAudio() {

    }
    @objc func togglePlayPlauseButton() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isAudioPlaying = player.isPlaying
    }

    private func updatePlayBackTimer() {
        playBackTimer?.invalidate()
        //Weak refernce to avoid hold MediaPlayerVC when close popup
        playBackTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.audioSlider.value = Float(self.audioPlayer?.currentTime ?? 0)
        }
    }
    @objc private func changeSliderPosition() {
        audioSlider.value = Float(audioPlayer?.currentTime ?? 0)
    }

    //MARK: Change slider position acording to audio playing time
    @objc func sliderValueChanged(_ sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(sender.value)
        if isSeeking {
            print("isSeeking \(sender.value)")
        }
    }
    @objc func sliderTouchBegan(_ sender: UISlider) {
        isSeeking = true;
        isAudioPlaying = false
        audioPlayer?.stop()
    }
    @objc func sliderTouchEnded(_ sender: UISlider) {
        isSeeking = false
        updatePlayBackTimer()
        isAudioPlaying = true
        audioPlayer?.play()
    }
}

extension MediaPlayerVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioMiniCell",for: indexPath) as? AudioMiniCell else { return UITableViewCell() }
        cell.audio = album[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(album[indexPath.row].title)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return album.count
    }
    
}

extension MediaPlayerVC: AVAudioPlayerDelegate {
    // This method automaticaly stop audio player
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Finished playing")
        isAudioPlaying = player.isPlaying
    }
}





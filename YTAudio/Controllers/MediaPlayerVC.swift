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

    ///Album array
    var album: [AudioModel]
    var pickedAudioIndex: Int? {
        didSet {
            if let index = pickedAudioIndex {
                cleanupPlayer()
                playerInitForCurrentPickedAudioIndex()
                setupViews()
                updatePlayBackTimer()
                print("New audio `\(album[index].title)`, with index `\(index)`")
            }
        }
    }
    /// Stock played audio indexes
    var playedIndexes: [Int] = []
    ///Player
    var audioPlayer: AVAudioPlayer?

    /// `Timer` playback for `synhronization` betwen audio play time and slider position
    var playBackTimer: Timer?

    /// Indicate if audio `is playing` right now or not
    var isAudioPlaying: Bool = true {
        didSet {
            updatePLayPauseButtonUI()
        }
    }

    var isLoop = false // check if for current audio is loop option activate
    var isShuffle = false {
        didSet {
            updateShuffleButtonAppearance()
        }
    } // check if for all album is acivated random playback
    var isSeeking = false // track slider change

    //MARK: Views
    private lazy var mediaPlayerTableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.dataSource = self
        v.delegate = self
        v.register(AudioMiniCell.self, forCellReuseIdentifier: "audioMiniCell")
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 60
        v.tableFooterView = UIView()
        v.backgroundColor = .black
        return v
    }()

    private lazy var audioCoverImage: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.layer.cornerRadius = 20
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
        v.addTarget(self, action: #selector (previousAudioButtonTapped), for: .touchUpInside)
        return v
    }()

    private lazy var nextAudioButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        v.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        v.tintColor = .myRed
        v.addTarget(self, action: #selector(nextAudioButtonTapped), for: .touchUpInside)
        return v
    }()

    private lazy var playButton: UIButton = {
        let v = UIButton(type: .system)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setImage(UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)), for: .normal)

        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .myRed
        config.imagePadding = 0
        config.background.backgroundColor = .myDarkGray
        config.background.cornerRadius = 10

        config.contentInsets = NSDirectionalEdgeInsets(
            top: 15,
            leading: 25,
            bottom: 15,
            trailing: 25
        )
        v.configuration = config
        v.addTarget(self, action: #selector(togglePlayPlauseButton), for: .touchUpInside)
        return v
    }()

    private lazy var loopAudioButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        v.setImage(UIImage(systemName: "repeat", withConfiguration: config), for: .normal)
        v.tintColor = .myRed
        v.addTarget(self, action: #selector(toggleLoop), for: .touchUpInside)
        return v
    }()

    private lazy var shuffleButton: UIButton = {
        let v = UIButton(type: .system)
        v.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.plain()
        config.title = "Shuffle"
        config.image = UIImage(systemName: "shuffle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        config.imagePlacement = .leading
        config.imagePadding = 10
        config.baseForegroundColor = .myRed

        var attributedTitle = AttributedString("Shuffle")
        if let range = attributedTitle.range(of: "Shuffle") {
            attributedTitle[range].font = UIFont.boldSystemFont(ofSize: 16)
        }

        config.attributedTitle = attributedTitle
        config.background.backgroundColor = .myDarkGray
        config.background.cornerRadius = 10
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 15,
            leading: 25,
            bottom: 15,
            trailing: 25
        )
        v.configuration = config
        v.addTarget(self, action: #selector(shuffleAlbum), for: .touchUpInside)
        return v
    }()

    private lazy var playerControlStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [shuffleButton, playButton])
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .horizontal
        v.distribution = .fillEqually
        v.spacing = 8
        return v
    }()

    private lazy var audioSliderControlStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [audioSlider, loopAudioButton])
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .horizontal
        v.distribution = .equalSpacing
        return v
    }()

// MARK: Init Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updatePlayBackTimer()
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

//MARK: Init audio file into player
    init(album: [AudioModel], pickedAudioIndex: Int) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
        self.pickedAudioIndex = pickedAudioIndex
        playerInitForCurrentPickedAudioIndex()

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
    //MARK: Clean up player resources
    private func cleanupPlayer() {
        audioPlayer?.delegate = nil
        audioPlayer?.stop()
        playBackTimer?.invalidate()
        playBackTimer = nil
        print("AudioPlayerVC: Player resources cleaned up.")

    }
    //MARK: init player
    private func playerInitForCurrentPickedAudioIndex() {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: album[pickedAudioIndex ?? 0].url)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.delegate = self
            self.audioPlayer?.play()
            isAudioPlaying = true

            //Init slider
            audioSlider.minimumValue = 0
            audioSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
            audioSlider.value = 0 // Reset to the start position
            audioSlider.updateProgressLayer() // Refresh UI for the slider
        } catch {
            print("Error initializing audioPlayer: \(#file), \(error)")
        }
        configureAudioSession()
    }

    private func setupViews() {
        view.backgroundColor = .black
        [previousAudioButton, nextAudioButton, playerControlStack, audioSliderControlStack, audioCoverImage, mediaPlayerTableView].forEach { view.addSubview($0) }
        audioCoverImage.image = album[pickedAudioIndex ?? 0].image ?? UIImage(named: "emptyAudio")
        setupConstraints()
    }
    private func setupConstraints() {

        NSLayoutConstraint.activate([
            audioCoverImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            audioCoverImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            audioCoverImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            audioCoverImage.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
        ])

        NSLayoutConstraint.activate([
            previousAudioButton.centerYAnchor.constraint(equalTo: audioCoverImage.centerYAnchor),
            previousAudioButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),

            nextAudioButton.centerYAnchor.constraint(equalTo: audioCoverImage.centerYAnchor),
            nextAudioButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])

        NSLayoutConstraint.activate([
            mediaPlayerTableView.topAnchor.constraint(equalTo: playerControlStack.bottomAnchor, constant: 10),
            mediaPlayerTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mediaPlayerTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mediaPlayerTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])

        NSLayoutConstraint.activate([
            playerControlStack.topAnchor.constraint(equalTo: audioCoverImage.bottomAnchor, constant: 10),
            playerControlStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playerControlStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])

        NSLayoutConstraint.activate([

            audioSliderControlStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            audioSliderControlStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            audioSliderControlStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            audioSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),


//            audioSlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//            audioSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
//            audioSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -16),
//
//            loopAudioButton.leadingAnchor.constraint(equalTo: audioSlider.trailingAnchor, constant: 8),
//            loopAudioButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }



    // Call this function when audioPlayer.isPlaying proprety is changed in didSet
    private func updatePLayPauseButtonUI() {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let image = isAudioPlaying ? UIImage(systemName: "pause", withConfiguration: config) : UIImage(systemName: "play", withConfiguration: config)
        playButton.setImage(image, for: .normal)
    }

    //MARK: previousAudioButtonTapped method
    @objc private func previousAudioButtonTapped() {
        if var index = self.pickedAudioIndex, index > 0 && index < self.album.count {
            index -= 1
            self.pickedAudioIndex = index
        }
    }

    //MARK: nextAudioButtonTapped

    @objc private func nextAudioButtonTapped() {
        if var index = self.pickedAudioIndex, index >= 0 && index < self.album.count - 1 {
            index += 1
            self.pickedAudioIndex = index
        }
    }

    // Actualizează apariția butonului în funcție de isShuffle
    private func updateShuffleButtonAppearance() {
        var config = shuffleButton.configuration ?? UIButton.Configuration.plain()

        if isShuffle {
            // Stil când shuffle este activ
            config.background.backgroundColor = .myRed
            config.baseForegroundColor = .white
        } else {
            // Stil când shuffle este inactiv
            config.background.backgroundColor = .myDarkGray
            config.baseForegroundColor = .myRed
        }

        shuffleButton.configuration = config
    }

    private func getNextShuffleTrack() {

        // remaining indexes array
        let remainingIndexes = (0..<album.count).filter { !playedIndexes.contains($0) }

        // Check if remaining indexes array stop audio and reset playedIndexes array
        guard !remainingIndexes.isEmpty else {
            playedIndexes.removeAll()
            isShuffle = false
            isAudioPlaying = false
            cleanupPlayer()
            self.pickedAudioIndex = 0
            return
        }
        if let randomIndex = remainingIndexes.randomElement() {
            self.pickedAudioIndex = randomIndex
            playedIndexes.append(randomIndex)

        }

    }

    @objc func shuffleAlbum() {
        isShuffle.toggle()
        getNextShuffleTrack()
        print("Shuffle state: \(isShuffle)")
    }
    //MARK: Loop audio
    @objc func toggleLoop() {
        isLoop.toggle()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        loopAudioButton.setImage(isLoop ? UIImage(systemName: "repeat.1", withConfiguration: config) : UIImage(systemName: "repeat", withConfiguration: config), for: .normal)
    }
    @objc func togglePlayPlauseButton() {
        if isAudioPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isAudioPlaying.toggle()
    }

    private func updatePlayBackTimer() {
        playBackTimer?.invalidate()
        //Weak refernce to avoid hold MediaPlayerVC when close popup
        playBackTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            audioSlider.value = Float(self.audioPlayer?.currentTime ?? 0)
            audioSlider.updateProgressLayer()
        }
    }
    @objc private func changeSliderPosition() {
        updatePlayBackTimer()
        print(audioSlider.value)
    }

    //MARK: Change slider position acording to audio playing time
    @objc func sliderValueChanged(_ sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(sender.value)
        if isSeeking {
            print("isSeeking \(sender.value)")
        }
        print(sender.value)
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
        if isAudioPlaying { audioPlayer?.play() }
        else { audioPlayer?.pause() }
    }
}

extension MediaPlayerVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickedAudioIndex = indexPath.row
        print(album[indexPath.row].title)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioMiniCell", for: indexPath) as? AudioMiniCell else { return UITableViewCell() }
        cell.audio = album[indexPath.row]
        cell.backgroundView?.backgroundColor = .clear
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return album.count
    }

}

extension MediaPlayerVC: AVAudioPlayerDelegate {
    // This function treat behaviour of player when audio is end played
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

        print("\(album[pickedAudioIndex ?? 0].title) Finished playing")

        guard var index = self.pickedAudioIndex else { return }

        if index < album.count - 1 && !isShuffle && !isLoop {
            // Daca nu e pusa redarea pe loop la un anumit audio sau nu e pornita optiunea de shuffle la album, automat pornesc urmatorul audio
            index += 1
            self.pickedAudioIndex = index
        } else if isLoop && !isShuffle {
            playerInitForCurrentPickedAudioIndex()
        }
        else if isShuffle {
            getNextShuffleTrack()
        }
        else if index == album.count - 1 {
            // Last aduio from album so start play again
            self.pickedAudioIndex = 0
        }
        print("Start next: \(album[pickedAudioIndex ?? 0 + 1].title)")
    }

}





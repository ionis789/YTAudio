//
//  ImportAudioVC.swift
//  YTAudio
//
//  Created by Ion Socol on 11/10/24.
//

import UIKit

class ImportAudioVC: UIViewController, UIDocumentPickerDelegate {

    private var pickeAudioURL: URL?

    private lazy var getAudioTextField: UITextField = {
        let v = UITextField()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 10
        v.layer.borderColor = #colorLiteral(red: 1, green: 0.3223263323, blue: 0.3430142701, alpha: 1)
        v.layer.borderWidth = 1

        // Custom placeholder
        let placeholderText = "YouTube video link..."
        let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.gray
        ]
        v.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)

        // Add gap (padding) on the left
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0)) // Width defines the gap size
        v.leftView = paddingView
        v.leftViewMode = .always
        return v
    }()

    private lazy var getAudioButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("Get", for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        v.backgroundColor = .myRed
        v.layer.cornerRadius = 10
        return v
    }()

    private lazy var orLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "OR"
        v.font = .systemFont(ofSize: 24, weight: .bold)
        v.textColor = .white
        return v
    }()

    private lazy var importButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("Import audio", for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        v.backgroundColor = .myRed
        v.layer.cornerRadius = 10
        v.addTarget(self, action: #selector(didImportAudioButtonTaped), for: .touchUpInside)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
    }

    private func setupViews() {
        [importButton, orLabel, getAudioTextField, getAudioButton].forEach { view.addSubview($0) }
        setupConstraints()
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            getAudioTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            getAudioTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            getAudioTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            getAudioTextField.heightAnchor.constraint(equalToConstant: 52)
        ])

        NSLayoutConstraint.activate([
            getAudioButton.topAnchor.constraint(equalTo: getAudioTextField.bottomAnchor, constant: 32),
            getAudioButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getAudioButton.widthAnchor.constraint(equalToConstant: view.frame.width / 4),
            getAudioButton.heightAnchor.constraint(equalToConstant: 52)
        ])

        NSLayoutConstraint.activate([
            orLabel.topAnchor.constraint(equalTo: getAudioButton.bottomAnchor, constant: 32),
            orLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            importButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 32),
            importButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            importButton.widthAnchor.constraint(equalToConstant: view.frame.width / 3),
            importButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func didImportAudioButtonTaped() {

        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)

    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedAudioURL = urls.first else {
            print("No audio selected")
            return
        }
        /// If the audio file is successfully picked, it can be passed to the throw `AudioDestinationPopup`  to store the file in one of the album's playlists.
        if let pickedAudio: AudioModel = SystemFileService.processPickedAudioURL(at: selectedAudioURL) {
            let audioDestinationPopup = AudioDestinationPopup(audio: pickedAudio)
            present(audioDestinationPopup, animated: true, completion: nil)
            print(pickedAudio)
        } else {
            print("Could not process selected audio file.")
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Cancelled audio import")
    }

}

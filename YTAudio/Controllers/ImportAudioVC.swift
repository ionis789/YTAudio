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
        v.isUserInteractionEnabled = true

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

    private lazy var fetchAudioActivityIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.style = .large
        v.color = .myRed
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
        v.addTarget(self, action: #selector (didGetAudioButtonTapped), for: .touchUpInside)
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
        [importButton, orLabel, getAudioTextField, getAudioButton, fetchAudioActivityIndicator].forEach { view.addSubview($0) }
        setupConstraints()
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            fetchAudioActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fetchAudioActivityIndicator.bottomAnchor.constraint(equalTo: getAudioTextField.topAnchor, constant: -20)
        ])

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

    @objc private func didGetAudioButtonTapped() {
        print("didGetAudioButtonTapped")

        /// Check if the `textField` contains a valid URL.
        guard let textFieldURL = getAudioTextField.text, !textFieldURL.isEmpty else {
            showAlert(title: "Error", message: "Please enter a valid URL")
            return
        }

        /// Build the server URL.
        let serverURLStringFormat = "http://93.116.111.83:3000/extract-audio?url=\(textFieldURL)"
        guard let serverURL = URL(string: serverURLStringFormat) else {
            showAlert(title: "Error", message: "Invalid URL format. Please check again.")
            return
        }

        fetchAudioActivityIndicator.startAnimating()

        /// Create a task to send the request to the server.
        let task = URLSession.shared.dataTask(with: serverURL) { data, response, error in
            // Check for errors.
            if let error = error {
                print("Error from server: \(#file), \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.fetchAudioActivityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                }
                return
            }

            // Check the server response.
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid server response.")
                DispatchQueue.main.async {
                    self.fetchAudioActivityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: "Server response error.")
                    self.getAudioTextField.text = ""
                }
                return
            }

            // Check if the server returned data.
            guard let data = data else {
                print("No data received.")
                DispatchQueue.main.async {
                    self.fetchAudioActivityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: "No data received from server.")
                    self.getAudioTextField.text = ""
                }
                return
            }

            do {
                // Parse the JSON data into a dictionary.
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    //MARK: Proces Server Response
                    self.handleServerDataResponse(data: json)
                } else {
                    print("Failed to parse JSON.")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to parse server response.")
                        self.getAudioTextField.text = ""
                    }
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Error parsing server response.")
                    self.getAudioTextField.text = ""
                }
            }

            // Stop the activity indicator on the main thread.
            DispatchQueue.main.async {
                self.getAudioTextField.resignFirstResponder()
                self.fetchAudioActivityIndicator.stopAnimating()
                self.getAudioTextField.text = ""
            }
        }
        task.resume()
    }

    // From server comes json response in format { ["String", any data] }
    private func handleServerDataResponse(data: [String: Any]) {
        guard let filePath = data["file"] as? String,
            let title = data["title"] as? String,
            let uploader = data["uploader"] as? String,
            let duration = data["duration"] as? Int else {
            print("Error: Missing or invalid data in server response")
            return
        }
        // Base URL of the server
        let serverBaseURL = "http://93.116.111.83:3000"

        // Construct the full URL
        guard let fileDownloadURL = URL(string: serverBaseURL + filePath) else {
            print("Error: Invalid file URL")
            return
        }
        print("File URL: \(fileDownloadURL)")
        print("Title: \(title)")
        print("Uploader: \(uploader)")
        print("Duration: \(duration) seconds")

        // Closure with my function from SystemFileService witch return AudioModel object
        SystemFileService.downloadAudioFileFromURL(fileURL: fileDownloadURL, title: title, duration: String(duration), author: uploader) { audioModel in
            if let audio = audioModel {
                let destination = AudioDestinationPopup(audio: audio)
                self.present(destination, animated: true, completion: nil)
                print(audio.title)
            } else {
                print("Error: Failed to download audio file")
            }

        }



    }


    @objc private func didImportAudioButtonTaped() {

        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)

    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
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
            print(pickedAudio.title)
        } else {
            print("Could not process selected audio file.")
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Cancelled audio import")
    }

}

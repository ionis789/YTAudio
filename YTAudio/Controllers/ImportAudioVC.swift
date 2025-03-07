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
        setupDismissKeyboardGesture()
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
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
        print("Get Tapped")

        //MARK: URL validation
        guard let textFieldURL = getAudioTextField.text, !textFieldURL.isEmpty else {
            showAlert(title: "Error", message: "Please write some URL.")
            return
        }

        let serverURLStringFormat = "http://93.116.111.83:3000/extract-audio?url=\(textFieldURL)"

        guard let serverURL = URL(string: serverURLStringFormat) else {
            showAlert(title: "Error", message: "Invalid URL format. Please check again.")
            return
        }
        //MARK: Start activity indicator while get response from server
        fetchAudioActivityIndicator.startAnimating()

        //Create a URLSession instance
        let session = URLSession.shared

        //Create a data task using URLSessionDataTask
        let dataTask = session.dataTask(with: serverURL) { data, response, error in

            //Check the errors
            if let error = error {
                print("Error: \(#file): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Something went wrong.\n Please try again later.")
                    self.fetchAudioActivityIndicator.stopAnimating()
                    self.getAudioTextField.text = ""
                }
                return
            }
            // Check if data is available
            guard let responseData = data else {
                print("Error: Invalid data received from server")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Error: Invalid data received from server.\n Please try again later.")
                    self.fetchAudioActivityIndicator.stopAnimating()
                    self.getAudioTextField.text = ""
                }
                return
            }

            // If no issues at this moment then start procces received data
            do {

                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: String] {

                    // If received data is valid then download audio file
                    if let audioTitle = json["title"],
                        let audioDownloadURL = json["audio"] {

                        print("Audio title: \(audioTitle)")
                        print("Audio download URL: \(audioDownloadURL)")
                        // Create new task for download data from audioDownloadURL
                        let downloadAudioURLStringFormat = "http://93.116.111.83:3000" + audioDownloadURL
                        let downloadAudioURL = URL(string: downloadAudioURLStringFormat)!

                        let session = URLSession.shared

                        let downloadTask = session.downloadTask(with: downloadAudioURL) { temporaryUrl, response, error in

                            // Check for errors
                            if let error = error {
                                print("Error on trying download audio file from server")
                                DispatchQueue.main.async {
                                    print("Error: \(error)")
                                    self.showAlert(title: "Error", message: "Error on trying download audio file from server.\n Please try again later.")
                                    self.fetchAudioActivityIndicator.stopAnimating()
                                    self.getAudioTextField.text = ""
                                }
                            }

                            if let tempURL = temporaryUrl {
                                print("temporaryUrl", temporaryUrl ?? "Nothing in temporaryUrl")
                                self.writeAudioData(audioData: tempURL, audioName: audioTitle)
                                //MARK: Succesifuly received audio data
                                DispatchQueue.main.async {
                                    self.fetchAudioActivityIndicator.stopAnimating()
                                    self.getAudioTextField.text = ""
                                }
                            }


                        }
                        downloadTask.resume()
                    }
                }

            } catch {
                print("Error parsing JSON(Server iobanîi): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Something went wrong when receiving data from server.\n Please try again later or pick other link.")
                    self.fetchAudioActivityIndicator.stopAnimating()
                }
            }

        }
        dataTask.resume()


    }

    // Configurare UITapGestureRecognizer pentru a ascunde tastatura la apăsarea pe un loc gol
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Permite alte interacțiuni (cum ar fi apăsarea pe butoane)
        view.addGestureRecognizer(tapGesture)
    }

    // Funcție pentru a ascunde tastatura
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func generateUniqueFileName(for name: String, withExtension fileExtension: String, in directory: URL) -> URL {
        var uniqueName = name
        var count = 1
        var uniqueURL = directory.appendingPathComponent("\(uniqueName).\(fileExtension)")

        // Dacă fișierul există, generează un nume nou cu "(1)", "(2)", etc.
        while FileManager.default.fileExists(atPath: uniqueURL.path) {
            uniqueName = "\(name)(\(count))"
            uniqueURL = directory.appendingPathComponent("\(uniqueName).\(fileExtension)")
            count += 1
        }

        return uniqueURL
    }

    private func writeAudioData(audioData: URL, audioName: String) {

        do {
            // Definește directorul și numele fișierului
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            // Generează un URL unic
            let destinationURL = generateUniqueFileName(for: audioName, withExtension: "mp3", in: documentsDirectory)

            // Mută fișierul la locația destinată
            try FileManager.default.moveItem(at: audioData, to: destinationURL)

            print("File saved to: \(destinationURL.path)")

            if let audio = SystemFileService.processPickedAudioURL(at: destinationURL) {
                DispatchQueue.main.async {
                    let destination = AudioDestinationPopup(audio: audio)
                    self.present(destination, animated: true, completion: nil)
                    print(audio.title)
                }
            }
        } catch {
            print("Error saving audio file: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.fetchAudioActivityIndicator.stopAnimating()
                self.showAlert(title: "Error", message: "Failed to save audio file. \n \(error.localizedDescription)")
            }
        }
    }

// From server comes json response in format { ["String", any data] }
    private func handleServerDataResponse(url: String) {

        // Construct the full URL
        guard let fileDownloadURL = URL(string: url) else {
            print("Error: Invalid file URL")
            return
        }
        print("File URL: \(fileDownloadURL)")


        // Closure with my function from SystemFileService witch return AudioModel object
        NetworkService.downloadAudioFileFromURL(fileURL: fileDownloadURL) { audioModel in
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

        // Începe accesarea resursei securizate
        guard selectedAudioURL.startAccessingSecurityScopedResource() else {
            print("Could not access secured resource.")
            return
        }

        defer {
            // Închide accesarea securizată după terminarea procesării
            selectedAudioURL.stopAccessingSecurityScopedResource()
        }

        // Salvează fișierul în directorul aplicației
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(selectedAudioURL.lastPathComponent)

        do {
            // Dacă fișierul deja există, îl ștergem pentru a-l suprascrie
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            // Copiem fișierul în directorul aplicației
            try FileManager.default.copyItem(at: selectedAudioURL, to: destinationURL)

            print("File copied to: \(destinationURL.path)")

            // Procesăm fișierul copiat
            if let pickedAudio: AudioModel = SystemFileService.processPickedAudioURL(at: destinationURL) {
                let audioDestinationPopup = AudioDestinationPopup(audio: pickedAudio)
                present(audioDestinationPopup, animated: true, completion: nil)
                print("Audio Processed: \(pickedAudio.title)")
            } else {
                print("Could not process the selected audio file.")
            }

        } catch {
            print("Failed to copy audio file: \(error.localizedDescription)")
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Cancelled audio import")
    }

}

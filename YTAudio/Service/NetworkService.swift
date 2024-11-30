//
//  NetworkService.swift
//  YTAudio
//
//  Created by Ion Socol on 11/26/24.
//

import UIKit

class NetworkService {
    
    static func downloadAudioFileFromURL(fileURL: URL, completion: @escaping (AudioModel?) -> Void) {
        let downLoadTask = URLSession.shared.downloadTask(with: fileURL) { urlOrNil, responseOrNil, errorOrNil in
            // Error handling
            if let error = errorOrNil {
                print("Error downloading file: \(error.localizedDescription)")
                completion(nil) // Return nil if download fails
                return
            }

            // Obtain tempLocation of downloaded file
            guard let audioFileURL = urlOrNil else {
                print("Error downloading file: No temporary location found")
                completion(nil) // Return nil if no temporary location
                return
            }
            print("File temporarily downloaded to: \(audioFileURL.path)")

            // Move the file from the temp location to a permanent location (e.g., Documents directory)
            do {

                let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
                let savedURL = documentsURL.appendingPathComponent(audioFileURL.lastPathComponent)
                try FileManager.default.moveItem(at: audioFileURL, to: savedURL)

                print("File moved to: \(savedURL.path)")

                // Process the file after it's moved
                DispatchQueue.main.async {
                    let audioModel = SystemFileService.processPickedAudioURL(at: savedURL)
                    completion(audioModel) // Return the AudioModel via the completion handler
                }
            } catch {
                print("Error moving file: \(error.localizedDescription)")
                completion(nil) // Return nil if file move fails
            }
        }
        downLoadTask.resume()
    }
    
    
    
}



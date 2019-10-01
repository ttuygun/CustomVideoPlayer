//
//  Recorder.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 1.10.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import AVFoundation

enum RecordPlayerManagerError: Error {
    case audioRecordingInitError
    case recordingSessionError
    case preparePlayError
}

class RecordPlayerManager: NSObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingSession = AVAudioSession.sharedInstance()
    var fileUrl: URL?
    var name: String
    var userPermission = false
    private let path = "m4a"

    init(with name: String) {
        self.name = name
    }

    private let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private func getFileUrl() -> URL {
        return getDocumentsDirectory().appendingPathComponent(name).appendingPathExtension(path)
    }

    private func permitRecording() throws -> Bool {
         var permissionGranted = false
         do {
             try recordingSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
             try recordingSession.setActive(true)
         } catch {
             throw RecordPlayerManagerError.recordingSessionError
         }
         
         switch recordingSession.recordPermission {
         case .granted:
             permissionGranted = true
         case .denied:
             // pop out a alert controller in here.
             debugPrint("user denied the permission")
         case .undetermined:
             recordingSession.requestRecordPermission { (granted) in
                 if granted {
                     permissionGranted = true
                 }
             }
         default:
             debugPrint("none")
         }
         return permissionGranted
     }

    private func prepareRecord() throws {
        guard let permissionGranted = try? permitRecording() else {
            return
        }
        if permissionGranted {
            let fileUrl = getFileUrl()
            debugPrint("fileUrl=\(fileUrl)")
            do {
                audioRecorder = try AVAudioRecorder(url: fileUrl, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.record()
            } catch {
                throw RecordPlayerManagerError.audioRecordingInitError
            }
            self.fileUrl = fileUrl
        }
    }

    func startRecord() {
        if audioRecorder == nil {
            try? prepareRecord()
            audioRecorder?.record()
        } else {
            audioRecorder?.record()
        }
        debugPrint("isRecording = \(String(describing: audioRecorder?.isRecording))")
    }

    private func preparePlay() throws {
        guard let fileUrl = fileUrl else {
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileUrl)
        } catch {
            throw RecordPlayerManagerError.preparePlayError
        }
    }

    func playRecord() {
        if audioPlayer == nil {
            try? preparePlay()
            audioPlayer?.play()
        } else {
            audioPlayer?.play()
        }
        debugPrint("\(String(describing: fileUrl)) is playing...")
    }

    func pauseRecord() {
        if isRecording {
            audioRecorder?.pause()
        }
    }

    func stopRecord() {
        if audioRecorder?.isRecording ?? false {
            debugPrint("Recorder stopping..")
            audioRecorder?.stop()
            audioRecorder = nil
            debugPrint("Recorder has stopped")
        }
    }

    func pausePlayer() {
        if isPlaying {
            audioPlayer?.pause()
        }
    }

    func stopPlayer() {
        if isPlaying {
            audioPlayer?.stop()
            audioPlayer = nil
        }
    }

    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
}

extension RecordPlayerManager: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        fatalError(String(describing: error))
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        NotificationCenter.default.post(name: Notification.Name("AudioRecorderDidFinishRecording"), object: nil)
    }
}

extension RecordPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: Notification.Name("AudioPlayerDidFinishPlaying"), object: nil)
    }
}

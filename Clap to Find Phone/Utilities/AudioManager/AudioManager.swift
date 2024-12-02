////
////  AudioManager.swift
////  Clap to Find Phone
////
////  Created by Tipu Sultan on 12/2/24.
////
//
//import SwiftUI
//import AVFoundation
//
//class AudioManager: ObservableObject {
//    private let audioEngine = AVAudioEngine()
//    @Published var clapDetected = false
//
//    func requestMicrophonePermission() {
//        AVAudioSession.sharedInstance().requestRecordPermission { granted in
//            if granted {
//                DispatchQueue.main.async {
//                    self.startListening()
//                }
//            } else {
//                print("Microphone access denied.")
//            }
//        }
//    }
//
//    private func startListening() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
//            try audioSession.setActive(true)
//        } catch {
//            print("Error configuring audio session: \(error)")
//            return
//        }
//
//        let inputNode = audioEngine.inputNode
//        let inputFormat = inputNode.inputFormat(forBus: 0)
//
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, _ in
//            self.detectClap(buffer: buffer)
//        }
//
//        do {
//            try audioEngine.start()
//            print("Audio engine started")
//        } catch {
//            print("Audio engine failed to start: \(error)")
//        }
//    }
//
//    private func detectClap(buffer: AVAudioPCMBuffer) {
//        guard let channelData = buffer.floatChannelData?[0] else { return }
//        let frameLength = Int(buffer.frameLength)
//
//        // Safely process the channel data
//        let channelDataPointer = UnsafeBufferPointer(start: channelData, count: frameLength)
//        let squaredValues = channelDataPointer.map { $0 * $0 }
//        let sumOfSquares = squaredValues.reduce(0, +)
//        let meanSquare = sumOfSquares / Float(frameLength)
//        let rms = sqrt(meanSquare)
//
//        // Threshold for detecting a clap (adjust as needed)
//        if rms > 0.1 {
//            DispatchQueue.main.async {
//                self.clapDetected = true
//                self.triggerFeedback()
//            }
//        }
//    }
//
//
//    private func triggerFeedback() {
//        let generator = UINotificationFeedbackGenerator()
//        generator.notificationOccurred(.success)
//    }
//
//    func resetClapStatus() {
//        clapDetected = false
//    }
//}


import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var audioPlayer: AVAudioPlayer? // To play alarm sound
    @Published var clapDetected = false

    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                DispatchQueue.main.async {
                    self.startListening()
                }
            } else {
                print("Microphone access denied.")
            }
        }
    }

    private func startListening() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Error configuring audio session: \(error)")
            return
        }

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, _ in
            self.detectClap(buffer: buffer)
        }

        do {
            try audioEngine.start()
            print("Audio engine started")
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    private func detectClap(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        let channelDataPointer = UnsafeBufferPointer(start: channelData, count: frameLength)
        let squaredValues = channelDataPointer.map { $0 * $0 }
        let sumOfSquares = squaredValues.reduce(0, +)
        let meanSquare = sumOfSquares / Float(frameLength)
        let rms = sqrt(meanSquare)

        if rms > 0.1 {
            DispatchQueue.main.async {
                self.clapDetected = true
                self.triggerAlarm()
            }
        }
    }

    private func triggerAlarm() {
        if let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.play()
            } catch {
                print("Failed to play alarm sound: \(error)")
            }
        }
    }

    func stopAlarm() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    func resetClapStatus() {
        clapDetected = false
    }
}

//
//  ContentView.swift
//  Clap to Find Phone
//
//  Created by MacBook Pro M1 Pro on 12/1/24.
//

import SwiftUI
//import AVFoundation

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()

    var body: some View {
        VStack {
            Text(audioManager.clapDetected ? "🎉 Clap Detected!" : "Listening for claps...")
                .font(.largeTitle)
                .padding()
                .foregroundColor(audioManager.clapDetected ? .green : .primary)

            Button(action: audioManager.resetClapStatus) {
                Text("Reset")
                    .font(.title2)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .onAppear {
            audioManager.requestMicrophonePermission()
        }
        .padding()
    }
}


#Preview {
    ContentView()
}

//
//  MirrorViewController.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 25.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import UIKit
import AVFoundation

class MirrorViewController: CustomVideoViewController {

    var redrawings: [DrawingModel] = []
    var lastPlayedIndex = 0

    var workers: [VideoDrawWork] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        handleDrawing()
        playingState = .readyToPlay
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction override func playButtonClicked(_ sender: UIButton) {
        switch playingState {
        case .some(.replay):
            player.seek(to: .zero) { (completed) in
                if completed {
                    self.playingState = .playing
                    self.handlePlayingStateControls()
                }
            }
            secondPlayer.seek(to: .zero)
        case .some(.playing):
            playingState = .paused
            self.handlePlayingStateControls()
        case .some(.paused):
            playingState = .playing
            self.handlePlayingStateControls()
            resetTimer()
        case .some(.readyToPlay):
            playingState = .playing
            self.handlePlayingStateControls()
        case .none:
            debugPrint("none")
        }
        handleDrawing()
    }
    
    private func handleDrawing() {
        switch playingState {
        case .some(.playing):
            for i in lastPlayedIndex..<redrawings.count {
                let drawing = redrawings[i]
                let worker = VideoDrawWork(delay: drawing.second - player.currentTime().seconds)
                worker.run {
                    self.drawLine(from: drawing.startPoint, to: drawing.endPoint)
                    self.lastPlayedIndex = i
                }
                workers.append(worker)
            }
        case .some(.paused):
            cancelWorkers()
        default:
            debugPrint("none")
        }
    }
    
    private func cancelWorkers() {
        for worker in workers {
            worker.cancel()
        }
    }
}

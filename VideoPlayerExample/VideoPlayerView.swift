//
//  VideoPlayerView.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 16.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class VideoPlayerView: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    var isVideoPlaying = false
    
    init(withFrame frame: CGRect, videoURL: URL) {
        super.init(frame: frame)
        
        setupVideoPlayer(with: videoURL)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupVideoPlayer(with url: URL) {
        addPlayer(with: url)
        player?.play()
        isVideoPlaying = true
    }
    
    private func addPlayer(with url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
   
        if let playerLayer = playerLayer {
            self.layer.addSublayer(playerLayer)
            playerLayer.frame = self.bounds
        }
    }
    
    internal func playPausePlayer() {
        if isVideoPlaying {
            player?.pause()
            isVideoPlaying = false
        } else {
            player?.play()
            isVideoPlaying = true
        }
    }
}

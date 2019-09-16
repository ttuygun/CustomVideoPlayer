//
//  ViewController.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 16.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var isVideoPlaying = false
    var isVideoMuted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let url = URL(string: "https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8")!
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        videoView.layer.addSublayer(playerLayer)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    @IBAction private func playButtonClicked(_ sender: UIButton) {
        if isVideoPlaying {
            player.pause()
            sender.setImage(UIImage(named: "play"), for: .normal)
        } else {
            player.play()
            sender.setImage(UIImage(named: "pause"), for: .normal)
        }
        isVideoPlaying = !isVideoPlaying
    }
    
    @IBAction private func muteButtonClicked(_ sender: UIButton) {
        if isVideoMuted {
            player.isMuted = false
            sender.setImage(UIImage(named: "mute"), for: .normal)
        } else {
            player.isMuted = true
            sender.setImage(UIImage(named: "sound"), for: .normal)
        }
        isVideoMuted = !isVideoMuted
    }
}


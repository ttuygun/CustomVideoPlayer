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
    @IBOutlet weak var videoPlayerView: UIView!

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var bottomPlayPauseButton: UIButton!
    @IBOutlet weak var playerBottomView: UIView!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var isVideoPlaying = false
    var isVideoMuted = false
    var isVideoFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let url = URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
        player = AVPlayer(url: url)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.videoPlayerDidClicked))
        videoView.addGestureRecognizer(tap)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        videoView.layer.addSublayer(playerLayer)
        
        playPauseButton.alpha = 0.8
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func playerDidFinishPlaying() {
        isVideoFinished = true
        playPauseButton.setImage(UIImage(named: "replay"), for: .normal)
        playPauseButton.isHidden = false
        isVideoPlaying = false
    }
    
    @objc private func videoPlayerDidClicked() {
        // show controls
        decideHidingBottomViewAndPlayPauseButton(state: false)
        
        if isVideoPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.decideHidingBottomViewAndPlayPauseButton(state: true)
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        playerLayer.frame = videoPlayerView.bounds
    }

    @IBAction private func playButtonClicked(_ sender: UIButton) {
        if isVideoFinished {
            player.seek(to: .zero) { (completed) in
                if completed {
                    self.player.play()
                    self.isVideoFinished = false
                    self.isVideoPlaying = true
                    self.decideHidingBottomViewAndPlayPauseButton(state: true)
                }
            }
        }
        
        if isVideoPlaying {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            bottomPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
            isVideoPlaying = false
        } else {
            player.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            bottomPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.decideHidingBottomViewAndPlayPauseButton(state: true)
            }
            isVideoPlaying = true
        }
    }

    private func decideHidingBottomViewAndPlayPauseButton(state: Bool) {
        if isVideoPlaying {
            self.playPauseButton.isHidden = state
            self.playerBottomView.isHidden = state
        }
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

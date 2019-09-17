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
    var isVideoElementsShowed = false
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
        
        playPauseButton.alpha = 0.5
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(self.playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }
    
    @objc func playerDidFinishPlaying() {
        print("Video Finished")
        isVideoFinished = true
        
        playPauseButton.setImage(UIImage(named: "replay"), for: .normal)
        playPauseButton.isHidden = false
       
    }
    
    @objc func videoPlayerDidClicked() {
        if !isVideoElementsShowed {
            self.playPauseButton.isHidden = false
            self.playerBottomView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() +  3, execute: {
                self.playPauseButton.isHidden = true
                self.playerBottomView.isHidden = true
                self.isVideoElementsShowed = false
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        playerLayer.frame = videoPlayerView.bounds
    }

    @IBAction private func playButtonClicked(_ sender: UIButton) {
        if isVideoFinished {
//            player.seek(to: CMTime.zero)
//            player.play()

            
            player.seek(to: CMTime.zero) { (seek) in
                print(seek)
                self.player.play()
                self.isVideoFinished = false

            }
        }
        
        if isVideoPlaying {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            bottomPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
            playPauseButton.isHidden = false
            self.playerBottomView.isHidden = false

        } else {
            player.playImmediately(atRate: 50)
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            bottomPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.playPauseButton.isHidden = true
                self.playerBottomView.isHidden = true
            }
    
        }
        isVideoPlaying = !isVideoPlaying
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        to do...
    }
    
    @IBAction private func muteButtonClicked(_ sender: UIButton) {
        if !isVideoMuted {
            player.isMuted = true
            sender.setImage(UIImage(named: "mute"), for: .normal)
        } else {
            player.isMuted = false
            sender.setImage(UIImage(named: "sound"), for: .normal)
        }
        isVideoMuted = !isVideoMuted
    }
}


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
    
    @IBOutlet weak var fasterLabel: UILabel!
    @IBOutlet weak var slowerLabel: UILabel!
    
    var playRate: Float = 1
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var isVideoPlaying = false
    var isVideoMuted = false
    var isVideoFinished = false
    
    var timer: Timer?
    var seconds = 0
    
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
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        fasterLabel.text = ""
        slowerLabel.text = ""
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

        seconds = 0
    }
    
    @objc func runTimedCode() {
        print(seconds)
        if seconds == 3 {
            if self.isVideoPlaying {
                self.decideHidingBottomViewAndPlayPauseButton(state: true)
                self.seconds = 0
                self.timer?.invalidate()
            }
        }
        seconds += 1
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
            seconds = 0
            timer?.invalidate()
        } else {
            player.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            bottomPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            seconds = 0
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
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
        seconds = 0
        if isVideoMuted {
            player.isMuted = false
            sender.setImage(UIImage(named: "sound"), for: .normal)
        } else {
            player.isMuted = true
            sender.setImage(UIImage(named: "mute"), for: .normal)
        }
        isVideoMuted = !isVideoMuted
        seconds = 0
    }
    
    @IBAction private func fasterButtonClicked(_ sender: UIButton) {
        if isVideoPlaying {
            seconds = 0
            playRate *= 2
            
            if playRate < 1 {
                slowerLabel.text = "-\(playRate)x"
                fasterLabel.text = ""
            } else if playRate > 1 {
                fasterLabel.text = "\(playRate)x"
                slowerLabel.text = ""
            } else {
                slowerLabel.text = ""
                fasterLabel.text = ""
            }
            
            player.playImmediately(atRate: playRate)
        }
    }
    
    @IBAction private func slowerButtonClicked(_ sender: UIButton) {
        if isVideoPlaying {
            seconds = 0
            playRate /= 2
            
            if playRate > 1 {
                slowerLabel.text = ""
                fasterLabel.text = "\(playRate)x"
            } else if playRate < 1 {
                fasterLabel.text = ""
                slowerLabel.text = "-\(playRate)x"
            } else {
                slowerLabel.text = ""
                fasterLabel.text = ""
            }
            
            player.playImmediately(atRate: playRate)
        }
    }
}

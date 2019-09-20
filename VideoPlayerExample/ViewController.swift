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
    @IBOutlet weak var videoView2: UIView!
    @IBOutlet weak var videoPlayerView: UIView!

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var bottomPlayPauseButton: UIButton!
    @IBOutlet weak var playerBottomView: UIView!
    
    @IBOutlet weak var fasterLabel: UILabel!
    @IBOutlet weak var slowerLabel: UILabel!
    
    @IBOutlet weak var timeSlider: UISlider!
    
    var playRate: Float = 1
    
    var player: AVPlayer!
    var player2: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var playerLayer2: AVPlayerLayer!
    
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
        
        player2 = AVPlayer(url: url)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.videoPlayerDidClicked))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.videoPlayerDidClicked))
        videoView.addGestureRecognizer(tap)
        videoView2.addGestureRecognizer(tap2)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        playerLayer2 = AVPlayerLayer(player: player2)
        playerLayer2.videoGravity = .resize
        
        videoView.layer.addSublayer(playerLayer)
        videoView2.layer.addSublayer(playerLayer2)
        
        playPauseButton.alpha = 0.8
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        player.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration), options: [.new], context: nil)
        addTimeObserver()
        
        fasterLabel.text = ""
        slowerLabel.text = ""
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            print(time)
            guard let currentItem = self?.player.currentItem else {
                return
            }
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
        })
    }
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        player.seek(to: CMTimeMake(value: Int64(sender.value * 1000), timescale: 1000))
        player2.seek(to: CMTimeMake(value: Int64(sender.value * 1000), timescale: 1000))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration))
    }
    
    @objc private func playerDidFinishPlaying() {
        isVideoFinished = true
        playPauseButton.setImage(UIImage(named: "replay"), for: .normal)
        playPauseButton.isHidden = false
        isVideoPlaying = false
        slowerLabel.text = ""
        fasterLabel.text = ""
    }
    
    @objc private func videoPlayerDidClicked() {
        // show controls
        decideHidingBottomViewAndPlayPauseButton(state: false)
        seconds = 0
    }
    
    @objc private func runTimedCode() {
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

//        playerLayer.frame = videoPlayerView.bounds
        
        playerLayer.frame = videoView.bounds
        playerLayer2.frame = videoView2.bounds
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
            
            player2.seek(to: .zero) { (completed) in
                if completed {
                    self.player2.play()
                }
            }
        }
        
        if isVideoPlaying {
            player.pause()
            player2.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            bottomPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
            isVideoPlaying = false
            seconds = 0
            timer?.invalidate()
        } else {
            player.play()
            player2.play()
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
            player2.isMuted = false
            sender.setImage(UIImage(named: "sound"), for: .normal)
        } else {
            player.isMuted = true
            player2.isMuted = true
            sender.setImage(UIImage(named: "mute"), for: .normal)
        }
        isVideoMuted = !isVideoMuted
        seconds = 0
    }
    
    @IBAction private func fasterButtonClicked(_ sender: UIButton) {
        if isVideoPlaying {
            seconds = 0
            if playRate >= 8 {
                playRate = 1
                slowerLabel.text = ""
                fasterLabel.text = ""
            } else if playRate < 1 {
                playRate += 0.25
                if playRate == 1 {
                    slowerLabel.text = ""
                    fasterLabel.text = ""
                } else {
                    slowerLabel.text = "-\(1 - playRate)x"
                    fasterLabel.text = ""
                }
            } else if playRate > 1 {
                playRate *= 2
                fasterLabel.text = "\(playRate)x"
                slowerLabel.text = ""
            } else if playRate == 1 {
                playRate *= 2
                fasterLabel.text = "\(playRate)x"
                slowerLabel.text = ""
            }
            player.playImmediately(atRate: playRate)
            player2.playImmediately(atRate: playRate)
            
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.layoutSubviews()
    }
    
    @IBAction private func slowerButtonClicked(_ sender: UIButton) {
        if isVideoPlaying {
            seconds = 0
            
            print(playRate)
            if playRate <= 0.25 {
                isVideoPlaying = true
                slowerLabel.text = ""
                fasterLabel.text = ""
                self.decideHidingBottomViewAndPlayPauseButton(state: true)
                playRate = 1
                player.playImmediately(atRate: playRate)
                player2.playImmediately(atRate: playRate)
                
            } else if playRate > 1 {
                playRate /= 2
                slowerLabel.text = ""
                if playRate == 1 {
                    fasterLabel.text = ""
                } else {
                    fasterLabel.text = "\(playRate)x"
                }
                player.playImmediately(atRate: playRate)
                player2.playImmediately(atRate: playRate)
            } else if playRate < 1 {
                playRate -= 0.25
                fasterLabel.text = ""
                slowerLabel.text = "-\(1 - playRate)x"
                player.playImmediately(atRate: playRate)
                player2.playImmediately(atRate: playRate)
            } else if playRate == 1 {
                playRate = 0.75
                slowerLabel.text = "-\(1 - playRate)x"
                fasterLabel.text = ""
                player.playImmediately(atRate: playRate)
                player2.playImmediately(atRate: playRate)
            }
            
            print("playRate=\(playRate)")
        }
    }
}

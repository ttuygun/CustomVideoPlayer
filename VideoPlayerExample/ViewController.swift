//
//  ViewController.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 16.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import UIKit
import AVFoundation

enum PlayingState: String {
    case readyToPlay = "readyToPlay"
    case playing = "playing"
    case paused = "paused"
    case replay = "replay"
}

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
    var playerLayer: AVPlayerLayer!
    var playerLayer2: AVPlayerLayer!
    
    var timer: Timer?
    var seconds: Int = 0
    
    var playingState: PlayingState!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let url = URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
        player = AVPlayer(url: url)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.videoPlayerDidClicked))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.videoPlayerDidClicked))
        
        videoView.addGestureRecognizer(tap)
        videoView2.addGestureRecognizer(tap2)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        playerLayer2 = AVPlayerLayer(player: player)
        playerLayer2.videoGravity = .resize
        
        videoView.layer.addSublayer(playerLayer)
        videoView2.layer.addSublayer(playerLayer2)
        
        playPauseButton.alpha = 0.8
        setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
        resetTimer()
        playingState = .readyToPlay
        initObservers()
    }
    
    private func initObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerDidPlayToEndTime),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        
        
        player.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration), options: [.new], context: nil)
        addTimeObserver()
    }
    
    private func setFasterSlowerLabels(fasterLabel: String, slowerLabel: String) {
        self.fasterLabel.text = fasterLabel
        self.slowerLabel.text = slowerLabel
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            debugPrint(time)
            guard let currentItem = self?.player.currentItem else {
                return
            }
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
        })
    }
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        resetTimer()
        player.seek(to: CMTimeMake(value: Int64(sender.value * 1000), timescale: 1000))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration))
    }
    
    @objc private func playerDidPlayToEndTime() {
        self.playingState = .replay
        self.handlePlayingStateControls()
        self.setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
    }
    
    private func handlePlayingStateControls() {
        if playingState == .init(.readyToPlay) {
            bottomPlayPauseButton.isHidden = false
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        } else if playingState == .init(.playing) {
            player.playImmediately(atRate: playRate)
            playerBottomView.isHidden = false
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            bottomPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        } else if playingState == .init(.paused) {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            bottomPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
        } else if playingState == .init(.replay) {
            playerBottomView.isHidden = true
            playPauseButton.setImage(UIImage(named: "replay"), for: .normal)
            resetTimer()
        }
    }
    
    private func willHidePlayPauseButtonAndBottomView(state hidingState: Bool) {
        if playingState == .init(.playing) {
            playPauseButton.isHidden = hidingState
            playerBottomView.isHidden = hidingState
        }
    }
    
    @objc private func videoPlayerDidClicked() {
        resetTimer()
        willHidePlayPauseButtonAndBottomView(state: false)
    }
    
    private func resetTimer() {
        seconds = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }
    
    @objc private func runTimedCode() {
//        debugPrint(seconds)
        if seconds == 3 {
            if playingState == .init(.playing) {
                self.willHidePlayPauseButtonAndBottomView(state: true)
                resetTimer()
            }
        }
        seconds += 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer.frame = videoView.bounds
        playerLayer2.frame = videoView2.bounds
    }

    @IBAction private func playButtonClicked(_ sender: UIButton) {
        if playingState == .init(.replay) {
            player.seek(to: .zero) { (completed) in
                if completed {
                    self.playingState = .playing
                    self.handlePlayingStateControls()
                }
            }
        } else if playingState == .init(.playing) {
            playingState = .paused
            self.handlePlayingStateControls()
        } else if playingState == .init(.paused) {
            playingState = .playing
            self.handlePlayingStateControls()
            resetTimer()
        } else if playingState == .init(.readyToPlay) {
            playingState = .playing
            self.handlePlayingStateControls()
        }
    }

    @IBAction private func muteButtonClicked(_ sender: UIButton) {
        let soundImage = UIImage(named: "sound")
        let muteImage = UIImage(named: "mute")
        
        sender.setImage(player.isMuted ? soundImage: muteImage, for: .normal)
        player.isMuted = !player.isMuted
        resetTimer()
    }
    
    @IBAction private func fasterButtonClicked(_ sender: UIButton) {
        resetTimer()
        if playRate >= 8 {
            playRate = 1
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
        } else if playRate >= 1 {
            playRate *= 2
            setFasterSlowerLabels(fasterLabel: "\(playRate)x", slowerLabel: "")
        } else if playRate < 1 {
            playRate += 0.25
            if playRate == 1 {
                setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
            } else {
                setFasterSlowerLabels(fasterLabel: "", slowerLabel: "-\(1 - playRate)x")
            }
        }
        debugPrint("playRate=\(playRate)")
        handlePlayingStateControls()
    }
    
    @IBAction private func slowerButtonClicked(_ sender: UIButton) {
        resetTimer()
        if playRate <= 0.25 {
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
            playRate = 1
        } else if playRate <= 1 {
            playRate -= 0.25
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "-\(1 - playRate)x")
        } else if playRate > 1 {
            playRate /= 2
            if playRate == 1 {
                setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
            } else {
                setFasterSlowerLabels(fasterLabel: "\(playRate)x", slowerLabel: "")
            }
        }
        debugPrint("playRate=\(playRate)")
        handlePlayingStateControls()
    }
}

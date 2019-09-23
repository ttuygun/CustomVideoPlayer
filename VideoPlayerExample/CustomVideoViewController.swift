//
//  CustomVideoViewController.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 16.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import UIKit
import AVFoundation

class CustomVideoViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var secondVideoView: UIView!
    @IBOutlet weak var videoPlayerView: UIView!

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var bottomPlayPauseButton: UIButton!
    @IBOutlet weak var playerBottomView: UIView!
    
    @IBOutlet weak var fasterLabel: UILabel!
    @IBOutlet weak var slowerLabel: UILabel!
    
    @IBOutlet weak var timeSlider: UISlider!
    
    var playRate: PlayRate = .x
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var secondPlayerLayer: AVPlayerLayer!
    
    var timer: Timer?
    var seconds: Int = 0
    
    var playingState: PlayingState!
    
    let videoFPS: Float = 30.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resetTimer()
        initLayouts()
        initObservers()
        playingState = .readyToPlay
        setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
    }
    
    private func initLayouts() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.videoPlayerDidClicked))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.videoPlayerDidClicked))
        
        videoView.addGestureRecognizer(tap)
        secondVideoView.addGestureRecognizer(tap2)
        
        let url = URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
        player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        secondPlayerLayer = AVPlayerLayer(player: player)
        secondPlayerLayer.videoGravity = .resize
        
        videoView.layer.addSublayer(playerLayer)
        secondVideoView.layer.addSublayer(secondPlayerLayer)
        
        playPauseButton.alpha = 0.8
        // layout views
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
//            debugPrint(time)
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
        player.seek(to: CMTimeMake(value: Int64(sender.value * videoFPS), timescale: Int32(videoFPS)))
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
        let playImage = UIImage(named: "play")
        let pauseImage = UIImage(named: "pause")
        let replayImage = UIImage(named: "replay")
        
        switch playingState {
        case .some(.readyToPlay):
            bottomPlayPauseButton.isHidden = false
            playPauseButton.setImage(playImage, for: .normal)
        case .some(.playing):
            player.playImmediately(atRate: playRate.rawValue)
            playerBottomView.isHidden = false
            playPauseButton.setImage(pauseImage, for: .normal)
            bottomPlayPauseButton.setImage(pauseImage, for: .normal)
        case .some(.paused):
            player.pause()
            playPauseButton.setImage(playImage, for: .normal)
            bottomPlayPauseButton.setImage(playImage, for: .normal)
            timer?.invalidate()
        case .some(.replay):
            playerBottomView.isHidden = true
            playPauseButton.setImage(replayImage, for: .normal)
            resetTimer()
        case .none:
            debugPrint("none")
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
        debugPrint(seconds)
        if seconds > 2 {
            if playingState == .init(.playing) {
                self.willHidePlayPauseButtonAndBottomView(state: true)
                timer?.invalidate()
            }
        }
        seconds += 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer.frame = videoView.bounds
        secondPlayerLayer.frame = secondVideoView.bounds
    }

    @IBAction private func playButtonClicked(_ sender: UIButton) {
        switch playingState {
        case .some(.replay):
            player.seek(to: .zero) { (completed) in
                if completed {
                    self.playingState = .playing
                    self.handlePlayingStateControls()
                }
            }
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
        switch playRate {
        case .x8:
            playRate = .x
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
        case .x:
            playRate = .x2
            setFasterSlowerLabels(fasterLabel: "\(playRate.rawValue)x", slowerLabel: "")
        case .x2:
            playRate = .x4
            setFasterSlowerLabels(fasterLabel: "\(playRate.rawValue)x", slowerLabel: "")
        case .x4:
            playRate = .x8
            setFasterSlowerLabels(fasterLabel: "\(playRate.rawValue)x", slowerLabel: "")
        case .x0_75:
            playRate = .x
            // If you switch from slower rates to 1, I don't want to show default speed rate in player.
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
        case .x0_50:
            playRate = .x0_75
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "\(playRate.rawValue)")
            // 1 - x
        case .x0_25:
            playRate = .x0_50
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "\(playRate.rawValue)")
        }
        debugPrint("playRate=\(playRate)")
        handlePlayingStateControls()
    }
    
    @IBAction private func slowerButtonClicked(_ sender: UIButton) {
        resetTimer()
        switch playRate {
        case .x0_25:
            playRate = .x
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
        case .x:
            playRate = .x0_75
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "\(playRate.rawValue)")
        case .x0_75:
            playRate = .x0_50
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "\(playRate.rawValue)")
        case .x0_50:
            playRate = .x0_25
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "\(playRate.rawValue)")
        case .x2:
            playRate = .x
            setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
        case .x4:
            playRate = .x2
            setFasterSlowerLabels(fasterLabel: "\(playRate)", slowerLabel: "")
        case .x8:
            playRate = .x4
            setFasterSlowerLabels(fasterLabel: "\(playRate)", slowerLabel: "")
        }
        debugPrint("playRate=\(playRate)")
        handlePlayingStateControls()
    }
}

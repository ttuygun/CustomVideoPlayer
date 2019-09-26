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
    var secondPlayer: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var secondPlayerLayer: AVPlayerLayer!
    
    var timer: Timer?
    var seconds: Int = 0
    
    var playingState: PlayingState!
    
    let videoFPS: Float = 30.0
        
//    var firstModel: GolfVideoModel!
//    var secondModel: GolfVideoModel!
    
    var firstModel: GolfVideoFileModel!
    var secondModel: GolfVideoFileModel!
    
    // This variable keep track of first playing time to sync two videos.
    var firstPlaying = true
    
    // player.play()
    // secondPlayer.play()
    // In every pause/play tap, `player` go ahead of secondPlayer with increasing delay. This variable keep track of last played player.
    var firstVideoPlaying = false
    
    // Drawing variables
    var lastPoint: CGPoint = .zero
    var color: UIColor = .red
    var brushWidth: CGFloat = 5.0
    
    // Drawing outlets
    @IBOutlet weak var imageView: UIImageView!
    
    var drawings: [DrawingModel] = []
//    var drawing: DrawingModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resetTimer()
        initLayouts()
        initObservers()
        playingState = .readyToPlay
        setFasterSlowerLabels(fasterLabel: "", slowerLabel: "")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        lastPoint = touch.location(in: view)
        debugPrint("touchesBeganPoint=\(lastPoint)")
        
        let currentTime = player.currentTime()
        
        debugPrint("playerCurrentTime=\(currentTime)")
       
    
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        imageView.image?.draw(in: view.bounds)
        
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        
        context.setLineCap(.round)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)
        
        context.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let currentPoint = touch.location(in: view)
        drawLine(from: lastPoint, to: currentPoint)
        
        let drawing = DrawingModel(startPoint: lastPoint, endPoint: currentPoint, second: player.currentTime().seconds)
        drawings.append(drawing)
        
        lastPoint = currentPoint
        debugPrint("touchesMovedPoint=\(lastPoint)")
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("touchesEnded")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMirror" {
            let destionation = segue.destination as! MirrorViewController
            destionation.reDrawings = drawings
        }
    }
    
    private func initLayouts() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.videoPlayerDidClicked))
        let secondTap = UITapGestureRecognizer(target: self, action: #selector(self.videoPlayerDidClicked))
        
        videoView.addGestureRecognizer(tap)
        secondVideoView.addGestureRecognizer(secondTap)
        
        guard let said = Bundle.main.path(forResource: "said", ofType:"mp4") else {
            return
        }
        
        guard let yigit = Bundle.main.path(forResource: "yigit", ofType:"mp4") else {
            return
        }
        
        firstModel = GolfVideoFileModel(urlString: yigit,
                                    shotFrame: 94.0)
        
        secondModel = GolfVideoFileModel(urlString: said,
                                     shotFrame: 90.0)
        
//        firstModel = GolfVideoModel(urlString: "https://da6h2esi5ewzl.cloudfront.net/317/20190807_145043223_%2B0300/20190807_145043223_%2B0300.mp4",
//                                        shotFrame: 94.0)
//
//        secondModel = GolfVideoModel(urlString: "https://da6h2esi5ewzl.cloudfront.net/317/20190725_162542_%2B0300/20190725_162542_%2B0300.mp4",
//                                         shotFrame: 90.0)
        
        player = AVPlayer(url: secondModel.url)
        secondPlayer = AVPlayer(url: firstModel.url)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        secondPlayerLayer = AVPlayerLayer(player: secondPlayer)
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
    
    private func syncTwoVideos() {
        if firstModel.shotFrame > secondModel.shotFrame {
            // 1 2  3x 4 5 6
            // 1 2x 3  4 5 6
            let diff = CMTime(seconds: firstModel.shotFrame - secondModel.shotFrame,
                              preferredTimescale: Int32(videoFPS))
            
            player.playImmediately(atRate: self.playRate.rawValue)
            secondPlayer.pause()
            
            secondPlayer.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: diff) { (completed) in
                if completed {
                    self.secondPlayer.playImmediately(atRate: self.playRate.rawValue)
                }
            }
        } else if secondModel.shotFrame > firstModel.shotFrame {
            // 1 2x 3  4 5 6
            // 1 2  3x 4 5 6
            let diff = CMTime(seconds: secondModel.shotFrame - firstModel.shotFrame,
                              preferredTimescale: Int32(videoFPS))
            
            secondPlayer.playImmediately(atRate: self.playRate.rawValue)
            player.pause()
            
            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: diff) { (completed) in
                if completed {
                    self.player.playImmediately(atRate: self.playRate.rawValue)
                }
            }
        } else if firstModel.shotFrame == secondModel.shotFrame {
            player.playImmediately(atRate: self.playRate.rawValue)
            secondPlayer.playImmediately(atRate: self.playRate.rawValue)
        }
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
            // I assume that first video's duration is smaller than second one.
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
        })
    }
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        resetTimer()
        player.seek(to: CMTimeMake(value: Int64(sender.value * videoFPS), timescale: Int32(videoFPS)))
        secondPlayer.seek(to: CMTimeMake(value: Int64(sender.value * videoFPS), timescale: Int32(videoFPS)))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration))
    }
    
    @objc private func playerDidPlayToEndTime() {
        self.playingState = .replay
        self.handlePlayingStateControls()
        // I paused the second player.
        self.secondPlayer.pause()
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
            if firstPlaying {
                syncTwoVideos()
                firstPlaying = false
            } else {
                if firstVideoPlaying {
                    secondPlayer.playImmediately(atRate: playRate.rawValue)
                    player.playImmediately(atRate: playRate.rawValue)
                } else {
                    player.playImmediately(atRate: playRate.rawValue)
                    secondPlayer.playImmediately(atRate: playRate.rawValue)
                }
                firstVideoPlaying = !firstVideoPlaying
            }
            playerBottomView.isHidden = false
            playPauseButton.setImage(pauseImage, for: .normal)
            bottomPlayPauseButton.setImage(pauseImage, for: .normal)
            resetTimer()
        case .some(.paused):
            player.pause()
            secondPlayer.pause()
            playPauseButton.setImage(playImage, for: .normal)
            bottomPlayPauseButton.setImage(playImage, for: .normal)
            timer?.invalidate()
        case .some(.replay):
            playerBottomView.isHidden = true
            playPauseButton.isHidden = false
            playerBottomView.isHidden = false
            playPauseButton.setImage(replayImage, for: .normal)
            resetTimer()
//            timer?.invalidate()
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
//        debugPrint(seconds)
        if seconds > 2 {
            if playingState == .init(.playing) {
                self.willHidePlayPauseButtonAndBottomView(state: true)
                timer?.invalidate()
            } else if playingState == .init(.readyToPlay) {
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
    }

    @IBAction private func muteButtonClicked(_ sender: UIButton) {
        let soundImage = UIImage(named: "sound")
        let muteImage = UIImage(named: "mute")
        
        sender.setImage(player.isMuted ? soundImage: muteImage, for: .normal)
        player.isMuted = !player.isMuted
        secondPlayer.isMuted = !secondPlayer.isMuted
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

//
//  MirrorViewController.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 25.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import UIKit

class MirrorViewController: CustomVideoViewController {

//    var drawings: [DrawingModel] = []
//
//    @IBOutlet weak var imageView: UIImageView!
//
//    var color: UIColor = .red
//    var brushWidth: CGFloat = 5.0
//
    var buttonPlayingState = true
//
//    var timer: Timer?
    
    var second: Double = 0
    var lastDrawIndex = 0
    
    var reDrawings: [DrawingModel] = []
    
    let semaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        startDrawing()
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func startDrawing() {
        
        for drawing in reDrawings {
            DispatchQueue.main.asyncAfter(deadline: .now() + drawing.second) {
                self.drawLine(from: drawing.startPoint, to: drawing.endPoint)
                debugPrint(self.lastDrawIndex)
            }
            
            DispatchQueue.main.async {
                
             
            }
            
        }
        
        debugPrint("drawings Count = \(drawings.count)")
        
//        for drawing in drawings {
//            DispatchQueue.main.asyncAfter(deadline: .now() + drawing.second) {
//                if self.playingState {
//                    self.drawLine(from: drawing.startPoint, to: drawing.endPoint)
//                } else {
//                    // pause
//                }
//            }
//        }
        
//        while lastDrawIndex < drawings.count  {
//            DispatchQueue.main.asyncAfter(wallDeadline: .now() + self.drawings[lastDrawIndex].second) {
//                if self.playingState {
//                    self.drawLine(from: self.drawings[self.lastDrawIndex].startPoint, to: self.drawings[self.lastDrawIndex].endPoint)
//                    debugPrint(self.lastDrawIndex)
//                }
//            }
//        }
        
    }
    @IBAction func secondPlayButtonClicked(_ sender: UIButton) {
        let playImage = UIImage(named: "play")
        let pauseImage = UIImage(named: "pause")
        sender.setImage(buttonPlayingState ? playImage : pauseImage, for: .normal)
        

        buttonPlayingState = !buttonPlayingState

      
        if self.buttonPlayingState {
            DispatchQueue.main.async {
                self.semaphore.signal()
            }
        } else {
            DispatchQueue.main.async {
                self.semaphore.wait()
            }
        }
        
        
//        DispatchQueue.main.async {
//            print("Kid 1 - wait")
//            self.semaphore.wait()
//            print("Kid 1 - wait finished")
//            sleep(1) // Kid 1 playing with iPad
//            self.semaphore.signal()
//            print("Kid 1 - done with iPad")
//        }
//        DispatchQueue.main.async {
//            print("Kid 2 - wait")
//            self.semaphore.wait()
//            print("Kid 2 - wait finished")
//            sleep(1) // Kid 1 playing with iPad
//            self.semaphore.signal()
//            print("Kid 2 - done with iPad")
//        }
//
//        DispatchQueue.main.async {
//            print("Kid 3 - wait")
//            self.semaphore.wait()
//            print("Kid 3 - wait finished")
//            sleep(1) // Kid 1 playing with iPad
//            self.semaphore.signal()
//            print("Kid 3 - done with iPad")
//        }
//        
    }
    

//    @IBAction func playButtonClicked(_ sender: UIButton) {
//        let playImage = UIImage(named: "play")
//        let pauseImage = UIImage(named: "pause")
//        sender.setImage(playingState ? playImage : pauseImage, for: .normal)
//        playingState = !playingState
//        
//        if !playingState {
//            // pause
//            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
//            
//        } else {
//            // play
//            second = 0
//            timer?.invalidate()
//        }
//        
//        startDrawing()
//    }
//    
//    @objc private func runTimedCode() {
//        second += 1
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

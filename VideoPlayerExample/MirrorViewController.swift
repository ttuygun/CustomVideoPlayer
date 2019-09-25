//
//  MirrorViewController.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 25.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import UIKit

class MirrorViewController: UIViewController {

    var drawings: [DrawingModel] = []
    
    @IBOutlet weak var imageView: UIImageView!
    
    var color: UIColor = .red
    var brushWidth: CGFloat = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        startDrawing()
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func startDrawing() {
        for drawing in drawings {
            DispatchQueue.main.asyncAfter(deadline: .now() + drawing.second) {
                self.drawLine(from: drawing.startPoint, to: drawing.endPoint)
            }
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

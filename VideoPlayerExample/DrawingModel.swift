//
//  DrawingModel.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 25.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

struct DrawingModel {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let second: Double
    
    init(startPoint: CGPoint, endPoint: CGPoint, second: Double) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.second = second
    }
}

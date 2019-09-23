//
//  VideoPlayerEnums.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 23.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import Foundation

enum PlayingState: String {
    case readyToPlay = "readyToPlay"
    case playing = "playing"
    case paused = "paused"
    case replay = "replay"
}

enum PlayRate: Float {
    case x8 = 8.0
    case x4 = 4.0
    case x2 = 2.0
    case x = 1.0
    case x0_25 = 0.25
    case x0_50 = 0.50
    case x0_75 = 0.75
}

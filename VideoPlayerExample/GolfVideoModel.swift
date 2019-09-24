//
//  GolfVideoModel.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 24.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import Foundation

struct GolfVideoModel {
    let url: URL
    let shotFrame: Double
    
    init(urlString: String, shotFrame: Double) {
        self.url = URL(string: urlString)!
        self.shotFrame = shotFrame
    }
}

struct GolfVideoFileModel {
    let url: URL
    let shotFrame: Double
    
    init(urlString: String, shotFrame: Double) {
        self.url = URL(fileURLWithPath: urlString)
        self.shotFrame = shotFrame
    }
}

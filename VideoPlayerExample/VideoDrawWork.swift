//
//  VideoDrawWork.swift
//  VideoPlayerExample
//
//  Created by rapsodo-mobil-5 on 30.09.2019.
//  Copyright © 2019 rapsodo-mobil-5. All rights reserved.
//

import Foundation

public class VideoDrawWork {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    
    public init(delay: TimeInterval) {
        self.delay = delay
    }
    
    public func cancel() {
        workItem?.cancel()
    }
    
    /// Trigger the action after some delay
    public func run(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: action)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
}

//
//  Await.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

public func await<T>(timeout: DispatchTime = .distantFuture,
                     _ builder: (@escaping (T) -> Void) -> Void) -> T {
    var value: T?
    let semaphore = DispatchSemaphore(value: 0)
    let signal: (T) -> Void = {
        value = $0
        semaphore.signal()
    }
    builder(signal)
    if semaphore.wait(timeout: timeout) == .timedOut {
        fatalError("Timeout is not processed yet. Should be Result error.")
    }
    return value!
}


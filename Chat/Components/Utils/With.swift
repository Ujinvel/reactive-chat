//
//  With.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

@discardableResult
public func with<T>(_ value: T,
                    _ builder: (inout T) throws -> Void) rethrows -> T {
    var mutableValue = value
    try builder(&mutableValue)
    return mutableValue
}

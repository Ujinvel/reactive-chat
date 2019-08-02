//
//  WeakBox.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

public struct WeakBox<T: AnyObject> {
    public private(set) weak var value: T?
    public init(value: T) {
        self.value = value
    }
}

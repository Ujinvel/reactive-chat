//
//  Makable.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

public protocol Makeable: class {
    associatedtype Product: AnyObject = Self
    typealias Builder = (inout Product) -> Void
    
    static func make() -> Product
}

extension Makeable {
    public static func make(_ builder: Builder) -> Product {
        var product = make()
        builder(&product)
        return product
    }
}

//
//  Queryable.swift
//  Predicate
//
//  Created by Ihor Teltov on 5/14/18.
//  Copyright © 2018 Cleveroad Inc. All rights reserved.
//

import Foundation

public protocol Queryable {
    associatedtype Object: ObjectAttributeType
}

public extension Queryable {
    static var attributes: Object { return Object() }
}

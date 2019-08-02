//
//  Attribute.swift
//  Predicate
//
//  Created by Ihor Teltov on 5/14/18.
//  Copyright © 2018 Cleveroad Inc. All rights reserved.
//

import Foundation

public struct Attribute<T>: ExpressionConvertible {
    public let expression: Expression<T>
    public let keyPath: String
    
    internal init(keyPath: String) {
        self.keyPath = keyPath
        self.expression = Expression(keyPath: keyPath)
    }
    internal init(expression: Expression<T>) {
        self.expression = expression
        let nsExpression = expression.nsExpression
        self.keyPath = nsExpression.expressionType == .keyPath ? nsExpression.keyPath : ""
    }
}

public extension Attribute {
    public var ascending: SortDescriptor {
        return SortDescriptor(keyPath: keyPath, ascending: true)
    }
    public var descending: SortDescriptor {
        return SortDescriptor(keyPath: keyPath, ascending: false)
    }
}

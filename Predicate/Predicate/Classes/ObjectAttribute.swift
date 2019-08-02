//
//  ObjectAttribute.swift
//  Predicate
//
//  Created by Ihor Teltov on 5/22/18.
//

import Foundation

public protocol ObjectAttributeType: ExpressionConvertible {
    init(expression: Expression<Value>)
}

public extension ObjectAttributeType {
    public func value<T>(for keyPath: String) -> Attribute<T> {
        return Attribute(expression: expression.adding(keyPath: Expression(keyPath: keyPath)))
    }
    
    public func object<T: ObjectAttributeType>(for keyPath: String) -> T {
        return T(expression: expression.adding(keyPath: Expression(keyPath: keyPath)))
    }
    
    public func collection<T>(for keyPath: String) -> CollectionAttribute<T> {
        return CollectionAttribute(expression: expression.adding(keyPath: Expression(keyPath: keyPath)))
    }

    internal init(keyPath: String? = nil) {
        self.init(expression: Expression(keyPath: keyPath ?? ""))
    }
    internal init(variable: String) {
        self.init(expression: Expression(variable: variable))
    }
}

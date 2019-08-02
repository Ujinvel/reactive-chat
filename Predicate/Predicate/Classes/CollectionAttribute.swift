//
//  CollectionAttribute.swift
//  Predicate
//
//  Created by Ihor Teltov on 5/14/18.
//  Copyright © 2018 Cleveroad Inc. All rights reserved.
//

import Foundation

public protocol CollectionExpression: ExpressionConvertible {
}

public struct CollectionAttribute<T>: CollectionExpression {
    public let expression: Expression<T>
    
    internal init(expression: Expression<T>) {
        self.expression = expression
    }
}

public extension CollectionExpression where Value: Queryable {
    public func any<T>(_ attribute: (Value.Object) -> Attribute<T>) -> Expression<T> {
        return predicate(attribute).any
    }
    public func all<T>(_ attribute: (Value.Object) -> Attribute<T>) -> Expression<T> {
        return predicate(attribute).all
    }
    private func predicate<T>(_ attribute: (Value.Object) -> Attribute<T>) -> Expression<T> {
        return expression.adding(keyPath: attribute(Value.attributes).expression)
    }
    
    public func subquery(_ query: Predicate<Value>.ObjectBuilder) -> SubqueryExpression<Value> {
        return SubqueryExpression(expression: expression,
                                  predicate: query(Value.Object(variable: "item")))
    }
}

public extension CollectionExpression where Value: Comparable {
    public func any() -> Expression<Value> {
        return expression.any
    }
    public func all() -> Expression<Value> {
        return expression.all
    }
}

public extension CollectionExpression {
    ///returns the number of objects in a collection
    public func count() -> Expression<Int64> {
        return expression.adding(keyPath: Expression(expression: NSExpression(forKeyPath: "@count")))
    }
}

public extension CollectionAttribute where Value: Numeric {
    public func average() -> Expression<Double> {
        return expression.adding(keyPath: Expression(expression: NSExpression(forKeyPath: "@avg.doubleValue")))
    }
}

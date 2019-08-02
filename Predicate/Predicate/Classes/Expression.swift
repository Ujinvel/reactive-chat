//
//  Expression.swift
//  Predicate
//
//  Created by Ihor Teltov on 5/14/18.
//  Copyright © 2018 Cleveroad Inc. All rights reserved.
//

import Foundation

public protocol ExpressionConvertible {
    associatedtype Value
    var expression: Expression<Value> { get }
}

public struct Expression<T>: ExpressionConvertible {
    public var expression: Expression<T> {
        return self
    }
    // MARK: - Internal
    internal let nsExpression: NSExpression
    internal let modifier: NSComparisonPredicate.Modifier
    internal let options: NSComparisonPredicate.Options
    internal init(value: T) {
        self.init(expression: NSExpression(value: value),
                  modifier: .direct,
                  options: [])
    }
    internal init(sequence: [T]) {
        self.init(expression: NSExpression(forConstantValue: sequence),
                  modifier: .direct,
                  options: [])
    }
    internal init(keyPath: String) {
        self.init(expression: NSExpression(forKeyPath: keyPath),
                  modifier: .direct,
                  options: [])
    }
    internal init(variable: String) {
        self.init(expression: NSExpression(forVariable: variable),
                  modifier: .direct,
                  options: [])
    }
    internal init(expression: NSExpression,
                  modifier: NSComparisonPredicate.Modifier = .direct,
                  options: NSComparisonPredicate.Options = []) {
        self.nsExpression = expression
        self.modifier = modifier
        self.options = options
    }
}

extension Expression {
    internal func mergeOptions(_ options: NSComparisonPredicate.Options) -> NSComparisonPredicate.Options {
        return self.options.union(options)
    }
    internal var all: Expression {
        return Expression(expression: nsExpression, modifier: .all, options: options)
    }
    internal var any: Expression {
        return Expression(expression: nsExpression, modifier: .any, options: options)
    }
    internal func adding<Value>(keyPath expression: Expression<Value>) -> Expression<Value> {
        if nsExpression.expressionType == .keyPath && nsExpression.keyPath.isEmpty {
            return expression
        }
        return Expression<Value>(expression: NSExpression(format: "%@.%@",
                                                          nsExpression,
                                                          expression.nsExpression))
    }
}

extension ExpressionConvertible where Value: WrappedType {
    public func contained<S: Sequence, P>(in sequence: S) -> Predicate<P>
        where Value.WrappedValue == S.Element {
            return Predicate(self,
                             Expression(sequence: Array(sequence)),
                             operator: .in)
    }
}

public extension ExpressionConvertible
where Value: WrappedType {
    public func between<P>(_ range: ClosedRange<Value.WrappedValue>) -> Predicate<P> {
        return Predicate(self,
                         Expression(sequence: [range.lowerBound, range.upperBound]),
                         operator: .between)
    }
}

public extension ExpressionConvertible
where Value: WrappedType, Value.WrappedValue: SignedInteger {
    public func between<P, I: SignedInteger>(_ range: ClosedRange<I>) -> Predicate<P> {
        return Predicate(self,
                         Expression(sequence: [range.lowerBound, range.upperBound]),
                         operator: .between)
    }
}

// MARK: - String expression specialization
public extension ExpressionConvertible
where Value: WrappedType, Value.WrappedValue == String {
    public var caseInsensitive: Expression<Value> {
        return Expression(expression: expression.nsExpression,
                          modifier: expression.modifier,
                          options: expression.mergeOptions(.caseInsensitive))
    }
    
    public var diacriticInsensitive: Expression<Value> {
        return Expression(expression: expression.nsExpression,
                          modifier: expression.modifier,
                          options: expression.mergeOptions(.diacriticInsensitive))
    }
    
    public var normalized: Expression<Value> {
        return Expression(expression: expression.nsExpression,
                          modifier: expression.modifier,
                          options: .normalized)
    }
    
    /// Left hand expression begins with the right hand expression
    public func begins<P>(with string: String) -> Predicate<P> {
        return Predicate(Expression<Value.WrappedValue>(expression: expression.nsExpression,
                                                        modifier: expression.modifier,
                                                        options: expression.options),
                         Expression(value: string),
                         operator: .beginsWith)
    }
    
    /// Left hand expression ends with the right hand expression
    public func ends<P>(with string: String) -> Predicate<P> {
        return Predicate(Expression<Value.WrappedValue>(expression: expression.nsExpression,
                                                        modifier: expression.modifier,
                                                        options: expression.options),
                         Expression(value: string),
                         operator: .endsWith)
    }
    
    /// Left hand expression contains the right hand expression
    public func contains<P>(options: NSComparisonPredicate.Options = [], _ string: String) -> Predicate<P> {
        return Predicate(Expression<Value.WrappedValue>(expression: expression.nsExpression,
                                                        modifier: expression.modifier,
                                                        options: options.isEmpty ? expression.options : options),
                         Expression(value: string),
                         operator: .contains)
    }
    
    /// Left hand expression equals the right hand expression: ? and * are allowed as wildcard characters, where ? matches 1 character and * matches 0 or more characters
    public func like<P>(_ pattern: String) -> Predicate<P> {
        return Predicate(Expression<Value.WrappedValue>(expression: expression.nsExpression,
                                                        modifier: expression.modifier,
                                                        options: expression.options),
                         Expression(value: pattern),
                         operator: .like)
    }
    
    /// Left hand expression equals the right hand expression using a regex - style comparison
    public func matches<P>(_ pattern: String) -> Predicate<P> {
        return Predicate(Expression<Value.WrappedValue>(expression: expression.nsExpression,
                                                        modifier: expression.modifier,
                                                        options: expression.options),
                         Expression(value: pattern),
                         operator: .matches)
    }
}

// MARK: - Bool expression specialization
public extension ExpressionConvertible
where Value: WrappedType, Value.WrappedValue == Bool {
    public static prefix func !<P>(expression: Self) -> Predicate<P> {
        return expression == Expression<Bool>(expression: NSExpression(forConstantValue: false))
    }
}

public func == <T: ExpressionConvertible, P>(lhs: T, rhs: T.Value) -> Predicate<P>
    where T.Value: WrappedType, T.Value.WrappedValue: Equatable {
        return lhs == Expression(value: rhs)
}

public func != <T: ExpressionConvertible, P>(lhs: T, rhs: T.Value) -> Predicate<P>
    where T.Value: WrappedType, T.Value.WrappedValue: Equatable {
        return lhs != Expression(value: rhs)
}

public func > <T: ExpressionConvertible, P>(lhs: T, rhs: T.Value) -> Predicate<P>
    where T.Value: WrappedType, T.Value.WrappedValue: Comparable {
        return lhs > Expression(value: rhs)
}

public func >= <T: ExpressionConvertible, P>(lhs: T, rhs: T.Value) -> Predicate<P>
    where T.Value: WrappedType, T.Value.WrappedValue: Comparable {
        return lhs >= Expression(value: rhs)
}

public func < <T: ExpressionConvertible, P>(lhs: T, rhs: T.Value) -> Predicate<P>
    where T.Value: WrappedType, T.Value.WrappedValue: Comparable {
        return lhs < Expression(value: rhs)
}

public func <= <T: ExpressionConvertible, P>(lhs: T, rhs: T.Value) -> Predicate<P>
    where T.Value: WrappedType, T.Value.WrappedValue: Comparable {
        return lhs <= Expression(value: rhs)
}

public func == <T: ExpressionConvertible, K: ExpressionConvertible, P>
    (lhs: T, rhs: K) -> Predicate<P>
    where
    T.Value: WrappedType, K.Value: WrappedType,
    T.Value.WrappedValue == K.Value.WrappedValue,
    T.Value.WrappedValue: Equatable {
        return Predicate(lhs, rhs, operator: .equalTo)
}

public func != <T: ExpressionConvertible, K: ExpressionConvertible, P>
    (lhs: T, rhs: K) -> Predicate<P>
    where
    T.Value: WrappedType, K.Value: WrappedType,
    T.Value.WrappedValue == K.Value.WrappedValue,
    T.Value.WrappedValue: Equatable {
        return Predicate(lhs, rhs, operator: .notEqualTo)
}

public func > <T: ExpressionConvertible, K: ExpressionConvertible, P>
    (lhs: T, rhs: K) -> Predicate<P>
    where
    T.Value: WrappedType, K.Value: WrappedType,
    T.Value.WrappedValue == K.Value.WrappedValue,
    T.Value.WrappedValue: Comparable {
        return Predicate(lhs, rhs, operator: .greaterThan)
}

public func >= <T: ExpressionConvertible, K: ExpressionConvertible, P>
    (lhs: T, rhs: K) -> Predicate<P>
    where
    T.Value: WrappedType, K.Value: WrappedType,
    T.Value.WrappedValue == K.Value.WrappedValue,
    T.Value.WrappedValue: Comparable {
        return Predicate(lhs, rhs, operator: .greaterThanOrEqualTo)
}

public func < <T: ExpressionConvertible, K: ExpressionConvertible, P>
    (lhs: T, rhs: K) -> Predicate<P>
    where
    T.Value: WrappedType, K.Value: WrappedType,
    T.Value.WrappedValue == K.Value.WrappedValue,
    T.Value.WrappedValue: Comparable {
        return Predicate(lhs, rhs, operator: .lessThan)
}

public func <= <T: ExpressionConvertible, K: ExpressionConvertible, P>
    (lhs: T, rhs: K) -> Predicate<P>
    where
    T.Value: WrappedType, K.Value: WrappedType,
    T.Value.WrappedValue == K.Value.WrappedValue,
    T.Value.WrappedValue: Comparable {
        return Predicate(lhs, rhs, operator: .lessThanOrEqualTo)
}

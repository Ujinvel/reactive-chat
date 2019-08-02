//
//  Predicate.swift
//  Predicate
//
//  Created by Ihor Teltov on 5/14/18.
//  Copyright © 2018 Cleveroad Inc. All rights reserved.
//

import Foundation

public struct Predicate<T> {
    public let predicate: NSPredicate
    
    public func and(_ predicate: Predicate) -> Predicate {
        return Predicate(predicate:
            NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate,
                                                                predicate.predicate]))
    }
    
    public func or(_ predicate: Predicate) -> Predicate {
        return Predicate(predicate:
            NSCompoundPredicate(orPredicateWithSubpredicates: [self.predicate,
                                                               predicate.predicate]))
    }
    
    public func negate() -> Predicate {
        return !self
    }
    
    internal init(predicate: NSPredicate) {
        self.predicate = predicate
    }
}

extension Predicate where T: Queryable {
    public typealias ObjectBuilder = (T.Object) -> Predicate<T>
    public init(_ builder: ObjectBuilder) {
        self = builder(T.Object())
    }
    public func and(_ builder: ObjectBuilder) -> Predicate {
        return and(Predicate(builder))
    }
    public func or(_ builder: ObjectBuilder) -> Predicate {
        return or(Predicate(builder))
    }
}

extension Predicate where T: WrappedType {
    public typealias AttributeBuilder = (Attribute<T>) -> Predicate<T>
    public init(_ builder: AttributeBuilder) {
        self = builder(Attribute(expression: Expression(expression: NSExpression(format: "SELF"))))
    }
    public func and(_ builder: AttributeBuilder) -> Predicate {
        return and(Predicate(builder))
    }
    public func or(_ builder: AttributeBuilder) -> Predicate {
        return or(Predicate(builder))
    }
}

public extension Predicate {
    public static func &&(_ lhs: Predicate, rhs: Predicate) -> Predicate {
        return Predicate(predicate:
            NSCompoundPredicate(andPredicateWithSubpredicates: [lhs.predicate, rhs.predicate]))
    }
    
    public static func ||(_ lhs: Predicate, rhs: Predicate) -> Predicate {
        return Predicate(predicate:
            NSCompoundPredicate(orPredicateWithSubpredicates: [lhs.predicate, rhs.predicate]))
    }
    
    public static prefix func !(predicate: Predicate) -> Predicate {
        return Predicate(predicate:
            NSCompoundPredicate(notPredicateWithSubpredicate: predicate.predicate))
    }
}

extension Predicate {
    init<
        T: ExpressionConvertible,
        K: ExpressionConvertible
        >(
        _ lhs: T,
        _ rhs: K,
        operator type: NSComparisonPredicate.Operator
        )
    {
        let predicate =
            NSComparisonPredicate(leftExpression: lhs.expression.nsExpression,
                                  rightExpression: rhs.expression.nsExpression,
                                  modifier: lhs.expression.modifier,
                                  type: type,
                                  options: lhs.expression.mergeOptions(rhs.expression.options))
        self.init(predicate: predicate)
    }
}

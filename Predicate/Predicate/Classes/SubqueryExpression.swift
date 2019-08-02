//
//  SubqueryExpression.swift
//  Predicate
//
//  Created by Ihor Teltov on 5/25/18.
//

import Foundation

public struct SubqueryExpression<T: Queryable>: CollectionExpression {
    public let expression: Expression<T>
    
    internal init(expression: Expression<T>, predicate: Predicate<T>) {
        let nsExpression = NSExpression(forSubquery: expression.nsExpression,
                                        usingIteratorVariable: "item",
                                        predicate: predicate.predicate)
        self.expression = Expression(expression: nsExpression)
    }
}

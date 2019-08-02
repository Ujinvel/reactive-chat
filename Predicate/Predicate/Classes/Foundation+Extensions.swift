//
//  Foundation+Extensions.swift
//  Predicate
//
//  Created by Ihor Teltov on 5/25/18.
//

import Foundation

extension NSExpression {
    convenience init(value: Any?) {
        self.init(forConstantValue: value)
    }
}


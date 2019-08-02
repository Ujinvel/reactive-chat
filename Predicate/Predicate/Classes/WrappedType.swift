//
//  WrappedType.swift
//  Predicate
//
//  Created by Ihor Teltov on 5/30/18.
//

import Foundation

public protocol WrappedType {
    associatedtype WrappedValue = Self
}
extension Optional: WrappedType {
    public typealias WrappedValue = Wrapped
}

extension Bool: WrappedType {}
extension String: WrappedType {}
extension Character: WrappedType {}
extension Int: WrappedType {}
extension Int8: WrappedType {}
extension Int16: WrappedType {}
extension Int32: WrappedType {}
extension Int64: WrappedType {}
extension UInt: WrappedType {}
extension UInt8: WrappedType {}
extension UInt16: WrappedType {}
extension UInt32: WrappedType {}
extension UInt64: WrappedType {}
extension Float: WrappedType {}
extension Double: WrappedType {}
extension Date: WrappedType {}
extension Data: WrappedType {}

extension NSData: WrappedType {}
extension NSDate: WrappedType {}
extension NSNumber: WrappedType {}
extension NSString: WrappedType {}


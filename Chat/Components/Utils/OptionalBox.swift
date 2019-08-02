//
//  OptionalBox.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

enum OptionalBoxError: Error {
    case missingValue(type: Any)
}

/// OptionalBox provides a way to determine if value is absent by intent. Use `none` case when you cannot provide actual value.
public enum OptionalBox<Value> {
    case some(Value)
    case null
    case none
    
    func definedValue() throws -> Value? {
        switch self {
        case .some(let value):
            return value
        case .null:
            return nil
        case .none:
            throw OptionalBoxError.missingValue(type: Value.self)
        }
    }
    
    public var value: Value? {
        if case .some(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
    public var hasValue: Bool {
        if case .none = self {
            return false
        } else {
            return true
        }
    }
    
    public init(_ value: Value?) {
        if let value = value {
            self = .some(value)
        } else {
            self = .null
        }
    }
}

extension OptionalBox: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        do {
            try self = .some(Value(from: decoder))
        } catch DecodingError.valueNotFound {
            self = .null
        }
    }
}

extension OptionalBox: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .none:
            break
        default:
            try value.encode(to: encoder)
        }
    }
}

extension KeyedDecodingContainer {
    public func decode<T>(_ type: OptionalBox<T>.Type,
                          forKey key: K) throws -> OptionalBox<T>
        where T: Decodable {
            return try decodeIfPresent(OptionalBox<T>.self, forKey: key) ?? .none
    }
}

extension OptionalBox: Equatable where Value: Equatable {
    public static func == (lhs: OptionalBox, rhs: OptionalBox) -> Bool {
        switch (lhs, rhs) {
        case (.some(let value1), .some(let value2)):
            return value1 == value2
        case (.null, .null):
            return true
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}

//
//  Identifiable
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

public struct Token<Parent, Value: Codable & Hashable>: RawRepresentable, Codable, Hashable {
    public let rawValue: Value
    
    public init(rawValue: Value) {
        self.rawValue = rawValue
    }
    
    public init(from decoder: Decoder) throws {
        self.rawValue = try Value(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

extension Token: ExpressibleByIntegerLiteral where Value == Int64 {
    public typealias IntegerLiteralType = Value
    
    public init(integerLiteral value: Value) {
        self.init(rawValue: value)
    }
}

public protocol Identifiable {
    associatedtype Identifier: Codable & Hashable = Int64
    typealias ID = Token<Self, Identifier>
    
    var id: ID { get }
}


//
//  Mapper.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import RealmSwift

enum MapperError: Error {
    case valueRequired(type: Any)
}

struct Mapper {
    let realm: Realm
    public init(realm: Realm) {
        self.realm = realm
    }
    
    public func wrap<T>(_ value: T?) -> OptionalBox<T> {
        return OptionalBox(value)
    }
    
    public func unwrap<T>(_ box: OptionalBox<T>) throws -> T? {
        switch box {
        case .some(let value):
            return value
        case .null:
            return nil
        case .none:
            throw MapperError.valueRequired(type: T.self)
        }
    }
    
    public func unwrap<T>(_ transform: @autoclosure () throws -> T?) throws -> T {
        guard let value = try transform() else {
            throw MapperError.valueRequired(type: T.self)
        }
        return value
    }
}

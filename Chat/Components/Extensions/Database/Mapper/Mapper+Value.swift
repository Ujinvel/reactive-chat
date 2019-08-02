//
//  Mapper+Value.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import RealmSwift

extension Mapper {
    func value<P: Persistable>(from object: P.ManagedObject?) throws -> P
        where P.Context == Mapper
    {
        return try P(from: unwrap(object), context: self)
    }
    
    func value<P: Persistable>(from object: P.ManagedObject?) throws -> OptionalBox<P>
        where P.Context == Mapper
    {
        return OptionalBox(try? P(from: unwrap(object), context: self))
    }
    
    func values<P: Persistable>(from objects: List<P.ManagedObject>) throws -> [P]
        where P.Context == Mapper
    {
        return try objects.map { try P(from: $0, context: self) }
    }
}

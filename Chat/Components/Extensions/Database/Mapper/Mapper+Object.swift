//
//  Mapper+Object.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import RealmSwift

extension Mapper {
    @discardableResult
    func object<P: Persistable>(from value: P) throws -> P.ManagedObject
        where P.ManagedObject: Object, P.Context == Mapper
    {
        let managedObject = realm.fetchOrCreate(P.ManagedObject.self, forPrimaryKey: value.primaryKey)
        try value.update(managedObject, context: self)
        return managedObject
    }
    
    @discardableResult
    func objects<P: Persistable>(from values: [P]) throws -> [P.ManagedObject]
        where P.ManagedObject: Object, P.Context == Mapper
    {
        return try values.map {
            let object = realm.fetchOrCreate(P.ManagedObject.self, forPrimaryKey: $0.primaryKey)
            try $0.update(object, context: self)
            return object
        }
    }
}

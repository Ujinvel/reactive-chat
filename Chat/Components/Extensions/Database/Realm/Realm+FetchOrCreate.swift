//
//  Realm+FetchOrCreate.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import RealmSwift

extension Realm {
    func objectsForPrimaryKeys<T: Object>(type: T.Type, keys: [Any]) -> Results<T> {
        guard let primaryKey = T.primaryKey() else {
            return objects(type)
        }
        return objects(type).filter("\(primaryKey) IN %@", keys)
    }
    
    func fetchOrCreate<T: Object, Key>(_ type: T.Type, forPrimaryKey key: Key? = nil) -> T {
        guard let primaryKey = T.primaryKey(), let key = key else {
            return T()
        }
        return create(type, value: [primaryKey: key], update: true)
    }
    
    @discardableResult
    func fetchOrCreate<T: Persistable>(from object: T, context: T.Context) throws -> T.ManagedObject where T.ManagedObject: Object {
        let managedObject = fetchOrCreate(T.ManagedObject.self, forPrimaryKey: object.primaryKey)
        try object.update(managedObject, context: context)
        return managedObject
    }
    
    @discardableResult
    func fetchOrCreate<T: Persistable>(from objects: [T], context: T.Context) throws -> [T.ManagedObject] where T.ManagedObject: Object {
        return try objects.map {
            let object = fetchOrCreate(T.ManagedObject.self, forPrimaryKey: $0.primaryKey)
            try $0.update(object, context: context)
            return object
        }
    }
}

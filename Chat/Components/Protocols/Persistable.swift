//
//  PersistableEntitie.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

protocol Persistable {
    associatedtype ManagedObject
    associatedtype Context
    
    var primaryKey: Any? { get }
    var localId: String { get }
    
    init(from object: ManagedObject, context: Context) throws
    
    func update(_ object: ManagedObject, context: Context) throws
}

extension Persistable {
    var primaryKey: Any? { return localId }
}

extension Persistable where Context == Void {
    init(from object: ManagedObject) throws {
        try self.init(from: object, context: ())
    }
    
    func update(_ object: ManagedObject) throws {
        try update(object, context: ())
    }
}

protocol PersistableCollection {
    associatedtype Item: Persistable
    var items: [Item] { get }
}

extension Array: PersistableCollection where Element: Persistable {
    typealias Item = Element
    var items: [Item] { return self }
}


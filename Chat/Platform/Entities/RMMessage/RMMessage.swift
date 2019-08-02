//
//  RMMessage.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import RealmSwift
import Predicate

@objcMembers
final class RMMessage: Object, DateteIdentifiable, AutoQueryable {
    dynamic var localId: String = NSUUID().uuidString

    dynamic var createdAt: Date = Date()
    dynamic var updatedAt: Date = Date()
    dynamic var sentAt: Date = Date()
    
    dynamic var isIncoming: Bool = false
    
    dynamic var body: String = ""
    
    override class func primaryKey() -> String? { return #keyPath(localId) }
}

    // MARK: - Persistable
extension Message: Persistable {
    init(from object: RMMessage) throws {
        try self.init(from: object, context: Mapper(realm: try Realm()))
    }
    
    init(from object: RMMessage, context: Mapper) throws {
        self.init(localId: object.localId,
                  createdAt: object.createdAt,
                  updatedAt: object.updatedAt,
                  sentAt: object.sentAt,
                  isIncoming: object.isIncoming,
                  body: object.body)
    }
    
    func update(_ object: RMMessage, context: Mapper) throws {
        object.createdAt = createdAt
        object.updatedAt = updatedAt
        object.sentAt = sentAt
        object.isIncoming = isIncoming
        object.body = body
    }
}

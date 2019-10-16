//
//  RMMessage+Query.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import RealmSwift
import Predicate
import SwiftDate

extension RMMessage {
    static func getMessages(for date: Date, from realm: Realm) -> Results<RMMessage> {
        let dateEnd = date.dateAtEndOf(.day)
        let dateStart = date.dateAtStartOf(.day)
        return realm.objects(RMMessage.self)
            .filter {
                $0.sentAt >= dateStart &&
                $0.sentAt <= dateEnd
            }
            .sorted { $0.sentAt.descending }
    }
    
    static func getMessages(from realm: Realm) -> Results<RMMessage> {
        return realm.objects(RMMessage.self)
            .sorted { $0.sentAt.descending }
    }
    
    static func getById(_ localId: String, from realm: Realm) -> RMMessage? {
        return realm.objects(RMMessage.self)
            .filter { $0.localId == localId }
            .first
    }
}

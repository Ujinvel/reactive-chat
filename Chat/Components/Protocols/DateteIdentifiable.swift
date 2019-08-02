//
//  as.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import RealmSwift

protocol DateteIdentifiable where Self: Object {
    associatedtype ID: Hashable = String
    
    var localId: ID { get set }
    var sentAt: Date { get set }
}

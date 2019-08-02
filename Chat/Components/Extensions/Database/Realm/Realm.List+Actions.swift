//
//  Realm.List+Actions.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import RealmSwift

extension List {
    func replace<C: Collection>(with collection: C) where C.Element == Element {
        removeAll()
        append(objectsIn: collection)
    }
    
    func merge<C: Collection>(with collection: C, by id: (Element) -> Int)
        where C.Element == Element
    {
        append(objectsIn: collection)
    }
}

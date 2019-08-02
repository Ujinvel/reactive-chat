//
//  Realm.Results+Predicate.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import RealmSwift
import Predicate
import struct Predicate.SortDescriptor

extension Results where Element: Queryable {
    func filter(_ builder: Predicate<Element>.ObjectBuilder) -> Results {
        return filter(Predicate(builder).predicate)
    }
    
    func sorted(_ builder: (Element.Object) -> SortDescriptor) -> Results {
        let sortDescriptor = builder(Element.attributes)
        return sorted(byKeyPath: sortDescriptor.keyPath, ascending: sortDescriptor.ascending)
    }
    
    func sorted(_ builder: (Element.Object) -> [SortDescriptor]) -> Results {
        let sortDescriptors = builder(Element.attributes)
            .map { RealmSwift.SortDescriptor(keyPath: $0.keyPath, ascending: $0.ascending) }
        return sorted(by: sortDescriptors)
    }
}


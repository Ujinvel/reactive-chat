//
//  Realm.Results+MakeIndexes.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import RealmSwift

extension Results {
    func makeIndexes(_ indexationRange: ClosedRange<Int>) -> Array<Int> {
        guard indexationRange.lowerBound < count else { return [] }
        var max = indexationRange.upperBound
        while max >= 0 {
            if count - 1 >= max {
                return Array<Int>(indexationRange.lowerBound...max)
            }
            max -= 1
        }
        return []
    }
}

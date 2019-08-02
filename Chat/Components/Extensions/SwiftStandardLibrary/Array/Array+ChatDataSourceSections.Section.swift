//
//  Array+ChatDataSourceSections.Section.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

extension Array where Element == ChatDataSourceSections.Section {
    // Section is Hashable and == check only for Date
    func index(for date: Date) -> Int? {
        return self.firstIndex(of: ChatDataSourceSections.Section(date: date, count: 0))
    }
}

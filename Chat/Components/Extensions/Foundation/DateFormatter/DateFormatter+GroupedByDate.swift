//
//  DateFormatter+GroupedByDate.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

extension DateFormatter {
    public static func groupedByDate(in timeZone: TimeZone? = nil, yearEnabled: Bool) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = yearEnabled ? "E dd MMM yyyy" : "E dd MMM"
        formatter.timeZone = timeZone
        return formatter
    }
}


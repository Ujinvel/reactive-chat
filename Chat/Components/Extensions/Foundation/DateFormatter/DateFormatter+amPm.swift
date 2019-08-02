//
//  DateFormatter+amPm.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

extension DateFormatter {
    public static func amPm(timeZone: TimeZone? = nil) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("'at' hhmm")
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.timeZone = timeZone
        return formatter
    }
}

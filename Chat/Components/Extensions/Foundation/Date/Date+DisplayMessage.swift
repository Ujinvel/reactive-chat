//
//  Date+DisplayMessage.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import SwiftDate

extension Date {
    public var displayMessage: String {
        if isToday {
            return DateFormatter.amPm(timeZone: nil).string(from: self).uppercased()
        } else if isYesterday {
            return "Yesterday"
        }
        return toFormat("EEE d MMM")
    }
}

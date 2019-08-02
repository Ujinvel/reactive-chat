//
//  String+Range.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

extension String {
    public func allUTF16Ranges(of substring: String) -> [NSRange] {
        guard let regEx = try? NSRegularExpression(pattern: substring, options: [.caseInsensitive, .useUnicodeWordBoundaries]) else {
            return [] }
        return regEx
            .matches(in: self, options:[], range: NSMakeRange(0, utf16.count))
            .map { $0.range(at: 0) }
    }    
}

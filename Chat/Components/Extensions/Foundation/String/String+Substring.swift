//
//  String+Substring.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

extension String {
    public func removeSubstrings(_ source: [String]) -> String {
        return source.reduce(self) { $0.replacingOccurrences(of: $1, with: "") }
    }
}

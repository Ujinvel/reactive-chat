//
//  SortDescriptor.swift
//  Predicate
//
//  Created by Ihor Teltov on 7/12/18.
//

import Foundation

public struct SortDescriptor {
    public let keyPath: String
    public let ascending: Bool
    
    public init(keyPath: String, ascending: Bool) {
        self.keyPath = keyPath
        self.ascending = ascending
    }
}

//
//  Array+Chunked.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size)
            .map { Array(self[$0 ..< Swift.min($0 + size, count)]) }
    }
}


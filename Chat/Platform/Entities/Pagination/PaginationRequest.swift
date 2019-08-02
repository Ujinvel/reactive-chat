//
//  PaginationRequest.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

struct PaginationRequest {
    enum Order: String {
        case asc
        case desc
    }
    
    enum CodingKeys: String, CodingKey {
        case offset
        case limit
        case order
        case changesAfter
        case changesBefore
    }
    
    let offset: Int
    let limit: Int
    let order: Order
    let changesAfter: Date?
    let changesBefore: Date?
    
    init(offset: Int, limit: Int, order: Order, changesBefore: Date? = nil, changesAfter: Date? = nil) {
        self.offset = offset
        self.limit = limit
        self.order = order
        self.changesBefore = changesBefore
        self.changesAfter = changesAfter
    }
    
    var parameters: [String: Any] {
        var dict: [String: Any] = [CodingKeys.offset.stringValue: offset,
                                   CodingKeys.limit.stringValue: limit,
                                   CodingKeys.order.stringValue: order.rawValue]
        
        if let changesAfter = changesAfter {
            dict[CodingKeys.changesAfter.stringValue] = DateFormatter.iso8601.string(from: changesAfter)
        }
        
        if let changesBefore = changesBefore {
            dict[CodingKeys.changesBefore.stringValue] = DateFormatter.iso8601.string(from: changesBefore)
        }
        
        return dict
    }
}

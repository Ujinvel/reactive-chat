//
//  Pagination.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

struct PaginationResponce: Decodable {
    enum CodingKeys: String, CodingKey {
        case total
        case limit
        case offset
    }
    
    let total: Int
    let limit: Int
    let offset: Int
    
    var isLastPage: Bool {
        return offset + limit >= total
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.total = try container.decode(Int.self, forKey: .total)
        self.limit = try container.decode(Int.self, forKey: .limit)
        self.offset = try container.decode(Int.self, forKey: .offset)
    }
}

//
//  APIResponce.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

struct APIResponse<Value> {
    let data: Value
    let pagination: PaginationResponce?
    
    func map<T>(_ transform: (Value) throws -> T) throws -> APIResponse<T> {
        let newData = try transform(data)
        return APIResponse<T>(data: newData, pagination: pagination)
    }
}

extension APIResponse: Decodable where Value: Decodable {
    enum CodingKeys: String, CodingKey {
        case data
        case meta
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode(Value.self, forKey: .data)
        self.pagination = try container.decodeIfPresent(PaginationResponce.self, forKey: .meta)
    }
}


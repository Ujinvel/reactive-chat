//
//  Message.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

public struct Message: Decodable {
    enum CodingKeys: String, CodingKey {
        case localId
        case createdAt
        case updatedAt
        case sentAt
        case body
    }
    
    let localId: String
    
    let createdAt: Date
    let updatedAt: Date
    let sentAt: Date
    
    let isIncoming: Bool
    
    let body: String
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        localId = try container.decode(String.self, forKey: .localId)
        
        updatedAt = Date()
        createdAt = Date()
        sentAt = Date()
        
        isIncoming = true
        
        body = ""
    }
    
    // sourcery:inline:auto:Message.AutoPublicStruct
    // DO NOT EDIT
    public init(localId: String, 
    createdAt: Date, 
    updatedAt: Date, 
    sentAt: Date, 
    isIncoming: Bool, 
    body: String
    ) {
    self.localId = localId
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.sentAt = sentAt
    self.isIncoming = isIncoming
    self.body = body
    }
    // sourcery:end
}

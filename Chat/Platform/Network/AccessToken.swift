//
//  awdasd.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

final class AccessToken: Codable {    
    enum CodingKeys: String, CodingKey {
        case tokenString = "accessToken"
        case refreshTokenString = "refreshToken"
    }
    
    let tokenString: String
    let refreshTokenString: String
        
    init(tokenString: String) {
        self.tokenString = tokenString
        self.refreshTokenString = ""
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.tokenString = try container.decode(String.self, forKey: .tokenString)
        self.refreshTokenString = try container.decode(String.self, forKey: .refreshTokenString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tokenString, forKey: .tokenString)
        try container.encode(refreshTokenString, forKey: .refreshTokenString)
    }
}

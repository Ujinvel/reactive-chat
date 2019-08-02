//
//  Chat.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Moya

extension API {
    enum Chat: RequestConvertible {
        case sentMessage(Message)
        
        var path: String {
            switch self {
            case .sentMessage:
                return "/messages"
            }
        }
        
        var method: Moya.Method {
            switch self {
            case .sentMessage:
                return .post
            }
        }
        
        var task: Task {
            let parametersURLEncoding = URLEncoding.default
            let parametersJSONEncoding = JSONEncoding.default
            
            switch self {
            case .sentMessage(let message):
                return .requestParameters(parameters: [:],
                                          encoding: parametersJSONEncoding)
            }
        }
        
        var needsAuthorization: Bool {
            return true
        }
    }
}


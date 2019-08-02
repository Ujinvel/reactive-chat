//
//  Environment.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

enum Environment: PlatformEnvironment {
    case develop
    case stage
    case production
    
    #if STAGE
    static let current: Environment = stage
    #elseif PRODUCTION
    static let current: Environment = production
    #else
    static let current: Environment = develop
    #endif
    
    var baseURL: URL {
        let baseURLString: String = {
            switch self {
            case .develop: return "https://apple.com"
            case .stage: return "https://apple.com"
            case .production: return "https://apple.com"
            }
        }()
        return URL(string: baseURLString)!
    }
    
    var socketURL: URL {
        let socketURLString: String = {
            switch self {
            case .develop: return ""
            case .stage: return ""
            case .production: return ""
            }
        }()
        
        return URL(string: socketURLString)!
    }
    
    var google: GoogleConfig {
        return GoogleConfig(mapsKey: "",
                            placesKey: "",
                            clientID: "")
    }
    
    var outlook: OutlookConfig {
        let scopes = ["calendars.read", "user.read", "mail.read", "files.read"]
        let graphURL = URL(string: "https://graph.microsoft.com/v1.0/me")!
        return OutlookConfig(clientID: "",
                             graphURL: graphURL,
                             scopes: scopes)
    }
}

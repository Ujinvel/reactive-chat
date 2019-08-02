//
//  PlatformEnvironment.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

protocol PlatformEnvironment {
    var baseURL: URL { get }
    var socketURL: URL { get }
    var google: GoogleConfig { get }
    var outlook: OutlookConfig { get }
}

struct GoogleConfig {
    public let mapsKey: String
    public let placesKey: String
    public let clientID: String
    
    public init(mapsKey: String, placesKey: String, clientID: String) {
        self.mapsKey = mapsKey
        self.placesKey = placesKey
        self.clientID = clientID
    }
}

struct OutlookConfig {
    public let clientID: String
    public let graphURL: URL
    public let scopes: [String]
    
    public init(clientID: String, graphURL: URL, scopes: [String]) {
        self.clientID = clientID
        self.graphURL = graphURL
        self.scopes = scopes
    }
}

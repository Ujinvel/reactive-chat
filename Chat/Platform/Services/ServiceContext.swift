//
//  ServiceContext.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Result

final class ServiceContext {
    let configuration: PlatformEnvironment
    let network: Network
    let database: Database
    
    init(configuration: PlatformEnvironment,
         network: Network,
         database: Database) {
        self.configuration = configuration
        self.network = network
        self.database = database
    }
}

//
//  Platform.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UserNotifications
import ReactiveSwift
import Bagel

final class Platform: UseCasesProvider {
    var chat: ChatUseCase
    
    init(configuration: PlatformEnvironment) {
        Platform.setupServices(configuration: configuration)
        
        let context = ServiceContext(configuration: configuration,
                                     network: Network(baseURL: configuration.baseURL),
                                     database: Database())
        chat = ChatService(context: context)
    }
    
    public func didFinishLaunching(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        #if !STAGE && !PRODUCTION
        Bagel.start()
        #endif
    }
}

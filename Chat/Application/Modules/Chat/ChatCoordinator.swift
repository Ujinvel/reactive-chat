//
//  ChatCoordinator.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

final class ChatCoordinator: NSObject, Coordinator {
    var useCases: UseCasesProvider
    
    // MARK: - Controllers
    var rootViewController: UIViewController {
        return navigationController
    }
    private let navigationController: UINavigationController
    
    // MARK: - Life cycle
    init(useCases: UseCasesProvider,
         navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        self.useCases = useCases
        
        super.init()
    }
    
    // MARK: - Start/stop
    func start(animated: Bool) {
        navigationController.pushViewController(makeChatVC(), animated: animated)
    }
    
    func stop(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
    
    // MARK: - Make ViewModelOwner
    func makeChatVC() -> ChatVC {
        return makeViewModelOwner { _ in
            // heare you can config your ViewModelOwner
        }
    }
}

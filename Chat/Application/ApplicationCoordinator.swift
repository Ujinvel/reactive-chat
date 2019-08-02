//
//  ApplicationCoordinator.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

final class ApplicationCoordinator: NSObject {
    enum Flow {
        case main
    }
    
    // MARK: - Properties
    let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    private let useCases: UseCasesProvider
    
    private var flow: Flow? {
        didSet {
            guard let flow = flow, oldValue != flow else { return }
            
            var coordinator: Coordinator
            
            stop()
            
            switch flow {
            case .main: coordinator = ChatCoordinator(useCases: useCases)
            }
            
            coordinator.start(animated: false)
            
            window.rootViewController = coordinator.rootViewController
            window.makeKeyAndVisible()
        }
    }
    
    // MARK: - Setup
    init(useCases: UseCasesProvider) {
        self.useCases = useCases
        
        super.init()
    
        setupFlow()
        observeFlowChange()
    }
    
    private func setupFlow() {
        flow = .main
    }
    
    private func stop(animated: Bool = false) {
        guard let navigationController = window.rootViewController as? UINavigationController else { return }
        
        navigationController.viewControllers = []
    }
    
    // MARK: - Observe login/logout
    private func observeFlowChange() {
        
    }
}


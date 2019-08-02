//
//  Coordinator.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

protocol Coordinator {
    var rootViewController: UIViewController { get }
    var useCases: UseCasesProvider { get }
    
    func start(animated: Bool)
    func stop(animated: Bool)
}

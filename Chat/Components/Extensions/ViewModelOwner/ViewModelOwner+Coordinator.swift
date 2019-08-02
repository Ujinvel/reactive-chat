//
//  ViewModelOwner+Coordinator.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

private enum CoordinatorKeys {
    static var coordinator = "coordinator"
}

extension ViewModelOwner where Self: NSObject {
    static var describing: String {
        return String(describing: self.self)
    }
    
    var coordinator: Coordinator? {
        get {
            return getAssociatedObject(key: &CoordinatorKeys.coordinator)
        }
        set {
            setAssociatedObject(value: newValue, key: &CoordinatorKeys.coordinator, policy: .retainNonatomic)
        }
    }
}

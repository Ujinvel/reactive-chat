//
//  ViewModelOwner.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

protocol ViewModelOwner: class {
    associatedtype ViewModel: ViewModelDefault
    
    var viewModel: ViewModel { get set }
}

private enum ViewModelOwnerKeys {
    static var viewModel = "viewModel"
}

extension ViewModelOwner where Self: NSObject {
    var viewModel: ViewModel {
        get {
            return getAssociatedObject(key: &ViewModelOwnerKeys.viewModel)!
        }
        set {
            setAssociatedObject(value: newValue, key: &ViewModelOwnerKeys.viewModel, policy: .retain)
        }
    }
}

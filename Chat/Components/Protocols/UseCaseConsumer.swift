//
//  UseCaseConsumer.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

protocol UseCasesConsumer: class {
    associatedtype UseCases
    
    var useCases: UseCases { get }
}

private enum UseCasesConsumerKeys {
    static var useCases = "useCases"
}

extension UseCasesConsumer {
    var useCases: UseCases {
        get {
            if let useCases: UseCases = ObjcRuntime.getAssociatedObject(
                object: self,
                key: &UseCasesConsumerKeys.useCases) {
                return useCases
            } else { fatalError("useCases are required for \(Self.self)") }
        }
        
        set {
            ObjcRuntime.setAssociatedObject(object: self,
                                            value: newValue,
                                            key: &UseCasesConsumerKeys.useCases,
                                            policy: .retain)
        }
    }
}


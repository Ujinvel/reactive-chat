//
//  ActionGroup.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Result

/**
 Combine multiple actions into group. Combines errors and execution states of all actions.
 ```
 let action1: Action<Input1, Output1, Error1>
 let action2: Action<Input2, Output2, Error2>
 
 let group = ActionGroup()
 group.append(action1)
 group.append(action2)
 ```
 */

final class ActionGroup {
    private var errorSignals: [Signal<Error, NoError>] = []
    private var isExecutingProperties: [Property<Bool>] = []
    
    func append<Input, Output, Error>(_ action: Action<Input, Output, Error>) {
        errorSignals.append(action.errors.map { $0 as Error })
        isExecutingProperties.append(action.isExecuting)
    }
    
    /// Merges errors from all actions into one stream
    var errors: Signal<Error, NoError> {
        return Signal.merge(errorSignals)
    }
    
    /// true if any action is executing
    var isExecuting: Property<Bool> {
        return Property<Bool>.combineLatest(isExecutingProperties)?.map { $0.contains(true) } ?? Property<Bool>(value: false)
    }
}

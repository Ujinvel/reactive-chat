//
//  SignalProducer+MapToNoError.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Result

extension Signal where Value: Collection {
    func skipEmpty() -> Signal<Value, Error> {
        return filter { !$0.isEmpty }
    }
}

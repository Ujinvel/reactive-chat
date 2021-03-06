//
//  SignalProducer+MapToNoError.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift

extension SignalProducer where Value: Collection {
    func skipEmpty() -> SignalProducer<Value, Error> {
        return filter { !$0.isEmpty }
    }
}

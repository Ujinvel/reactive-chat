//
//  SignalProducer+MapToNoError.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Result

extension SignalProducer {
    func trigger() -> SignalProducer<Void, Error> {
        return map { _ in () }
    }
}

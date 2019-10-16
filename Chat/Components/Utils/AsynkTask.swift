//
//  AsynkTask.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift

typealias AsyncTaskResult<T> = SignalProducer<T, DomainError>
typealias AsyncTaskValue<T> = SignalProducer<T, Never>
typealias TriggerValue = AsyncTaskValue<Void>
typealias TriggerResult = AsyncTaskResult<Void>

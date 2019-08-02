//
//  SignalProducerConvertible+Error.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Result

extension SignalProducer where Error == DomainError {    
    func skipError(_ errorToSkip: Error) -> AsyncTaskResult<Result<Value, Error>> {
        return map { Result(value: $0) }
            .flatMapError {
                if errorToSkip == $0 {
                    return AsyncTaskResult(value: Result(error: $0))
                }
                return AsyncTaskResult(error: $0)
        }
    }
    
    func skipError(_ errorToSkip: Error, withDefaultValue defaultValue: Value) -> AsyncTaskResult<Value> {
        return producer
            .skipError(errorToSkip)
            .flatMap(.latest) { result -> AsyncTaskResult<Value> in
                switch result {
                case .success(let value):
                    return AsyncTaskResult(value: value)
                case .failure:
                    return AsyncTaskResult(value: defaultValue)
                }
        }
    }
}

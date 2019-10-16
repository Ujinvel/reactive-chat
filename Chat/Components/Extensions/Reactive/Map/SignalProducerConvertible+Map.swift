//
//  asdasd.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Moya

extension SignalProducerConvertible {
    func mapToDomainError() -> SignalProducer<Value, DomainError> {
        return producer
            .mapError { error in DomainError(error) }
    }
}

extension SignalProducerConvertible where Value == Response, Error == DomainError {
    func map<T: Decodable>(_ type: T.Type) -> AsyncTaskResult<T> {
        return producer.attemptMap { try $0.map(T.self) }
    }
}

extension SignalProducerConvertible where Value == Response, Error == Never {
    func map<T: Decodable>(_ type: T.Type) -> AsyncTaskResult<T> {
        return producer
            .attemptMap { try $0.map(T.self) }
            .mapToDomainError()
    }
}

extension SignalProducerConvertible where Error == DomainError {
    func attemptMap<U>(_ transform: @escaping (Value) throws -> U) -> SignalProducer<U, Error> {
        return producer.attemptMap {
            do {
                return .success(try transform($0))
            } catch let domainError as DomainError {
                return .failure(domainError)
            } catch let error {
                return .failure(DomainError(error))
            }
        }
    }
    
    func attempt(_ action: @escaping (Value) throws -> Void) -> SignalProducer<Value, Error> {
        return producer.attempt { value -> Result<(), Error> in
            do {
                try action(value)
                return .success(())
            } catch let domainError as DomainError {
                return .failure(domainError)
            } catch let error {
                return .failure(DomainError(error))
            }
        }
    }
}

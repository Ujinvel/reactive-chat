//
//  Database+Persist.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import RealmSwift
import ReactiveSwift

extension SignalProducerConvertible
    where
    Value: Persistable,
    Value.ManagedObject: Object,
    Error == DomainError,
    Value.Context == Mapper
{
    func persist(to database: Database, environment: DatabasePerformEnvironment = .default) -> AsyncTaskResult<Value> {
        return producer.flatMap(.concat) { value in
            database
                .performWrite(on: environment) { try $0.fetchOrCreate(from: value, context: Mapper(realm: $0)) }
                .map { _ in value }
            }
    }
}

extension SignalProducerConvertible
    where
    Value: PersistableCollection,
    Value.Item.ManagedObject: Object,
    Error == DomainError,
    Value.Item.Context == Mapper
{
    func persist(to database: Database, environment: DatabasePerformEnvironment = .default) -> AsyncTaskResult<Value> {
        return producer.flatMap(.concat) { value in
            database
                .performWrite(on: environment) { try $0.fetchOrCreate(from: value.items, context: Mapper(realm: $0)) }
                .map { _ in value }
            }
    }
}




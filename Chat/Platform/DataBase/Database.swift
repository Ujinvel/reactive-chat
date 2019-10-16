//
//  DataBase.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import RealmSwift
import ReactiveSwift

enum DatabasePerformEnvironment {
    case `default`
    case chat
    case queue(DispatchQueue)
}

final class Database: AutoQueueScheduler {
    // sourcery:inline:auto:Database.AutoQueueScheduler
    // DO NOT EDIT
    lazy var backgroundConcurentQueue: DispatchQueue = {
    return DispatchQueue(label: "\(Database.self)", qos: .userInitiated, attributes: .concurrent)
    }()
    lazy var backgroundConcurentSheduler: QueueScheduler = {
    return QueueScheduler(qos: .userInitiated,
    name: "\(Database.self)",
    targeting: backgroundConcurentQueue)
    }()
    // sourcery:end
    
    private let databaseThread = BackgroundWorker(name: "databaseThread")
    private let chatThread = BackgroundWorker(name: "chatThread")
    
    // MARK: - Perform
    private func commonPerform<Output>(on queue: DispatchQueue? = nil,
                                       inThread thread: BackgroundWorker?,
                                       _ action: @escaping (Realm) throws -> Output) -> AsyncTaskResult<Output> {
        return SignalProducer { observer, lifetime in
            autoreleasepool {
                let action = {
                    guard !lifetime.hasEnded else { return }
                    do {
                        let realm = try Realm()
                        do {
                            observer.send(value: try action(realm))
                        } catch let error {
                            if realm.isInWriteTransaction {
                                realm.cancelWrite()
                            }
                            observer.send(error: DomainError(error))
                        }
                        observer.sendCompleted()
                    } catch let error {
                        observer.send(error: DomainError(error))
                    }
                }
                if let queue = queue {
                    queue.async(execute: action)
                } else {
                    thread?.perform(action: action)
                }
            }
        }
        .observe(on: backgroundConcurentSheduler)
    }
    
    func perform<Output>(on environment: DatabasePerformEnvironment = .default,
                         _ action: @escaping (Realm) throws -> Output) -> AsyncTaskResult<Output> {
        switch environment {
        case .default:
            return commonPerform(inThread: databaseThread, action)
        case .chat:
            return commonPerform(inThread: chatThread, action)
        case .queue(let queue):
            return commonPerform(on: queue, inThread: nil, action)
        }
    }
        
    // MARK: - Write
    private func commonWrite<Output>(in realm: Realm, _ action: @escaping (Realm) throws -> Output) throws -> Output {
        let wasInWriteTransaction = realm.isInWriteTransaction
        if !wasInWriteTransaction {
            realm.beginWrite()
        }
        let output = try action(realm)
        if !wasInWriteTransaction {
            try realm.commitWrite()
        }
        return output
    }
    
    func performWrite<Output>(on environment: DatabasePerformEnvironment = .default,
                              _ action: @escaping (Realm) throws -> Output) -> AsyncTaskResult<Output> {
        return perform(on: environment) { [unowned self] in
            try self.commonWrite(in: $0, action)
        }
    }
}


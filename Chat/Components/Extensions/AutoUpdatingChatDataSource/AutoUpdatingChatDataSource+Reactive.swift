//
//  AutoUpdatingChatDataSource+Reactive.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Result

extension SignalProducerConvertible where Value: AutoUpdatingChatDataSource, Error == NoError {
    func didReceiveUpdates() -> AsyncTaskValue<AutoUpdatingChatDataSource.Updates> {
        return producer.flatMap(.latest) { dataSource -> AsyncTaskValue<AutoUpdatingChatDataSource.Updates> in
            AsyncTaskValue<AutoUpdatingChatDataSource.Updates> { observer, _ in
                dataSource.didReceiveUpdates = { updates in
                    if let updates = updates {
                        observer.send(value: updates)
                    }
                }
            }
        }
    }
    
    func didLoad() -> AsyncTaskValue<Void> {
        return producer.flatMap(.latest) { dataSource -> AsyncTaskValue<Void> in
            AsyncTaskValue<Void> { observer, _ in
                dataSource.didLoad = {
                    observer.send(value: ())
                }
            }
        }
    }
    
    func didBecomeEmpty() -> AsyncTaskValue<Void> {
        return producer.flatMap(.latest) { dataSource -> AsyncTaskValue<Void> in
            AsyncTaskValue<Void> { observer, _ in
                dataSource.didBecomeEmpty = {
                    observer.send(value: ())
                }
            }
        }
    }
    
    func didReceiveError() -> AsyncTaskValue<DomainError> {
        return producer.flatMap(.latest) { dataSource -> AsyncTaskValue<DomainError> in
            AsyncTaskValue<DomainError> { observer, _ in
                dataSource.didReceiveError = {
                    observer.send(value: $0)
                }
            }
        }
    }
    
    func executionTrigger() -> AsyncTaskValue<Bool> {
        return producer.flatMap(.latest) { dataSource -> AsyncTaskValue<Bool> in
            AsyncTaskValue<Bool> { observer, _ in
                dataSource.executionTrigger = { isExecuting in
                    observer.send(value: isExecuting)
                }
            }
        }
    }
}

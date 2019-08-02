//
//  Realm+Observe.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import RealmSwift
import ReactiveSwift

struct RealmObservationContext<T: RealmCollectionValue> {
    let results: Results<T>
    let deletions: [Int]
    let insertions: [Int]
    let modifications: [Int]
    var isInitial: Bool {
        return deletions.isEmpty && insertions.isEmpty && modifications.isEmpty
    }
    init(results: Results<T>) {
        self.init(results: results, deletions: [], insertions: [], modifications: [])
    }
    
    init(results: Results<T>, deletions: [Int], insertions: [Int], modifications: [Int]) {
        self.results = results
        self.deletions = deletions
        self.insertions = insertions
        self.modifications = modifications
    }
}

extension Results {
    func observe() -> AsyncTaskResult<RealmObservationContext<Element>> {
        return AsyncTaskResult { observer, lifetime in
            let token = self.observe { changes in
                switch changes {
                case .initial(let results):
                    observer.send(value: .init(results: results))
                case .update(let results,
                             deletions: let deletions,
                             insertions: let insertions,
                             modifications: let modifications):
                    observer.send(value: .init(results: results,
                                               deletions: deletions,
                                               insertions: insertions,
                                               modifications: modifications))
                case .error(let error):
                    observer.send(error: .init(error))
                }
            }
            lifetime.observeEnded {
                token.invalidate()
            }
        }
    }
}

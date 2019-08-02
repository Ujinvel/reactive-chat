//
//  NetworkProvider+Request.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Result
import Moya

extension NetworkProvider {
    public func request(_ target: Target, qos: DispatchQoS.QoSClass = .default) -> AsyncTaskResult<Response> {
        return AsyncTaskResult { observer, lifetime in
            let request: Cancellable? = self.request(target,
                                                     callbackQueue: DispatchQueue.global(qos: qos),
                                                     completion: { result in
                                                        switch result {
                                                        case .success(let value):
                                                            observer.send(value: value)
                                                            observer.sendCompleted()
                                                        case .failure(let error):
                                                            observer.send(error: DomainError(error))
                                                        }
            })
            lifetime.observeEnded {
                if let request = request {
                    request.cancel()
                }
            }
        }
    }
    
    public func requestWithProgress(_ target: Target, qos: DispatchQoS.QoSClass = .default) -> AsyncTaskResult<ProgressResponse> {
        return AsyncTaskResult { observer, lifetime in
            let request: Cancellable? = self.request(target, callbackQueue: DispatchQueue.global(qos: qos),
                                                     progress: {
                                                        observer.send(value: .progress($0.progress))
            }, completion: { result in
                switch result {
                case .success(let value):
                    observer.send(value: .response(value))
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: DomainError(error))
                }
            })
            lifetime.observeEnded {
                if let request = request {
                    request.cancel()
                }
            }
        }
    }
}

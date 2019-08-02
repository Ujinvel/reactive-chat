//
//  NetworkProvider.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Moya

final class NetworkProvider<Target: RequestConvertible>: MoyaProvider<Target> {
    enum ProgressResponse {
        case progress(Double)
        case response(Response)
    }
    
    private final class func endpointMapping(for baseURL: URL) -> (Target) -> Endpoint {
        return { target in
            return Endpoint(
                url: baseURL.appendingPathComponent(target.path).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }
    }
    
    weak var requestRetrier: RequestRetrier?
    
    init(baseURL: URL, manager: Manager, plugins: [PluginType], requestRetrier: RequestRetrier? = nil) {
        self.requestRetrier = requestRetrier
        super.init(endpointClosure: NetworkProvider.endpointMapping(for: baseURL), manager: manager, plugins: plugins)
    }
    
    @discardableResult
    override func request(_ target: Target,
                          callbackQueue: DispatchQueue? = .none,
                          progress: ProgressBlock? = .none,
                          completion: @escaping Completion) -> Moya.Cancellable {
        return super.request(target, callbackQueue: callbackQueue, progress: progress) { [weak self] result in
            guard let strongSelf = self else {
                completion(result)
                return
            }
            if case .failure(let error) = result, let requestRetrier = strongSelf.requestRetrier, target.shouldRetry {
                requestRetrier.should(retry: target, with: error, completion: { shouldRetry, delay in
                    if shouldRetry {
                        let callbackQueue = callbackQueue ?? .main
                        callbackQueue.asyncAfter(deadline: .now() + delay, execute: {
                            guard let strongSelf = self else {
                                completion(.failure(error))
                                return
                            }
                            strongSelf.request(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                        })
                        
                    } else {
                        completion(.failure(error))
                    }
                })
            } else {
                completion(result)
            }
        }
    }
}

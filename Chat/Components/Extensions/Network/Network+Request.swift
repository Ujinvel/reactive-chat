//
//  Network+Request.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Moya

extension Network {
    public func request<T: RequestConvertible>(_ target: T, qos: DispatchQoS.QoSClass = .default) -> AsyncTaskResult<Response> {
        let provider: NetworkProvider<T> = makeProvider()
        return provider.request(target, qos: qos)
    }
}

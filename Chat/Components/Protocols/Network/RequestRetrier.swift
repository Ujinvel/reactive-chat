//
//  RequestRetrier.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Moya

protocol RequestRetrier: class {
    func should(retry request: RequestConvertible,
                with error: MoyaError,
                completion: @escaping (Bool, DispatchTimeInterval) -> Void)
}

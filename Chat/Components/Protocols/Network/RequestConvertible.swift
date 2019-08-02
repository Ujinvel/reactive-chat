//
//  RequestRetrier.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Moya

protocol RequestConvertible: TargetType {
    var needsAuthorization: Bool { get }
    var shouldRetry: Bool { get }
}

extension RequestConvertible {
    var baseURL: URL {
        fatalError("Use RequestConvertible in conjunction with NetworkProvider")
    }
    var headers: [String : String]? {
        return nil
    }
    var needsAuthorization: Bool {
        return false
    }
    var shouldRetry: Bool {
        return true
    }
    var sampleData: Data {
        fatalError("Not implemented")
    }
}

//
//  DomainError+Error.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Moya

extension DomainError {
    public init(_ error: Error) {
        switch error {
        case let domainError as DomainError:
            self = domainError
        case let moyaError as MoyaError:
            switch moyaError {
            case .underlying(let error, _):
                if let responseError = error as? APIResponseError {
                    self = .api(responseError)
                } else if let domainError = error as? DomainError {
                    self = domainError
                } else if (error as NSError).code == -1009 {
                    self = .noConnection
                } else if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .imageMapping(let response), .jsonMapping(let response), .stringMapping(let response),
                         .statusCode(let response):
                        self = .customMessage(response.debugDescription)
                    case .objectMapping(_, let response):
                        self = .customMessage(response.debugDescription)
                    case .encodableMapping(_):
                        self = .underlying(error)
                    case .underlying(let error, _):
                        self = .underlying(error)
                    case .requestMapping(let description):
                        self = .customMessage(description)
                    case .parameterEncoding(_):
                        self = .underlying(error)
                    }
                } else {
                    self = .underlying(error)
                }
            case .objectMapping(let error, _):
                if let decodingError = error as? DecodingError {
                    self = .mapping(decodingError, decodingError.debugDescription)
                } else {
                    self = .underlying(error)
                }
            default:
                self = .underlying(moyaError)
            }
        default:
            self = .underlying(error)
        }
    }
}

extension DecodingError {
    public var debugDescription: String {
        switch self {
        case .dataCorrupted(let context):
            return "Data corrupted @ \(context.keyPath)"
        case .keyNotFound(let key, let context):
            return "Key '\(key.keyPath)' not found @ \(context.keyPath)"
        case .typeMismatch(let type, let context):
            return "Type mismatch '\(type)' @ \(context.keyPath)"
        case .valueNotFound(let type, let context):
            return "Value '\(type)' not found @ \(context.keyPath)"
        @unknown default:
            return "Unknown error"
      }
    }
}

extension DecodingError.Context {
    public var keyPath: String {
        return codingPath.map { $0.keyPath }.joined(separator: ".")
    }
}

extension CodingKey {
    public var keyPath: String {
        return intValue.flatMap(String.init) ?? stringValue
    }
}


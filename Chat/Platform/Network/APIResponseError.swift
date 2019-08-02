//
//  ApiResponceError.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

public struct APIResponseError: Decodable, LocalizedError {
    public enum CodeType: String {
        case unprocessable = "UNPROCESSABLE_ENTITY_ERROR"       // Data can't be proceed on server
        case badRequest = "BAD_REQUEST"                         // input validation error
        case restricted = "FORBIDDEN_RESOURCE_ERROR"            // resource access is restricted
        case `internal` = "INTERNAL_SERVER_ERROR"               // unhandled server exception
        case notFound = "NOT_FOUND_ERROR"                       // resource does not exist
        case notAuthorized = "UNAUTHORIZED_ERROR"               // user is not authenticated
        case lastEventHost = "LAST_EVENT_HOST_ERROR"            // you can't leave event if you're last host
        case notParticipant = "USER_IS_NOT_PARTICIPANT_ERROR"   // you're not a participant of current event
        case inactiveParticipant = "INACTIVE_PARTICIPANT_ERROR" // you're not active participant of event
        case blocked = "ACCOUNT_IS_BLOCKED_ERROR"               // your account has been blocked by admin
        case phoneVerification = "INCORRECT_VERIFICATION_CODE"  // user enter incorrect verification code
        case phoneChangeLimit = "LIMIT_EXCEEDED_ERROR"          // user try to change his phone more than ones at 48h
        case phoneInBlackList = "PHONE_IS_IN_BLACKLIST_ERROR"   // black list
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case statusCode
        case message
        case errors
    }
    
    let code: CodeType
    let statusCode: Int?
    let message: String
    let errors: [APIError]
    
    public var errorDescription: String? {
        if errors.isEmpty {
            return message
        } else {
            return errors[0].errorDescription
        }
    }
    
    init(code: CodeType,
                message: String,
                statusCode: Int,
                errors: [APIError]) {
        self.code = code
        self.message = message
        self.errors = errors
        self.statusCode = statusCode
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let codeTypeString = try container.decode(String.self, forKey: .code)
        guard let code = CodeType(rawValue: codeTypeString) else {
            throw DomainError.customMessage("Can't parse error")
        }
        self.code = code
        self.statusCode = try container.decodeIfPresent(Int.self, forKey: .statusCode)
        self.message = try container.decode(String.self, forKey: .message)
        
        do {
            let errors = try container.decodeIfPresent([APIError].self, forKey: .errors)
            
            if errors != nil {
                self.errors = errors!
            } else {
                self.errors = []
            }
        }
    }
}

struct APIError: Decodable, LocalizedError {
    enum Key: String, Decodable {
        case email
        case password
        case unknown
        case phone
    }
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case message
        case key
    }
    
    let message: String
    let statusCode: Int?
    let key: Key
    
    var errorDescription: String? {
        return message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.statusCode = try container.decodeIfPresent(Int.self, forKey: .statusCode)
        self.message = try container.decode(String.self, forKey: .message)
        self.key = (try? container.decode(Key.self, forKey: .key)) ?? .unknown
    }
    
    init(code: String,
                message: String,
                statusCode: Int,
                key: Key) {
        self.message = message
        self.key = key
        self.statusCode = statusCode
    }
}


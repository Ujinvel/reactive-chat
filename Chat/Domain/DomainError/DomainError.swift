//
//  DomainError.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

enum Permission {
    case location(always: Bool)
    case notifications
    case gallery
    case contacts
    case iCalendar
    case audio
    case video
}

enum DomainError: Error {
    case api(APIResponseError)
    case underlying(Error)
    case emailNotConfirmed(String)
    case customMessage(String)
    case userRequired
    case `internal`
    case permissionDenied(Permission)
    case paymentCardNotFound
    case socketNotConnected
    case facebook
    case mapping(Error, String)
    case noConnection
}

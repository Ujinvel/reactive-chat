//
//  DomainError+Equtable.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

extension DomainError: Equatable {
    public static func == (lhs: DomainError, rhs: DomainError) -> Bool {
        switch (lhs, rhs) {
        case (.api(let lResponse), .api(let rResponse)):
            return lResponse.code == rResponse.code
        case (.underlying(let lUnderlying), .underlying(let rUnderlying)):
            return lUnderlying.localizedDescription == rUnderlying.localizedDescription
        case (.emailNotConfirmed(let lEmailNotConfirmed), .emailNotConfirmed(let rEmailNotConfirmed)):
            return lEmailNotConfirmed == rEmailNotConfirmed
        case (.customMessage(let lCustomMessage), .customMessage(let rCustomMessage)):
            return lCustomMessage == rCustomMessage
        case (.userRequired, .userRequired):
            return true
        case (.internal, .internal):
            return true
        case (.permissionDenied(let lPermission), .permissionDenied(let rPermission)):
            switch (lPermission, rPermission) {
            case (.location(let lAlways), .location(let rAlways)):
                return lAlways == rAlways
            case (.notifications, .notifications):
                return true
            case (.gallery, .gallery):
                return true
            case (.contacts, .contacts):
                return true
            case (.iCalendar, .iCalendar):
                return true
            case (.audio, .audio):
                return true
            default:
                return false
            }
        case (.paymentCardNotFound, .paymentCardNotFound):
            return true
        case (.socketNotConnected, .socketNotConnected):
            return true
        case (.facebook, .facebook):
            return true
        case (.mapping, .mapping):
            return true
        case (.noConnection, .noConnection):
            return true
        default:
            return false
        }
    }
}


//
//  asd.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Moya

protocol AccessTokenProvider: class {
    var accessToken: Property<AccessToken?> { get }
    func refreshToken(else error: Error) -> SignalProducer<Void, MoyaError>
}

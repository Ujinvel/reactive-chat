//
//  ReachabilityManager.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Alamofire
import ReactiveSwift
import Result

extension Network {
    final class ReachabilityManager {
        private let manager: NetworkReachabilityManager?
        private let status: MutableProperty<NetworkReachabilityManager.NetworkReachabilityStatus>
        private(set) lazy var isReachable: Property<Bool> = status.map {
            if case .reachable = $0 {
                return true
            } else {
                return false
            }
        }
        
        init(host: String? = nil) {
            self.manager = host.flatMap(NetworkReachabilityManager.init(host:)) ??
                NetworkReachabilityManager()
            status = MutableProperty(manager?.networkReachabilityStatus ?? .unknown)
            manager?.listener = { [weak self] status in
                self?.status.value = status
            }
            manager?.startListening()
        }
        
        deinit {
            manager?.stopListening()
        }
    }
}


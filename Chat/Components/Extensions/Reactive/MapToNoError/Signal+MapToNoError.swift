//
//  Signal+MapToNoError.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift

extension Signal {
    func mapToNoError() -> Signal<Value, Never> {
        return flatMapError { _ in .empty }
    }
}

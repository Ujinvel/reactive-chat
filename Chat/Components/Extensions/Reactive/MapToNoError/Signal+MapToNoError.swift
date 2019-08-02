//
//  Signal+MapToNoError.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import ReactiveSwift
import Result

extension Signal {
    func mapToNoError() -> Signal<Value, NoError> {
        return flatMapError { _ in .empty }
    }
}

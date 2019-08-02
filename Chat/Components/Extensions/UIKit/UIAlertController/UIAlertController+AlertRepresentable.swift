//
//  UIAlertController+AlertRepresentable.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

extension UIAlertController {
    convenience init(_ alert: AlertRepresentable) {
        self.init(title: alert.title, message: alert.message, preferredStyle: alert.style)
        
        alert.actions.forEach { addAction($0) }
    }
}

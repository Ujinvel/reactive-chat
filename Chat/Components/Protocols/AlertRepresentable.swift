//
//  AlertRepresentable.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

protocol AlertRepresentable {
    typealias AlertHandler = () -> Void
    
    var title: String? { get }
    var message: String? { get }
    var actions: [UIAlertAction] { get }
    var style: UIAlertController.Style { get }
}

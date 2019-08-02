//
//  CommonErrorAlert.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

struct DomainErrorAlert: AlertRepresentable {
    var title: String? {
        return "Error"
    }
    
    var message: String? {
        return error.localizedDescription
    }
    
    var actions: [UIAlertAction] {
        return [UIAlertAction(title: R.string.buttons.buttonOk(), style: .default, handler: nil)]
    }
    
    var style: UIAlertControllerStyle {
        return .alert
    }
    
    let error: DomainError
}

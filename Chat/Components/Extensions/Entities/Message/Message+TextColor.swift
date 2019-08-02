//
//  Message+TextColor.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

extension Message {    
    var textColor: UIColor {
        return isIncoming ? .black : .white
    }
}

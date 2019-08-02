//
//  ChatItem.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

protocol ChatItem {
    var margins: UIEdgeInsets { get }
    var isSelected: Bool { get nonmutating set }
}


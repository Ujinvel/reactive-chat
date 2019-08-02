//
//  ChatCellFactoryProtocol.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import AsyncDisplayKit

protocol ChatCellFactoryProtocol {
    func makeCell(for message: Message) -> ASCellNode
    func makeSectionHeader(title: String, inverted: Bool) -> ASCellNode
    func makeEmptyCell() -> ASCellNode
}

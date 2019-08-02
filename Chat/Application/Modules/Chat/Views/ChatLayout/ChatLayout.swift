//
//  ChatLayout.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

final class ChatLayout: UICollectionViewFlowLayout {
    // MARK: - Private
    private enum AnimationStyle {
        case none
        case insertAfter(offset: CGFloat)
        case insertBefore
    }
    private var animations: [IndexPath: AnimationStyle] = [:]
    
    init(inverted: Bool) {
        super.init()
        commonInit(inverted: inverted)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInit(inverted: Bool) {
        if inverted {
            sectionFootersPinToVisibleBounds = true
        } else {
            sectionHeadersPinToVisibleBounds = true
        }
        minimumInteritemSpacing = 0
    }
    
    // MARK: - Override
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        let inserts = updateItems.lazy
            .filter { $0.updateAction == .insert }
            .compactMap { $0.indexPathAfterUpdate }
            .sorted()
        
        if inserts.first?.item == 0 {
            let contiguousInserts = inserts
                .enumerated()
                .prefix(while: {$0.offset == $0.element.item})
                .map { $0.element }
            
            if let lastIndexPath = contiguousInserts.last,
                let attributes = layoutAttributesForItem(at: lastIndexPath) {
                let offset = attributes.frame.maxY
                contiguousInserts.forEach { animations[$0] = .insertAfter(offset: offset) }
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        animations.removeAll()
        super.finalizeCollectionViewUpdates()
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
            else { return nil }
        let animationStyle = animations[itemIndexPath] ?? .none
        switch animationStyle {
        case .insertAfter(let offset):
            attributes.alpha = 1.0
            attributes.frame.origin.y -= 2 * offset
        case .insertBefore:
            attributes.alpha = 0.0
        default:
            break
        }
        return attributes
    }
}



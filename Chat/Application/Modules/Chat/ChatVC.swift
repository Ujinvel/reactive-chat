//
//  ViewController.swift
//  Chat
//
//  Created by Ujin on 7/31/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import ReactiveCocoa

extension ChatVC: Makeable {
    static func make() -> ChatVC {
        return R.storyboard.chat.chat()!
    }
}

final class ChatVC: BaseVC, ViewModelOwner {
    typealias ViewModel = ChatVM
    
    enum C {
        enum ChatAnimation {
            static let appearanceDuration: TimeInterval = 0.25
        }
        enum ChatLayout {
            static let minimumLineSpacing: CGFloat = 8
            static let sectionInset: UIEdgeInsets = .vertical(16)
        }
    }
    
    // MARK: - Outlets    
    @IBOutlet private var placeholderLabel: UILabel!
    
    // MARK: - Properties
    private lazy var chatInputView: ChatInputView = .instantiateFromNib()
    private lazy var collectionNode = makeCollectionNode()
    private var isScrolling = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return chatInputView
    }

    override func keyboardDidChange(_ context: KeyboardChangeContext) {
        let height = context.intersection(with: collectionNode.view).height
        collectionNode.contentInset.bottom = view.safeAreaInsets.top

        collectionNode.contentInset.top = height
        guard collectionNode.contentOffset.y == -context.beginFrame.height || collectionNode.contentOffset.y == 0 else { return }
        if let indexPath = collectionNode.indexPathsForVisibleItems.min() {
            context.animate {
                collectionNode.scrollToItem(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    // MARK: - Setup
    private func setup() {
        setupCollectionNode()
        viewModel.bindInput(collectionNode: collectionNode,
                            chatInputView: chatInputView,
                            placeholderLabel: placeholderLabel)
        viewModel.bindOutput(errors: errors(),
                             activity: activity())
    }
    
    // MARK: - Collection node
    private func makeCollectionNode() -> ASCollectionNode {
        let layout = ChatLayout(inverted: true)
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = C.ChatLayout.minimumLineSpacing
        layout.sectionInset = C.ChatLayout.sectionInset
        
        let node = ASCollectionNode(collectionViewLayout: layout)
        
        node.inverted = true
        node.backgroundColor = .clear
        node.view.keyboardDismissMode = .interactive
        node.view.alwaysBounceVertical = true
        
        return node
    }
    
    private func setupCollectionNode() {
        collectionNode.view.showsVerticalScrollIndicator = false
        collectionNode.alpha = 0
        collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionFooter)
        collectionNode.frame = view.bounds
        collectionNode.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionNode.view.contentInsetAdjustmentBehavior = .never
        collectionNode.dataSource = self
        collectionNode.delegate = self
        collectionNode.setTuningParameters(ASRangeTuningParameters(leadingBufferScreenfuls: 1,
                                                                   trailingBufferScreenfuls: 1),
                                           for: .visibleOnly,
                                           rangeType: .display)
        view.addSubnode(collectionNode)
        collectionNode.view.keyboardDismissMode = .interactive
    }
}

    // MARK: - ASCollectionDataSource
extension ChatVC: ASCollectionDataSource {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return viewModel.numberOfSections(in: collectionNode)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return viewModel.collectionNode(collectionNode, numberOfItemsInSection: section)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode,
                        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return viewModel.collectionNode(collectionNode, nodeBlockForItemAt: indexPath)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode,
                        nodeBlockForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> ASCellNodeBlock {
        return viewModel.collectionNode(collectionNode, nodeBlockForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode,
                        supplementaryElementKindsInSection section: Int) -> [String] {
        return [UICollectionElementKindSectionFooter]
    }
}

    // MARK: - ASCollectionDelegate
extension ChatVC: ASCollectionDelegate {
}

    // MARK: - ASCollectionDelegateFlowLayout
extension ChatVC: ASCollectionDelegateFlowLayout {
    func collectionNode(_ collectionNode: ASCollectionNode,
                        constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = collectionNode.frame.width
        return ASSizeRangeMake(CGSize(width: width, height: 0),
                               CGSize(width: width, height: ASSizeRangeUnconstrained.max.height))
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode,
                        sizeRangeForFooterInSection section: Int) -> ASSizeRange {
        let width = collectionNode.frame.width
        return ASSizeRangeMake(CGSize(width: width, height: 0),
                               CGSize(width: width, height: ASSizeRangeUnconstrained.max.height))
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrensBeforPagination: CGFloat = 0
        let screenBorder = collectionNode.bounds.height * scrensBeforPagination
        let needAddToTop = scrollView.contentOffset.y >= scrollView.contentSize.height - collectionNode.bounds.height - screenBorder
        if needAddToTop {
            viewModel.nextPage()
        }
    }
}


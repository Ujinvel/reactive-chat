//
//  AutoUpdatingChatDataSource.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import CoreGraphics

protocol AutoUpdatingChatDataSource: class {
    associatedtype Item
    
    typealias Updates = (insertations: Insertations, deletations: Deletations, modifications: Modifications)
    typealias Insertations = (sections: IndexSet, items: [IndexPath])
    typealias Deletations = (sections: IndexSet, items: [IndexPath])
    typealias Modifications = [IndexPath]
    
    typealias UpdatesCompletion = () -> Void
    typealias DidReceiveError = (DomainError) -> Void
    typealias DidLoad = () -> Void
    typealias DidBecomeEmpty = () -> Void
    typealias DidReceiveUpdates = (Updates?) -> Void
    typealias ExecutionTrigger = (Bool) -> Void
    
    typealias ContentPosition = (screenHeight: CGFloat, contentSizeHeight: CGFloat, contentOffsetY: CGFloat)
    
    var sectionsCount: Int { get }
    
    func numberOfItemsInSectionAt(_ section: Int) -> Int
    func item(at indexPath: IndexPath) -> Item?
    func item(at indexPath: IndexPath, completion: @escaping (Item?) -> Void)
    func indexPath(at item: Item) -> IndexPath?
    func dateHeader(at section: Int) -> Date?
    func nextPage()
    func updateVisibleItem(_ visibleItem: Item)
    func didProcessedUpdates()// UI just processed last updates
    
    var didLoad: DidLoad? { get set }
    var didBecomeEmpty: DidBecomeEmpty? { get set }
    var didReceiveError: DidReceiveError? { get set }
    var didReceiveUpdates: DidReceiveUpdates? { get set }
    var executionTrigger: ExecutionTrigger? { get set }
    
    func resume()
    func pause()
}

final class AnyChatDataSource<Item>: AutoUpdatingChatDataSource {
    private let sectionsCountClosure: () -> Int
    private let numberOfItemsInSectionAtClosure: (Int) -> Int
    private let itemAtIndexPathClosure: (IndexPath) -> Item?
    private let itemBlockAtIndexPathClosure: (IndexPath, @escaping (Item?) -> Void) -> Void
    private let indexPathAtItemClosure: (Item) -> IndexPath?
    private let dateHeaderAtSectionClosure: (Int) -> Date?
    private let nextPageClosure: () -> Void
    private let didProcessedLastUpdatesClosure: () -> Void
    private let getDidLoad: () -> AutoUpdatingChatDataSource.DidLoad?
    private let setDidLoad: (AutoUpdatingChatDataSource.DidLoad?) -> Void
    private let getDidBecomeEmpty: () -> AutoUpdatingChatDataSource.DidBecomeEmpty?
    private let setDidBecomeEmpty: (AutoUpdatingChatDataSource.DidBecomeEmpty?) -> Void
    private let getDidReceiveError: () -> AutoUpdatingChatDataSource.DidReceiveError?
    private let setDidReceiveError: (AutoUpdatingChatDataSource.DidReceiveError?) -> Void
    private let getDidReceiveUpdates: () -> AutoUpdatingChatDataSource.DidReceiveUpdates?
    private let setDidReceiveUpdates: (AutoUpdatingChatDataSource.DidReceiveUpdates?) -> Void
    private let getExecutionTrigger: () -> AutoUpdatingChatDataSource.ExecutionTrigger?
    private let setExecutionTrigger: (AutoUpdatingChatDataSource.ExecutionTrigger?) -> Void
    private let updateVisibleItemClosure: (Item) -> Void
    private let resumeClosure: () -> Void
    private let pauseClosure: () -> Void
    
    public init<T: AutoUpdatingChatDataSource>(_ dataSource: T) where T.Item == Item {
        self.sectionsCountClosure = { dataSource.sectionsCount }
        self.numberOfItemsInSectionAtClosure = dataSource.numberOfItemsInSectionAt
        self.itemAtIndexPathClosure = dataSource.item(at:)
        self.itemBlockAtIndexPathClosure = { dataSource.item(at: $0, completion: $1) }
        self.indexPathAtItemClosure = dataSource.indexPath(at:)
        self.dateHeaderAtSectionClosure = dataSource.dateHeader(at:)
        self.nextPageClosure = dataSource.nextPage
        self.didProcessedLastUpdatesClosure = dataSource.didProcessedUpdates
        self.getDidLoad = { dataSource.didLoad }
        self.setDidLoad = { dataSource.didLoad = $0 }
        self.getDidBecomeEmpty = { dataSource.didBecomeEmpty }
        self.setDidBecomeEmpty = { dataSource.didBecomeEmpty = $0 }
        self.getDidReceiveError = { dataSource.didReceiveError }
        self.setDidReceiveError = { dataSource.didReceiveError = $0 }
        self.getDidReceiveUpdates = { dataSource.didReceiveUpdates }
        self.setDidReceiveUpdates = { dataSource.didReceiveUpdates = $0 }
        self.getExecutionTrigger = { dataSource.executionTrigger }
        self.setExecutionTrigger = { dataSource.executionTrigger = $0 }
        self.updateVisibleItemClosure = dataSource.updateVisibleItem
        self.resumeClosure = dataSource.resume
        self.pauseClosure = dataSource.pause
    }
    
    public var isEmpty: Bool {
        return sectionsCountClosure() == 0
    }
    
    public var sectionsCount: Int {
        return sectionsCountClosure()
    }
    
    public func numberOfItemsInSectionAt(_ section: Int) -> Int {
        return numberOfItemsInSectionAtClosure(section)
    }
    
    public func item(at indexPath: IndexPath) -> Item? {
        return itemAtIndexPathClosure(indexPath)
    }
    
    public func indexPath(at item: Item) -> IndexPath? {
        return indexPathAtItemClosure(item)
    }
    
    public func item(at indexPath: IndexPath, completion: @escaping (Item?) -> Void) {
        return itemBlockAtIndexPathClosure(indexPath, completion)
    }
    
    public func dateHeader(at section: Int) -> Date? {
        return dateHeaderAtSectionClosure(section)
    }
    
    public func nextPage() {
        return nextPageClosure()
    }
    
    public func didProcessedUpdates() {
        return didProcessedLastUpdatesClosure()
    }
    
    public func updateVisibleItem(_ visibleItem: Item) {
        return updateVisibleItemClosure(visibleItem)
    }
    
    public var didLoad: AutoUpdatingChatDataSource.DidLoad? {
        get { return getDidLoad() }
        set { setDidLoad(newValue) }
    }
    
    public var didBecomeEmpty: AutoUpdatingChatDataSource.DidBecomeEmpty? {
        get { return getDidBecomeEmpty() }
        set { setDidBecomeEmpty(newValue) }
    }
    
    public var didReceiveError: AutoUpdatingChatDataSource.DidReceiveError? {
        get { return getDidReceiveError() }
        set { setDidReceiveError(newValue) }
    }
    
    public var didReceiveUpdates: AutoUpdatingChatDataSource.DidReceiveUpdates? {
        get { return getDidReceiveUpdates() }
        set { setDidReceiveUpdates(newValue) }
    }
    
    public var executionTrigger: ExecutionTrigger? {
        get { return getExecutionTrigger() }
        set { setExecutionTrigger(newValue) }
    }
    
    public func resume() {
        resumeClosure()
    }
    
    public func pause() {
        pauseClosure()
    }
}

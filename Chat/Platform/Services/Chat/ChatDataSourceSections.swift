//
//  ChatDataSourceIndexation.swift
//  Platform
//
//  Contains sorted sections, and also handles changes,
//  returning the correct IndexPath and IndexSet depending on the index of the main Results
//
//  Created by Ujin on 5/31/19.
//  Copyright © 2019 Cleveroad Inc. All rights reserved.
//

import RealmSwift
import Foundation

protocol ChatDataSourceSectionsDelegate: class {
    // the index of the element in the section and the date of this section,
    // depending on the index of the element in the general result
    func chatDataSourceSectionsGetItem(_ chatDataSourceSections: ChatDataSourceSections,
                                       from realmSnapshot: RealmSnapshot,
                                       for observationResultsIndex: Int) -> ChatDataSourceSections.Item
}

final class ChatDataSourceSections {
    typealias Item = (date: Date, index: Int)
    
    public struct Section: Hashable {
        let date: Date
        var count: Int
        
        static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.date == rhs.date
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(date)
        }
    }
    
    // MARK: - Properties
    var sorted: [Section] {
        var sections: [Section] = []
        syncQueue.sync { [nonatomicSortedSections] in sections = nonatomicSortedSections }
        return sections
    }
    var isExecuting: Bool {
        var executing = false
        syncQueue.sync { [nonatomicIsExecuting] in executing = nonatomicIsExecuting }
        return executing
    }
    
    private let pageItemsCount: Int
    private var nonatomicSortedSections: [Section] = []
    private var nonatomicIsExecuting = false
    private let syncQueue = DispatchQueue(label: "", qos: .userInitiated, attributes: .concurrent)
    
    private weak var delegate: ChatDataSourceSectionsDelegate?
    
    // MARK: - Life cycle
    required init(delegate: ChatDataSourceSectionsDelegate, pageItemsCount: Int) {
        self.pageItemsCount = pageItemsCount
        self.delegate = delegate
    }
    
    // MARK: - Thread safe sync
    private func performThreadSafeSync(_ action: @escaping (ChatDataSourceSections?) -> Void) {
        syncQueue.async(flags: .barrier) { [weak self] in
            action(self)
        }
    }
    
    // MARK: - Clear
    func clear() {
        performThreadSafeSync { `self` in
            self?.nonatomicSortedSections.removeAll()
        }
    }
    
    // MARK: - Process updates
    func processUpdates(deletations: [Int] = [],
                        insertations: [Int] = [],
                        modifications: [Int] = [],
                        observationItemsCount: Int,
                        performOnObservationThread: @escaping (@escaping() -> Void) -> Void,
                        performOnChatSnapshotThread: ((@escaping() -> Void) -> Void)? = nil,
                        completion: @escaping (AutoUpdatingChatDataSource.Updates?) -> Void) -> Void {
        nonatomicIsExecuting = true
        let completionWrap: (AutoUpdatingChatDataSource.Updates?) -> Void = { updates in
            self.nonatomicIsExecuting = false
            completion(updates)
        }
        guard let delegate = delegate,
            !modifications.isEmpty || !insertations.isEmpty || !deletations.isEmpty else {
                completionWrap(nil)
                return
        }
        var sections = nonatomicSortedSections
        var deletationsIndexes: AutoUpdatingChatDataSource.Deletations = (sections: .init(), items: [])
        var insertationsIndexes: AutoUpdatingChatDataSource.Insertations = (sections: .init(), items: [])
        var modificationsIndexes: AutoUpdatingChatDataSource.Modifications = []
        // insertations and modifications performed on same thread.
        let insertationsAndModifications: () -> Void = { [unowned self] in
            // Array(modifications.prefix(self.pageItemsCount)) - control amount of modifications
            // because on platform servicece uses a crappy code that modifies the entire result using a crutch
            modificationsIndexes = self.processModifications(for: sections, Array(modifications.prefix(self.pageItemsCount)), delegate: delegate)
            insertationsIndexes = self.processInsertations(for: &sections, insertations, delegate: delegate)
            self.performThreadSafeSync { `self` in
                self?.nonatomicSortedSections = sections
            }
            completionWrap(AutoUpdatingChatDataSource.Updates(insertations: insertationsIndexes,
                                                              deletations: deletationsIndexes,
                                                              modifications: modificationsIndexes))
        }
        if !deletations.isEmpty {
            performOnChatSnapshotThread? { [unowned self] in
                // deletations performed only on ChatSnapshotThread
                deletationsIndexes = self.processDeletations(for: &sections, deletations, delegate: delegate)
                performOnObservationThread {
                    insertationsAndModifications()
                }
            }
        } else {
            insertationsAndModifications()
        }
    }
    
    private func processDeletations(for sections: inout [Section],
                                    _ deletations: [Int],
                                    delegate: ChatDataSourceSectionsDelegate) -> AutoUpdatingChatDataSource.Deletations {
        guard !deletations.isEmpty else { return AutoUpdatingChatDataSource.Deletations(sections: .init(), items: []) }
        var deletedSections: IndexSet = .init()
        var deletedItems: [IndexPath] = .init()
        var dateSectionsToDelete: [Date] = []
        var sectionsToDeleteOriginalCount: [Int: Int] = [:]
        deletations.forEach { observationResultsIndex in
            let item = delegate.chatDataSourceSectionsGetItem(self, from: .observationPrevios, for: observationResultsIndex)
            if let section = sections.index(for: item.date) {
                if sectionsToDeleteOriginalCount[section] == nil {
                    sectionsToDeleteOriginalCount[section] = sections[section].count
                }
                // skip deletations that out of range
                if item.index >= sectionsToDeleteOriginalCount[section]! {
                    return
                }
                sections[section].count -= 1
                deletedItems.append(IndexPath(item: item.index, section: section))
                if sections[section].count == 0 {
                    dateSectionsToDelete.append(item.date)
                    deletedSections.update(with: section)
                }
                if sections[section].count < 0 {
                    fatalError("Negative items count")
                }
            }
        }
        dateSectionsToDelete.forEach {
            if let index = sections.index(for: $0) {
                sections.remove(at: index)
            }
        }
        deletedItems = deletedItems.filter { !deletedSections.contains($0.section) }
        return AutoUpdatingChatDataSource.Deletations(sections: deletedSections, items: deletedItems)
    }
    
    private func processInsertations(for sections: inout [Section],
                                     _ insertations: [Int],
                                     delegate: ChatDataSourceSectionsDelegate) -> AutoUpdatingChatDataSource.Insertations {
        guard !insertations.isEmpty else { return AutoUpdatingChatDataSource.Insertations(sections: .init(), items: []) }
        var insertedSections: IndexSet = .init()
        var insertedItems: [IndexPath] = .init()
        insertations.forEach { observationResultsIndex in
            let item = delegate.chatDataSourceSectionsGetItem(self, from: .observationCurrent, for: observationResultsIndex)
            if let section = sections.index(for: item.date) {
                sections[section].count += 1
                if !insertedSections.contains(section) {
                    insertedItems.append(IndexPath(item: item.index, section: section))
                }
            } else {
                let newSection = Section(date: item.date, count: 1)
                if sections.isEmpty {
                    insertedSections.update(with: 0)
                    sections.append(newSection)
                } else {
                    if sections[sections.count - 1].date > item.date {
                        insertedSections.update(with: sections.count)
                        sections.append(newSection)
                    } else {
                        if insertedSections.contains(0) {
                            fatalError("Pagination to bottom does not support yet")
                        } else {
                            sections.insert(newSection, at: 0)
                            insertedSections.update(with: 0)
                        }
                    }
                }
            }
        }
        return AutoUpdatingChatDataSource.Insertations(sections: insertedSections, items: insertedItems)
    }
    
    private func processModifications(for sections: [Section],
                                      _ modifications: [Int],
                                      delegate: ChatDataSourceSectionsDelegate) -> AutoUpdatingChatDataSource.Modifications {
        return modifications
            .compactMap {
                let item = delegate.chatDataSourceSectionsGetItem(self, from: .observationCurrent, for: $0)
                if let section = sections.index(for: item.date), item.index < sections[section].count { // skip modifications that out of range
                    return IndexPath(item: item.index, section: section)
                }
                return nil
        }
    }
}

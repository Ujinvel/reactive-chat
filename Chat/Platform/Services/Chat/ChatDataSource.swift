//
//  ChatDataSource.swift
//  Platform
//
//  A variation of reactive chat datasorse with unidirectional pagination,
//  changeset and lazy access to the elements from the database.
//  In general, before the item is drawn, the date is tooked for sorting,
//  but a full mapping occurs at the moment of item(at indexPath: )
//  The main logic is built on two equally sorted Results. One full - for tracking changes and another,
//  which is sorted by date (one section - one day). From these data, an array of sections is built,
//  where each section knows how many elements there are.
//
//  Created by Ujin on 5/30/19.
//  Copyright © 2019 Cleveroad Inc. All rights reserved.
//

import RealmSwift
import Foundation

enum RealmSnapshot {
    case observationCurrent, observationPrevios
}

final class ChatDataSource<Item, ManagedObject: DateteIdentifiable>: AutoUpdatingChatDataSource {
    typealias ObservationBuilder = (Realm) -> Results<ManagedObject>
    typealias SectionBlockBuilder = (Realm, Date) -> Results<ManagedObject>
    typealias TransformToDomain = (ManagedObject) throws -> Item
    typealias TransformToPlatform = (Item, Realm) -> ManagedObject?
    
    // MARK: - Properties
    // builders/mappers
    private let observationBuilder: ObservationBuilder
    private let sectionBlockBuilder: SectionBlockBuilder
    private let toDomain: TransformToDomain
    private let toPlatform: TransformToPlatform
    // realm
    // for managing the update, all references to realms must be strong
    private var currentSnapShot: RealmSnapshot {
        set {
            syncQueue.async(flags: .barrier) { [weak self] in
                self?.nonatomicCurrentSnapShot = newValue
            }
        }
        get {
            var snapshot: RealmSnapshot = .observationCurrent
            syncQueue.sync { [nonatomicCurrentSnapShot] in snapshot = nonatomicCurrentSnapShot }
            return snapshot
        }
    }
    private var nonatomicCurrentSnapShot: RealmSnapshot = .observationPrevios
    private var databaseThreadObservationCurrentRealm: Realm?// instance for result observation
    private var databaseThreadObservationPreviosRealm: Realm?// instance for previos result observation snapshot. Neaded for deletations update
    private var observationToken: NotificationToken?
    private var observationResults: Results<ManagedObject>?
    private let databaseBackgroundWorkerForCurrentSnapshot = BackgroundWorker(name: "databaseBackgroundWorkerForCurrentSnapshot")
    // since manage it is possible only with one realm on the thread,
    // we create a new one for saving the results snapshot of the previous iteration of the update
    private let databaseBackgroundWorkerForPreviosSnapshot = BackgroundWorker(name: "databaseBackgroundWorkerForPreviosSnapshot")
    private let syncQueue = DispatchQueue(label: "", qos: .userInitiated, attributes: .concurrent)
    // sections
    // all public properties an methods of ChatDataSourceSections are thread safe
    private lazy var sections: ChatDataSourceSections = {
        ChatDataSourceSections(delegate: self, pageItemsCount: nonatomicPageItemsCount)
    }()
    // pagination
    // must be called only from databaseBackgroundWorkerForPreviosSnapshot
    private var nonatomicUpdateIsExecuting: Bool {
        didSet {
            executionTrigger?(nonatomicUpdateIsExecuting)
        }
    }
    private var nonatomicVisibleItem: Item?// item, that must be in sections
    private let nonatomicScreensBeforePaginationStart: Int
    private let nonatomicPageItemsCount: Int
    // actions
    var didReceiveError: DidReceiveError?
    var didLoad: DidLoad?
    var didBecomeEmpty: DidBecomeEmpty?
    var didReceiveUpdates: DidReceiveUpdates?
    var executionTrigger: ExecutionTrigger?// only for initial indexation and pagination
    
    // MARK: - Life cycle
    init(observationBuilder: @escaping ObservationBuilder,// results must be sorted
        sectionBlockBuilder: @escaping SectionBlockBuilder,// results must be sorted
        toDomain: @escaping TransformToDomain,
        toPlatform: @escaping TransformToPlatform,
        pageItemsCount: Int = 40,
        screensBeforePaginationStart: Int = 0,
        visibleItem: Item? = nil) {
        self.observationBuilder = observationBuilder
        self.sectionBlockBuilder = sectionBlockBuilder
        self.toDomain = toDomain
        self.toPlatform = toPlatform
        self.nonatomicVisibleItem = visibleItem
        self.nonatomicPageItemsCount = pageItemsCount
        self.nonatomicScreensBeforePaginationStart = screensBeforePaginationStart
        self.nonatomicUpdateIsExecuting = false
        
        setupRealms()
    }
    
    deinit {
        
    }
    
    // MARK: - Table data source(all properties and functions are thread safe)
    var sectionsCount: Int {
        return sections.sorted.count
    }
    
    func numberOfItemsInSectionAt(_ section: Int) -> Int {
        return sections.sorted[safe: section]?.count ?? 0
    }
    
    func item(at indexPath: IndexPath) -> Item? {
        return await { signal in
            self.performOnDataBaseThread(realmSnapshot: currentSnapShot) { [weak self] realm in
                guard let self = self,
                    let date = self.sections.sorted[safe: indexPath.section]?.date,
                    let item = self.makeResults(for: date, realm: realm)?[safe: indexPath.item] else {
                        signal(nil)
                        return
                }
                do {
                    signal(try self.toDomain(item))
                } catch let error {
                    self.didReceiveError?(.init(error))
                    signal(nil)
                }
            }
        }
    }
    
    func item(at indexPath: IndexPath, completion: @escaping (Item?) -> Void) {
        performOnDataBaseThread(realmSnapshot: currentSnapShot) { [unowned self] realm in
            guard let date = self.sections.sorted[safe: indexPath.section]?.date,
                let item = self.makeResults(for: date, realm: realm)?[safe: indexPath.item] else {
                    completion(nil)
                    return
            }
            do {
                completion(try self.toDomain(item))
            } catch let error {
                self.didReceiveError?(.init(error))
                completion(nil)
                return
            }
        }
    }
    
    func indexPath(at item: Item) -> IndexPath? {
        return await { signal in
            self.performOnDataBaseThread(realmSnapshot: currentSnapShot) { [weak self] realm in
                guard let self = self,
                    let rmObject = self.toPlatform(item, realm),
                    let index = self.makeResults(for: rmObject.sentAt.dateAtStartOf(.day), realm: realm)?.index(of: rmObject),
                    let section = self.sections.sorted.index(for: rmObject.sentAt.dateAtStartOf(.day)),
                    index < self.sections.sorted[section].count else {
                        signal(nil)
                        return
                }
                signal(IndexPath(item: index, section: section))
            }
        }
    }
    
    func dateHeader(at section: Int) -> Date? {
        return sections.sorted[safe: section]?.date
    }
    
    func nextPage() {
        performOnDataBaseThread { [unowned self] realm in
            self.nonatomicVisibleItem = nil
            self.nextPage(results: self.observationBuilder(realm))
        }
    }
    
    func updateVisibleItem(_ visibleItem: Item) {
        performOnDataBaseThread { [unowned self] realm in
            self.nonatomicVisibleItem = visibleItem
            guard !self.sections.isExecuting else { return }
            self.updateWithVisibleItemIfNeaded()
        }
    }
    
    // must be called only when ui updates to prevent race conditions
    func didProcessedUpdates() {
        performOnDataBaseThread { [unowned self] _ in
            self.endIndexationUpdate {
                self.nonatomicUpdateIsExecuting = false
            }
        }
    }
    
    // MARK: - Pause/resume
    func pause() {
        setAutorefresh(false)
    }
    
    func resume() {
        performOnDataBaseThread { [weak self] _ in
            if self?.observationToken == nil {
                self?.makeDatabaseThreadResults { resultsToObserve in
                    guard self?.observationToken == nil else { return }
                    self?.observeResults(resultsToObserve)
                }
            } else {
                self?.setAutorefresh(true)
            }
        }
    }
    
    // MARK: - Realms
    private func setupRealms() {
        performOnDataBaseThread { [weak self] realm in
            self?.databaseThreadObservationCurrentRealm = realm
        }
        performOnDataBaseThread(realmSnapshot: .observationPrevios) { [weak self] realm in
            self?.databaseThreadObservationPreviosRealm = realm
            self?.databaseThreadObservationPreviosRealm?.autorefresh = false
        }
    }
    
    // stop following updates made in another thread. Result also does not change
    private func beginIndexationUpdate(completion: (() -> Void)? = nil) {
        setAutorefresh(false, completion: completion)
    }
    
    // We restore the monitoring and update Result.
    // All changes made between the cessation of observation and the restoration will come in as regular updates.
    private func endIndexationUpdate(completion: (() -> Void)? = nil) {
        setAutorefresh(true) { [weak self] in
            self?.currentSnapShot = .observationPrevios
            self?.updateWithVisibleItemIfNeaded()
            self?.nonatomicVisibleItem = nil
            completion?()
        }
    }
    
    // completion performs on databaseThreadObservationCurrentRealm
    private func setAutorefresh(_ autorefresh: Bool, completion: (() -> Void)? = nil) {
        let group = DispatchGroup()
        if autorefresh {
            group.enter()
            performOnDataBaseThread(realmSnapshot: .observationPrevios) { realm in
                realm.refresh()
                group.leave()
            }
        }
        group.enter()
        performOnDataBaseThread { databaseThreadRealm in
            databaseThreadRealm.autorefresh = autorefresh
            if autorefresh {
                databaseThreadRealm.refresh()
            }
            group.leave()
        }
        group.notify(queue: syncQueue) {
            self.performOnDataBaseThread { _ in
                completion?()
            }
        }
    }
    
    // MARK: - Perform wrapper
    private func performOnDataBaseThread(realmSnapshot: RealmSnapshot = .observationCurrent, _ action: @escaping (Realm) -> Void) {
        return autoreleasepool {
            var backgroundWorker: BackgroundWorker?
            switch realmSnapshot {
            case .observationCurrent:
                backgroundWorker = databaseBackgroundWorkerForCurrentSnapshot
            case .observationPrevios:
                backgroundWorker = databaseBackgroundWorkerForPreviosSnapshot
            }
            let backgroundWorkerAction: BackgroundWorker.Action = {
                var realmInstance: Realm?
                switch realmSnapshot {
                case .observationCurrent:
                    realmInstance = self.databaseThreadObservationCurrentRealm
                case .observationPrevios:
                    realmInstance = self.databaseThreadObservationPreviosRealm
                }
                if let realm = realmInstance {
                    action(realm)
                } else {
                    do {
                        action(try Realm())
                    } catch let error {
                        self.didReceiveError?(.init(error))
                    }
                }
            }
            backgroundWorker?.perform(action: backgroundWorkerAction)
        }
    }
    
    // MARK: - Make results
    private func makeDatabaseThreadResults(_ action: @escaping (Results<ManagedObject>) -> Void) {
        performOnDataBaseThread { [unowned self] realm in
            if let results = self.observationResults {
                action(results)
            } else {
                action(with(self.observationBuilder(realm)) {
                    self.observationResults = $0
                })
            }
        }
    }
    
    // unsafe method. Must be performed on databaseThread
    private func makeResults(for sectionDate: Date, realm: Realm) -> Results<ManagedObject>? {
        return sectionBlockBuilder(realm, sectionDate)
    }
    
    // unsafe method. Must be performed on databaseThread
    private func makeResults(realm: Realm) -> Results<ManagedObject>? {
        return observationBuilder(realm)
    }
    
    // MARK: - Observe results
    private func observeResults(_ results: Results<ManagedObject>) {
        observationToken = results.observe { [weak self] change in
            guard let `self` = self else { return }
            let performOnObservationThread: (@escaping () -> Void) -> Void = { block in
                self.performOnDataBaseThread() { _ in
                    block()
                }
            }
            let performOnChatSnapshotThread: (@escaping () -> Void) -> Void = { block in
                self.performOnDataBaseThread(realmSnapshot: RealmSnapshot.observationPrevios) { _ in
                    block()
                }
            }
            let processChanges: () -> Void = {
                switch change {
                case .initial(let results):
                    guard self.sections.sorted.isEmpty else {
                        self.didLoad?()
                        return
                    }
                    self.nonatomicUpdateIsExecuting = true
                    self.processInitial(results) {
                        self.didLoad?()
                    }
                case .update(_, let deletions, let insertions, let modifications):
                    self.sections.processUpdates(deletations: deletions,
                                                 insertations: insertions,
                                                 modifications: modifications,
                                                 observationItemsCount: results.count,
                                                 performOnObservationThread: performOnObservationThread,
                                                 performOnChatSnapshotThread: performOnChatSnapshotThread) { updates in
                                                    self.currentSnapShot = .observationCurrent
                                                    if results.isEmpty && !deletions.isEmpty {
                                                        self.didBecomeEmpty?()
                                                    } else if let updates = updates {
                                                        self.didReceiveUpdates?(updates)
                                                    } else {
                                                        self.endIndexationUpdate()
                                                    }
                    }
                case .error(let error):
                    self.endIndexationUpdate {
                        self.didReceiveError?(.init(error))
                    }
                }
            }
            self.beginIndexationUpdate(completion: processChanges)
        }
    }
    
    private func processInitial(_ results: Results<ManagedObject>, completion: @escaping () -> Void) {
        guard !results.isEmpty else {
            completion()
            return
        }
        var baseIndex = 0
        if let visibleItem = nonatomicVisibleItem,
            let realm = databaseThreadObservationCurrentRealm,
            let visibleObject = toPlatform(visibleItem, realm) {
            guard let visibleObjectIndex = results.index(of: visibleObject) else {
                self.didReceiveError?(DomainError(ChatDataSourceError.visibleItem("\(visibleObject.self)", visibleObject.localId as! String)))
                return
            }
            nonatomicVisibleItem = nil
            baseIndex = visibleObjectIndex
        }
        let performOnObservationThread: (@escaping () -> Void) -> Void = { [weak self] block in
            self?.performOnDataBaseThread() { _ in
                block()
            }
        }
        let performOnChatSnapshotThread: (@escaping () -> Void) -> Void = { [weak self] block in
            self?.performOnDataBaseThread(realmSnapshot: RealmSnapshot.observationPrevios) { _ in
                block()
            }
        }
        let performCompletion: (AutoUpdatingChatDataSource.Updates?) -> Void = { _ in
            completion()
        }
        sections.processUpdates(insertations: results.makeIndexes(0...baseIndex + nonatomicPageItemsCount),
                                observationItemsCount: results.count,
                                performOnObservationThread: performOnObservationThread,
                                performOnChatSnapshotThread: performOnChatSnapshotThread,
                                completion: performCompletion)
    }
    
    // MARK: - Pagination
    private func nextPage(results: Results<ManagedObject>) {
        guard let databaseThreadObservationCurrentRealm = databaseThreadObservationCurrentRealm,
            !nonatomicUpdateIsExecuting && !self.sections.sorted.isEmpty else { return }
        let startIndex = lastCashedIndex(for: databaseThreadObservationCurrentRealm) + 1
        processPageInserations(results.makeIndexes(startIndex...startIndex + nonatomicPageItemsCount))
    }
    
    // non thread safe. Must be performed only on databaseThreadObservationCurrentRealm thread
    private func processPageInserations(_ insertations: [Int]) {
        let startObserveIfNeaded: () -> Void = { [weak self] in
            if self?.observationToken == nil {
                self?.makeDatabaseThreadResults { resultsToObserve in
                    self?.observeResults(resultsToObserve)
                }
            }
        }
        let performOnObservationThread: (@escaping () -> Void) -> Void = { [weak self] block in
            self?.performOnDataBaseThread() { _ in
                block()
            }
        }
        let performOnChatSnapshotThread: (@escaping () -> Void) -> Void = { [weak self] block in
            self?.performOnDataBaseThread(realmSnapshot: RealmSnapshot.observationPrevios) { _ in
                block()
            }
        }
        let processInsertations: () -> Void = { [unowned self] in
            self.sections.processUpdates(insertations: insertations,
                                         observationItemsCount: self.observationResults?.count ?? 0,
                                         performOnObservationThread: performOnObservationThread,
                                         performOnChatSnapshotThread: performOnChatSnapshotThread) { updates in
                                            self.currentSnapShot = .observationCurrent
                                            if let updates = updates {
                                                self.didReceiveUpdates?(updates)
                                                startObserveIfNeaded()
                                            } else {
                                                startObserveIfNeaded()
                                                self.endIndexationUpdate()
                                            }
            }
        }
        if !insertations.isEmpty {
            nonatomicUpdateIsExecuting = true
        }
        beginIndexationUpdate(completion: processInsertations)
    }
    
    // non thread safe. Must be performed only on realm thread
    private func lastCashedIndex(for realm: Realm) -> Int {
        guard !sections.sorted.isEmpty else { return 0 }
        let date = sections.sorted[sections.sorted.count - 1].date
        let count = sections.sorted[sections.sorted.count - 1].count
        guard let sectionsResults = makeResults(for: date, realm: realm) else {
            fatalError(ChatDataSourceError.sectionResults(date).localizedDescription)
        }
        guard let observationResults = makeResults(realm: realm) else {
            fatalError(ChatDataSourceError.observationCurrentResults.localizedDescription)
        }
        guard let index = observationResults.index(of: sectionsResults[count - 1]) else {
            fatalError(ChatDataSourceError.observationCurrentResultsIndexOutOfRange(count - 1, observationResults.count).localizedDescription)
        }
        return index
    }
    
    private func updateWithVisibleItemIfNeaded() {
        guard let visibleItem = nonatomicVisibleItem else { return }
        if let databaseThreadObservationCurrentRealm = self.databaseThreadObservationCurrentRealm,
            let results = self.makeResults(realm: databaseThreadObservationCurrentRealm),
            let platformItem = self.toPlatform(visibleItem, databaseThreadObservationCurrentRealm) {
            if let index = results.index(of: platformItem) {
                let lastIndex = self.lastCashedIndex(for: databaseThreadObservationCurrentRealm)
                if index > lastIndex {
                    let startIndex = lastIndex != 0 ? lastIndex + 1 : 0
                    self.processPageInserations(results.makeIndexes(startIndex...index + Int(self.nonatomicPageItemsCount / 2)))
                }
            } else {
                self.didReceiveError?(DomainError(ChatDataSourceError.visibleItem("\(platformItem.self)", platformItem.localId as! String)))
            }
        }
    }
}

// MARK: - ChatDataSourceSectionsDelegate
extension ChatDataSource: ChatDataSourceSectionsDelegate {
    func chatDataSourceSectionsGetItem(_ chatDataSourceSections: ChatDataSourceSections,
                                       from realmSnapshot: RealmSnapshot,
                                       for observationResultsIndex: Int) -> ChatDataSourceSections.Item {
        var realmInstance: Realm?
        switch realmSnapshot {
        case .observationCurrent:
            if Thread.current != databaseBackgroundWorkerForCurrentSnapshot.thread {
                fatalError(ChatDataSourceError.wrongThreadForSnapshotCurrentRealm.localizedDescription)
            }
            realmInstance = databaseThreadObservationCurrentRealm
        case .observationPrevios:
            if Thread.current != databaseBackgroundWorkerForPreviosSnapshot.thread {
                fatalError(ChatDataSourceError.wrongThreadForSnapshotPreviosRealm.localizedDescription)
            }
            realmInstance = databaseThreadObservationPreviosRealm
        }
        guard let realm = realmInstance else {
            fatalError(ChatDataSourceError.noRealm.localizedDescription)
        }
        guard let results = makeResults(realm: realm) else {
            fatalError(ChatDataSourceError.observationCurrentResults.localizedDescription)
        }
        guard let object = results[safe: observationResultsIndex] else {
            fatalError(ChatDataSourceError.observationCurrentResultsIndexOutOfRange(observationResultsIndex, results.count).localizedDescription)
        }
        guard let index = makeResults(for: object.sentAt.dateAtStartOf(.day), realm: realm)?.index(of: object) else {
            fatalError(ChatDataSourceError.noItem(object.localId as! String, object.sentAt.dateAtStartOf(.day)).localizedDescription)
        }
        return (date: object.sentAt.dateAtStartOf(.day), index: index)
    }
}

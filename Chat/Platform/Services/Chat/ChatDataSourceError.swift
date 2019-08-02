//
//  ChatDataSourceError.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

enum ChatDataSourceError: Error {
    case visibleItem(String, String)// no item that must be visible
    // internal errors for debug associated with incorrectly filtered Results or internal logic
    case sectionResults(Date)// no results for the current date. Perhaps incorrectly sorted sections
    case observationCurrentResults// can't make main observation results
    case observationCurrentResultsIndexOutOfRange(Int, Int)// no object by index. Perhaps incorrect counting of elements in the section
    case wrongThreadForSnapshotPreviosRealm
    case wrongThreadForSnapshotCurrentRealm
    case noRealm
    case noItem(String, Date)// no item in section result.
}

extension ChatDataSourceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .visibleItem(let item, let id):
            return "No item \(item) with id: \(id) on current result."
        case .sectionResults(let date):
            return "No results for date: \(date)."
        case .observationCurrentResults:
            return "Can`t make observation results."
        case .observationCurrentResultsIndexOutOfRange(let index, let count):
            return "Trying to request object at index: \(index) in observationResult, but result`s coutnt is \(count)."
        case .wrongThreadForSnapshotPreviosRealm:
            return "Wrong thread, mus be databaseBackgroundWorkerForPreviosSnapshot.thread."
        case .wrongThreadForSnapshotCurrentRealm:
            return "Wrong thread, mus be databaseBackgroundWorkerForCurrentSnapshot.thread."
        case .noRealm:
            return "No realm instanse."
        case .noItem(let id, let date):
            return "No object with id: \(id) in sections results for date: \(date)"
        }
    }
}


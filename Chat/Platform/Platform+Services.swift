//
//  Platform+Services.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation
import RealmSwift

extension Platform {
    static func setupServices(configuration: PlatformEnvironment) {
        setupFabric()
        setupRealm()
        setupGooglePlaces(key: configuration.google.placesKey)
        setupFirebase()
    }
    
    private static func setupFabric() {
        //Fabric.with([Crashlytics.self])
    }
    
    private static func setupGooglePlaces(key: String) {
        //GMSPlacesClient.provideAPIKey(key)
    }
    
    private static func setupRealm() {
        let cachesDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let cachesDirectoryURL = NSURL(fileURLWithPath: cachesDirectoryPath)
        let fileURL = cachesDirectoryURL.appendingPathComponent("Default.realm")
        let config = Realm.Configuration(fileURL: fileURL,
                                         schemaVersion: 1,
                                         migrationBlock: Platform.migrateDatabase)
        
        Realm.Configuration.defaultConfiguration = config
        do {
            let realm = try Realm()
            if let folderPath = realm.configuration.fileURL?.deletingLastPathComponent().path {
                print("folderPath - \(folderPath)")
                try FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none],
                                                      ofItemAtPath: folderPath)
            }
        } catch let error {
            //Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    private static func setupFirebase() {
        //FirebaseApp.configure()
    }
    
    private static func migrateDatabase(_ migration: Migration, _ oldSchemaVersion: UInt64) {
        // We haven’t migrated anything yet, so oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
            // Nothing to do!
            // Realm will automatically detect new properties and removed properties
            // And will update the schema on disk automatically
        }
    }
}


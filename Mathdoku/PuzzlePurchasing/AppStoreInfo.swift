//
//  AppStoreInfo.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 2/22/22.
//  Copyright © 2022 Taylor Geisse. All rights reserved.
//

import Foundation

// MARK: Enumerator for the StoreInfo JSON to simplify necessary information
enum SavedStoreInformation: String, CaseIterable {
    case version
    case appStoreUrl = "trackViewUrl"
    case currentVersionReleaseDate
}

class AppStoreInfo {
    // MARK: - Singleton
    static let sharedInstance = AppStoreInfo()
    
    // MARK: - Class properties
    lazy var storeInfo: [SavedStoreInformation: String] = saveStoreInformation()
    var updateAvailable: Bool {
        guard let installedVersion = MainBundleInformation.version.string,
              let storeVersion = storeInfo[.version] else {
            return false
        }
        DebugUtil.print("Installed Version: \(installedVersion)  .....  Store Version: \(storeVersion)")
        return installedVersion != storeVersion
    }
    
    // MARK: - Private helper Functions
    private func getStoreInfo() -> JSON? {
        DebugUtil.print("Requesting store information")
        
        guard let identifier = MainBundleInformation.identifier.string,
                let storeUrl = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            
            return nil
        }
        
        do {
            let data = try Data(contentsOf: storeUrl)
            let json = try JSON(data: data, options: [.allowFragments])
            
            return json
        } catch (_) {
            return nil
        }
    }
    
    private func saveStoreInformation() -> [SavedStoreInformation: String] {
        guard let storeInfo = getStoreInfo()?["results"][0] else { return [:] }
        
        // DebugUtil.print(storeInfo)
        var res = [SavedStoreInformation: String]()
        
        for element in SavedStoreInformation.allCases {
            if let info = storeInfo[element.rawValue].string {
                DebugUtil.print(element, ": ", info)
                res[element] = info
            }
        }
        
        return res
    }
}

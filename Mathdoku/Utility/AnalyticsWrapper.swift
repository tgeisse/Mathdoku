//
//  AnalyticsWrapper.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 12/12/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import FirebaseAnalytics

struct AnalyticsWrapper {
    enum EventType {
        case selectContent
        case appOpen
        
        var mapped: String {
            switch self {
            case .selectContent: return AnalyticsEventSelectContent
            case .appOpen: return AnalyticsEventAppOpen
            }
        }
    }
    
    enum ContentType: String {
        case userSetting    =   "type-userSetting"
        case puzzleLoad     =   "type-puzzleLoad"
        case puzzlePlayed   =   "type-puzzlePlayed"
        case featureUsage   =   "type-featureUsage"
        case presented      =   "type-presented"
    }
    
    static func logEvent(_ type: EventType,
                         contentType: ContentType? = nil,
                         id: String? = nil,
                         name: String? = nil,
                         variant: String? = nil) {
        
        DispatchQueue.global(qos: .utility).async {
            var parameters: [String: String] = [:]
            var debugPrint = "\(type)"
            
            if let typeRawValue = contentType?.rawValue {
                parameters[AnalyticsParameterContentType] = typeRawValue
                debugPrint += ".\(typeRawValue)"
            }
            if id != nil {
                parameters[AnalyticsParameterItemID] = id!
                debugPrint += ".\(id!)"
            }
            if name != nil {
                parameters[AnalyticsParameterItemName] = name!
                debugPrint += ".\(name!)"
            }
            if variant != nil {
                parameters[AnalyticsParameterItemVariant] = variant!
                debugPrint += ".\(variant!)"
            }
            
            DebugUtil.print("Logging event \(debugPrint)")
            
            Analytics.logEvent(type.mapped, parameters: parameters)
        }
    }
}

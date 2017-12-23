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
        
        var mappedType: String {
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
            
            if contentType != nil {
                parameters[AnalyticsParameterContentType] = contentType!.rawValue
            }
            if id != nil {
                parameters[AnalyticsParameterItemID] = id!
            }
            if name != nil {
                parameters[AnalyticsParameterItemName] = name!
            }
            if variant != nil {
                parameters[AnalyticsParameterItemVariant] = variant!
            }
            
            Analytics.logEvent(type.mappedType, parameters: parameters)
        }
    }
}

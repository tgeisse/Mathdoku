//
//  CrashWrapper.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 3/16/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Foundation
import Bugsnag

struct CrashWrapper {
    enum BreadcrumbType {
        case log
        case manual
        case navigation
        case process
        case request
        case state
        case user
        
        var mapped: BSGBreadcrumbType {
            switch self {
            case .log: return .log
            case .manual: return .manual
            case .navigation: return .navigation
            case .process: return .process
            case .request: return .request
            case .state: return .state
            case .user: return .user
            }
        }
    }
    
    enum Severity {
        case error
        case info
        case warning
        
        var mapped: BSGSeverity {
            switch self {
            case .error: return .error
            case .info: return .info
            case .warning: return .warning
            }
        }
    }
    
    static func notifyError(domain: String, code: Int, userInfo: [String:Any]? = nil, severity: Severity? = nil) {
        CrashWrapper.notifyError(NSError(domain: domain, code: code, userInfo: userInfo), severity: severity)
    }
    
    static func notifyError(_ error: Error, severity: Severity? = nil) {
        Bugsnag.notifyError(error) { (report) in
            if severity != nil {
                report.severity = severity!.mapped
            }
        }
    }
    
    static func notifyException(name: String, reason: String?, userInfo: [String:Any]? = nil, severity: Severity? = nil) {
        CrashWrapper.notifyException(NSException(name: NSExceptionName(name), reason: reason, userInfo: userInfo), severity: severity)
    }
    
    static func notifyException(_ exception: NSException, severity: Severity? = nil) {
        Bugsnag.notify(exception) { (report) in
            if severity != nil {
                report.severity = severity!.mapped
            }
        }
    }
    
    static func setUser(id: String, withName name: String = "", andEmail email: String = "") {
        Bugsnag.configuration()?.setUser(id, withName: name, andEmail: email)
    }
    
    static func leaveBreadcrumb(withName name: String, withType type: BreadcrumbType = .manual, withMetadata metadata: [AnyHashable:Any] = [:]) {
        Bugsnag.leaveBreadcrumb { (crumb) in
            crumb.name = name
            crumb.type = type.mapped
            crumb.metadata = metadata
        }
    }
    
    static func leaveBreadcrumb(withMessage message: String) {
        Bugsnag.leaveBreadcrumb(withMessage: message)
    }
    
    static func leaveBreadcrumb(forNotificationName notificationName: String) {
        Bugsnag.leaveBreadcrumb(forNotificationName: notificationName)
    }
    
    static func addAttribute(_ attribute: String, withValue value: String? = "", toTabWithName tabName: String) {
        Bugsnag.addAttribute(attribute, withValue: value, toTabWithName: tabName)
    }
    
    static func clearTab(withName tabName: String) {
        Bugsnag.clearTab(withName: tabName)
    }
}

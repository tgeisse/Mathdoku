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
}

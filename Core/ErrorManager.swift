//
//  ErrorManager.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/22/26.
//

import Foundation

enum ErrorManager: Error {
    case permissionDenied
    case fileNotFound(String)
    case parsingError
    case diskFull
    case unknown(Error)
}

extension ErrorManager: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "error_permission_denied".localized
        case .fileNotFound(let path):
            return String(format: "error_file_not_found".localized, path)
        case .parsingError:
            return "error_parsing_config".localized
        case .diskFull:
            return "error_disk_full".localized
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "permission_denied_suggestion".localized
        case .diskFull:
            return "disk_full_suggestion".localized
        case .fileNotFound:
            return "file_not_found_suggestion".localized
        default:
            return "uknown_suggestion".localized
        }
    }
    
    var failureReason: String? {
        switch self {
        case .permissionDenied:
            return "error_permission_title".localized
        default:
            return "error_generic_title".localized
        }
    }
}

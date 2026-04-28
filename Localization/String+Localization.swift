//
//  String+Localization.swift
//  NovaClean
//
//  Created by Arnaldo Baumanis on 4/21/26.
//

import Foundation

extension String {
    /// Returns the translation of the string based on the current language of the device.
    /// If the key does not exist, it returns the original string.
    /// Use @MainActor to make the property accessible from the UI, but mark it as 'not isolated' so the Enum can use it without thread context issues
    nonisolated var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

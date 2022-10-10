//
//  STPLocalizedString.swift
//  StripePaymentSheet
//

import Foundation
@_spi(STP) import StripeCore

@inline(__always) func STPLocalizedString(_ key: String, _ comment: String?) -> String {
    return STPLocalizationUtils.localizedStripeString(forKey: key, bundleLocator: StripePaymentSheetBundleLocator.self)
}

//
//  SheetFooterView.swift
//  StripePaymentSheet
//
//  Created by Virginia Cook on 12/12/23.
//

import Foundation
@_spi(STP) import StripeCore
@_spi(STP) import StripeUICore
import UIKit
/// For internal SDK use only
@objc(STP_Internal_SheetFooterView)
class SheetFooterView: UIView {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12.0
        return stackView
    }()
    
    private let topLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1.00)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
        return line
    }()
    
    private let button: UIView

    /// Space below the button when the sheet has no bottom safe area of its own (an iPad form sheet,
    /// a device without a home indicator). With a bottom safe area, the safe area is the margin.
    static let bottomPadding: CGFloat = 20.0
    private var bottomConstraint: NSLayoutConstraint?

    // MARK: - Initializers
    
    init(button: UIView) {
        self.button = button
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.button = UIView()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(topLine)
        
        // Create a container view for the button with horizontal margins
        let buttonContainerView = UIView()
        buttonContainerView.addSubview(button)
        
        // Set up constraints for the button inside the container view
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor, constant: PaymentSheetUI.defaultPadding),
            button.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor, constant: -PaymentSheetUI.defaultPadding),
            button.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            button.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor)
        ])
        
        stackView.addArrangedSubview(buttonContainerView)
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint: NSLayoutConstraint
        
        if #available(iOS 11.0, *) {
            // Check if the device has a bottom safe area inset
            let window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
            if let window {
                let bottomSafeAreaInset = window.safeAreaInsets.bottom
                if bottomSafeAreaInset > 0 {
                    // Device has a bottom safe area inset, no need for additional padding
                    bottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
                } else {
                    // Device does not have a bottom safe area inset, add padding
                    bottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
                }
            } else {
                bottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
            }
        } else {
            // Fallback for earlier iOS versions
            bottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        }
        
        self.bottomConstraint = bottomConstraint
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            bottomConstraint
        ])
    }

    /// Called by the sheet container with its own bottom safe area, which is what the footer sits on.
    /// The window's safe area is wrong for an iPad form sheet: the window has a home indicator inset,
    /// but the sheet ends above it, so the button would touch the sheet's bottom edge.
    func updateBottomPadding(sheetBottomSafeArea: CGFloat) {
        let constant = sheetBottomSafeArea > 0 ? 0.0 : -Self.bottomPadding
        guard let bottomConstraint, bottomConstraint.constant != constant else { return }
        bottomConstraint.constant = constant
    }
}

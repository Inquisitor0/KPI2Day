//
//  AlertPresenter.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 13.05.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import SCLAlertView

class AlertPresenter {
    
    typealias AlertPresenterClosure = (() -> Void)
    private static var appearanceStyle = SCLAlertView.SCLAppearance(kWindowWidth: UIScreen.main.bounds.width * 0.75,
                                                                    kButtonHeight: 50.0,
                                                                    showCloseButton: false)

    static func showErrorAlert(title: String) {
        let alert = SCLAlertView(appearance: appearanceStyle)
        alert.addButton("OK", action: {})
        alert.showError("Ooops", subTitle: title)
    }
    
    static func showConfirmationAlert(title: String,
                                      subtitle: String,
                                      confirmClosure: @escaping AlertPresenterClosure = {}) {
        let alert = SCLAlertView(appearance: appearanceStyle)
        alert.addButton("Confirm", action: confirmClosure)
        alert.addButton("Cancel", backgroundColor: .red, textColor: .white, showTimeout: nil, action: {})
        alert.showInfo(title, subTitle: subtitle)
    }
}

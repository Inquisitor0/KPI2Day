//
//  SelectGroupVC.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 13.05.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import PKHUD

class SelectGroupVC: UIViewController {

    private var contentView = SelectGroupView()
    private let viewModel = SelectGroupVM()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.okButton.addTarget(self, action: #selector(didPressOkButton), for: .touchUpInside)
    }
    
    @objc private func didPressOkButton() {
        guard let text = contentView.textField.text, !text.isEmpty else { return }
        view.endEditing(true)
        requestGroup(name: text.lowercased())
    }
    
    private func requestGroup(name: String) {
        HUD.show(.progress)
        viewModel.loadGroup(name: name) { (groupId, errorDescription) in
            
            DispatchQueue.main.async {
                
                HUD.hide()
                
                if let errorDesc = errorDescription {
                    AlertPresenter.showErrorAlert(title: errorDesc)
                    return
                } else if let id = groupId {
                    AppDataManager.shared.updateGroup(name: name, id: id)
                    return
                } else {
                    return
                }
            }
        }
    }
}

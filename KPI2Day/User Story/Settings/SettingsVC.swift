//
//  SettingsVC.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 16.05.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import Eureka
import SwiftyUserDefaults

fileprivate struct TableTags {
    static let tableGridViewSwitcher = "tableGridViewSwitcher"
}

class SettingsVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        setupForm()
    }
    
    private func setupForm() {
        form
        +++ Section("Group info")
        <<< LabelRow().cellSetup({ (_, row) in
            row.title = "Current group"
            row.value = AppDataManager.shared.currentGroupName?.uppercased() ?? "Undefined"
        })
        
        <<< ButtonRow() { row in
            row.title = "Change group"
            }.onCellSelection({ (_, _) in
                AlertPresenter.showConfirmationAlert(title: "Change group",
                                                     subtitle: "Are you sure?",
                                                     confirmClosure: {
                    AppDataManager.shared.flush()
                })
        })
        
        +++ Section("Display options")
            <<< SwitchRow(TableTags.tableGridViewSwitcher) { row in
                row.title = "Grid view"
                row.value = AppDataManager.shared.isGridViewEnabled.value
                }.onChange({ row in
                    guard let value = row.value else { return }
                    
                    AppDataManager.shared.isGridViewEnabled.value = value
                    Defaults[.gridViewEnabled] = value
                })
    }
}

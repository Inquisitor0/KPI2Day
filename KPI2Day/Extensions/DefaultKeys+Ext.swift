//
//  DefaultKeys+Ext.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 13.05.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let groupId = DefaultsKey<String?>("groupId")
    static let groupName = DefaultsKey<String?>("groupName")
    static let gridViewEnabled = DefaultsKey<Bool>("gridViewEnabled")
}

extension UserDefaults {
    
    static func reset() {
        Defaults[.groupId] = nil
        Defaults[.groupName] = nil
        Defaults[.gridViewEnabled] = false
    }
}


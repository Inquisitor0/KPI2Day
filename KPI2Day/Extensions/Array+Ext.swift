//
//  Array+Ext.swift
//  KPI2Day
//
//  Created by Inquisitor on 08.07.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import Foundation
import RealmSwift

extension List where Element == Teacher {
    func containsById(_ id: Int) -> Bool {
        return self.contains { $0.id == id }
    }
}

extension List where Element == Group {
    func containsById(_ id: Int) -> Bool {
        return self.contains { $0.id == id }
    }
}

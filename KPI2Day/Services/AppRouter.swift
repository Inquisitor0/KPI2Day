//
//  AppRouter.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 07.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import RxSwift
import SwiftyUserDefaults

class AppRouter {
    
    private static let bag = DisposeBag()
    
    static func showStart() {
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = StartVC()
    }
    
    static func prepareUserFlow() {

        AppDataManager.shared.currentGroupId.asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (groupId) in
                guard groupId != nil else { showGroupSelection(); return; }
                showStudentTabBar()
            }, onError: { (error) in
                return
            })
            .disposed(by: bag)
    }

    private static func showStudentTabBar() {
        guard let groupId = AppDataManager.shared.currentGroupId.value else { showGroupSelection(); return; }
        let mainTabBar = ESTabBarController.defaultStudentTabBar(groupId: groupId)
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = mainTabBar
    }
    
    private static func showGroupSelection() {
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = SelectGroupVC()
    }
}


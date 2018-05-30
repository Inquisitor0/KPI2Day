//
//  StartVC.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 13.05.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit

class StartVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppRouter.prepareUserFlow()
    }
    
    // TODO: (alex) Add image view similar to the splash screen
}

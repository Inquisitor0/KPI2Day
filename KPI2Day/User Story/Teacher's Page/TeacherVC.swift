//
//  TeacherVC.swift
//  KPI2Day
//
//  Created by Inquisitor on 01.06.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit


class TeacherVC: UIViewController {

    private let teacher: Teacher
    
    init(teacher: Teacher) {
        self.teacher = teacher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

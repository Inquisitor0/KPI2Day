//
//  LessonVC.swift
//  KPI2Day
//
//  Created by Inquisitor on 01.06.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit

class LessonVC: UIViewController {
    
    private let lesson: Lesson
    private let contentView = LessonView()
   
    override func loadView() {
        view = contentView
    }
    
    init(lesson: Lesson) {
        self.lesson = lesson
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        title = lesson.discipline?.name ?? "Lesson"
        contentView.update(with: LessonViewModel(lesson: lesson))
        contentView.delegate = self
    }
}

extension LessonVC: LessonViewDelegate {
    func didPressTeacherButton() {
        guard let teacher = lesson.teachers.first else { return }
        let scheduleVC = ScheduleVC(type: .teacher(id: teacher.id))
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
}

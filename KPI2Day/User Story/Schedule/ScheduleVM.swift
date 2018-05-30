
//
//  ScheduleVM.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 07.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import Moya
import CocoaLumberjack
import RxSwift
import SwiftyJSON
import RealmSwift

protocol ScheduleVMDelegate: class {
    func didUpdateSchedule()
    func didRecieveError(error: Error)
}

class ScheduleVM {
    
    typealias scheduleCompletion = ((Error?) -> Void)
    
    weak var delegate: ScheduleVMDelegate?
    
    private let bag = DisposeBag()
    private let provider = OnlineProvider<AppNetworkService>()
    
    private var lessons: Results<Lesson>!
    private var token: NotificationToken?
    private let realm = try! Realm()
    
    var firstWeekLessons: [Int: [Lesson]] = [:]     // For easy UITableView setup
    var secondWeekLessons: [Int: [Lesson]] = [:]    // Lessons ordered by weekday
    
    func lessons(forWeek index: Int) -> [Int: [Lesson]] {
        return index == 0 ? firstWeekLessons : secondWeekLessons
    }
    
    init() {
        lessons = realm.objects(Lesson.self)
        observeSchedule()
    }
    
    private func observeSchedule() {
        token = lessons?.observe({ [unowned self] (change) in
            self.setupSchedule()
            
            if self.lessons != nil, !self.lessons.isEmpty {
                DispatchQueue.main.async { [unowned self] in
                    self.delegate?.didUpdateSchedule()
                }
            }
        })
    }
    
    private func observeRealmErrors() {
        RealmService.errors.asObservable()
        .subscribe(onNext: { [unowned self] (realmError) in
            guard let error = realmError else { return }
            self.delegate?.didRecieveError(error: error)
        })
        .disposed(by: bag)
    }
    
    func loadFullSchedule(groupId: String) {
        
        guard lessons != nil, !lessons.isEmpty else {
            self.downloadSchedule(groupId: groupId)
            return
        }
    }
    
    private func downloadSchedule(groupId: String) {
        self.provider.request(.loadFullSchedule(groupId: groupId))
            .subscribe(onSuccess: { [unowned self] response in
                self.setupLessonsDictionaries(response)
            }) { error in
                DispatchQueue.main.async {
                    self.delegate?.didRecieveError(error: error)
                }
            }
            .disposed(by: self.bag)
    }
    
    private func setupSchedule() {
        guard lessons != nil else { return }
        
        for lesson in lessons {
            addLesson(lesson: lesson, week: lesson.weekNumber, day: lesson.day)
        }
    }
    
    private func addLesson(lesson: Lesson, week: Int, day: Int) {
        if week == 1 {
            if self.firstWeekLessons[day] != nil {
                self.firstWeekLessons[day]!.append(lesson)
            } else {
                self.firstWeekLessons[day] = [lesson]
            }
        } else if week == 2 {
            if self.secondWeekLessons[day] != nil {
                self.secondWeekLessons[day]!.append(lesson)
            } else {
                self.secondWeekLessons[day] = [lesson]
            }
        }
    }
    
    private func setupLessonsDictionaries(_ data: Any) {
        
        let json = JSON(data)
        let weeksDict = json["data"].dictionaryValue
        
        var lessons: [Lesson] = []
        
        for (week, weekJson) in weeksDict {
            
            guard let weekIndex = Int(week) else { continue }
            let daysDict = weekJson.dictionaryValue
            
            for (day, dayJson) in daysDict {
                
                guard let dayIndex = Int(day) else { continue }
                let lessonsDict = dayJson.dictionaryValue
                
                for (_, lessonJSON) in lessonsDict {
                    
                    let lesson = Lesson(json: lessonJSON, day: dayIndex, week: weekIndex)
                    lessons.append(lesson)
                }
            }
        }
        
        saveLessonsLocally(lessons: lessons)
    }
    
    private func saveLessonsLocally(lessons: [Lesson]) {
        AppDataManager.shared.saveLessons(lessons)
    }
}

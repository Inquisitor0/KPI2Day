
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
import PKHUD

protocol ScheduleVMDelegate: class {
    func didUpdateSchedule()
    func didRecieveError(error: Error)
}

struct LessonsData {
    var firstWeekLessons: [Int: [Lesson]] = [:]     // For easy UITableView setup
    var secondWeekLessons: [Int: [Lesson]] = [:]    // Lessons ordered by weekday
}

class ScheduleVM {
    
    typealias scheduleCompletion = ((Error?) -> Void)
    
    weak var delegate: ScheduleVMDelegate?
    
    let scheduleType: ScheduleType
    
    private let bag = DisposeBag()
    private let provider = OnlineProvider<AppNetworkService>()
    
    private var token: NotificationToken?
//    private let realm = try! Realm()
    
    var data = Variable<LessonsData>(LessonsData())
    
    private var lessons: Results<Lesson>! {
        didSet {
            if lessons.isEmpty {
                downloadSchedule()
            } else {
                setupSchedule()
            }
        }
    }
    
    func lessons(forWeek index: Int) -> [Int: [Lesson]] {
        return index == 0 ? data.value.firstWeekLessons : data.value.secondWeekLessons
    }
    
    init(type: ScheduleType) {
        self.scheduleType = type
        fetchSchedule()
    }
    
    
    private func fetchSchedule() {
        switch scheduleType {
        case .group:
            RealmService.fetchLessons { [unowned self] res in
                self.lessons = res
            }
        case .teacher(let id):
            // TODO: Filter by TeacherID
            RealmService.fetchLessons { [unowned self] res in
                self.lessons = res
            }
        }
    }
    
    // Fetch from Realm
//    private func observeSchedule() {
//        token = lessons?.observe({ [unowned self] (change) in
//            self.setupSchedule()
//
//            if self.lessons != nil, !self.lessons.isEmpty {
//                DispatchQueue.main.async { [unowned self] in
//                    self.delegate?.didUpdateSchedule()
//                }
//            }
//        })
//    }
    
//    func loadFullSchedule() {
//        if scheduleType.shouldUseRealmStorage {
//            guard lessons != nil, !lessons.isEmpty else {
//                HUD.show(.progress)
//                downloadSchedule()
//                return
//            }
//        } else {
//            HUD.show(.progress)
//            downloadSchedule()
//        }
//    }
    
    private func downloadSchedule() {
        downloadScheduleSignal()
            .subscribe(onSuccess: { [unowned self] response in
                self.parseLessons(response)
                self.fetchSchedule()
            }) { error in
                DispatchQueue.main.async {
                    self.delegate?.didRecieveError(error: error)
                }
            }
            .disposed(by: self.bag)
    }
    
    private func downloadScheduleSignal() -> PrimitiveSequence<SingleTrait, Any> {
        switch scheduleType {
        case .group(let id):
            return provider.request(.loadFullSchedule(groupId: id))
        case .teacher(let id):
            return provider.request(.loadTeacherSchedule(teacherId: id))
        }
    }
    
    /* Internal login */
    
    private func setupSchedule() {
        guard lessons != nil else { return }
        
        var lessonsData = LessonsData()
        
        for lesson in lessons {
            if lesson.weekNumber == 1 {
                if lessonsData.firstWeekLessons[lesson.day] != nil {
                    lessonsData.firstWeekLessons[lesson.day]!.append(lesson)
                } else {
                    lessonsData.firstWeekLessons[lesson.day] = [lesson]
                }
            } else if lesson.weekNumber == 2 {
                if lessonsData.secondWeekLessons[lesson.day] != nil {
                    lessonsData.secondWeekLessons[lesson.day]!.append(lesson)
                } else {
                    lessonsData.secondWeekLessons[lesson.day] = [lesson]
                }
            }
        }
        
        data.value = lessonsData
    }
    
    private func parseLessons(_ data: Any) {
        
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
//                    addLesson(lesson: lesson, week: weekIndex, day: dayIndex)
//                    if scheduleType.shouldUseRealmStorage {
//                        lessons.append(lesson)
//                    } else {
//
//                    }
                }
            }
        }
        
        AppDataManager.shared.saveLessons(lessons)
        
//        if scheduleType.shouldUseRealmStorage {
//            saveLessonsLocally(lessons: lessons)
//        } else {
//            DispatchQueue.main.async { [unowned self] in
//                self.delegate?.didUpdateSchedule()
//            }
//        }
    }
    
    private func observeRealmErrors() {
        RealmService.errors.asObservable()
            .subscribe(onNext: { [unowned self] (realmError) in
                guard let error = realmError else { return }
                self.delegate?.didRecieveError(error: error)
                DDLogError(error.localizedDescription)
            })
            .disposed(by: bag)
    }
}

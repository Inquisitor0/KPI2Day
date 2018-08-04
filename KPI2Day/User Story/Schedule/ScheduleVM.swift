
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
    var teacher: Teacher?
    
    private let bag = DisposeBag()
    private let provider = OnlineProvider<AppNetworkService>()
    
    private var token: NotificationToken?
    
    var data = Variable<LessonsData>(LessonsData())
    
    private var lessons: AnyBidirectionalCollection<Lesson>! {
        didSet {
            if lessons.isEmpty || (teacher != nil && teacher?.scheduleWasLoaded == false) {
                downloadSchedule()
            } else {
                setupSchedule()
            }
        }
    }
    
    init(type: ScheduleType) {
        self.scheduleType = type
        
        switch scheduleType {
        case .group:
            self.teacher = nil
        case .teacher(let teacher):
//            self.token =
        }
        
        fetchSchedule()
    }
    
    func lessons(forWeek index: Int) -> [Int: [Lesson]] {
        return index == 0 ? data.value.firstWeekLessons : data.value.secondWeekLessons
    }
    
    private func fetchSchedule() {
        switch scheduleType {
        case .group:
            RealmService.fetchLessons { [unowned self] res in
                self.lessons = res
            }
        case .teacher(let teacher):
            DispatchQueue.main.async {
                RealmService.fetchLessons(Int(teacher.id), { [unowned self] res in
                    self.lessons = res
                })
            }
        }
    }
    
    private func downloadSchedule() {
        downloadScheduleSignal()
            .subscribe(onSuccess: { [unowned self] response in
                self.parseLessons(response, { [unowned self] in
                    self.fetchSchedule()
                })
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
        case .teacher(let teacher):
            return provider.request(.loadTeacherSchedule(teacherId: Int(teacher.id)))
        }
    }
    
    /* Internal logic */
    
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
    
    private func parseLessons(_ data: Any, _ completion: (() -> Void)? = nil) {
        
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
        
        DispatchQueue.main.async { [unowned self] in
            AppDataManager.shared.saveLessons(lessons, Int(self.teacher?.id ?? -1)) {
                completion?()
            }
        }
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

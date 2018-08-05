
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
    
    private var teachersIds: Set<Int> = []
    
    weak var delegate: ScheduleVMDelegate?
    
    let scheduleType: ScheduleType
    
    private let bag = DisposeBag()
    private let provider = OnlineProvider<AppNetworkService>()
    
    var data = Variable<LessonsData>(LessonsData())
    
    private var lessons: AnyBidirectionalCollection<Lesson>! {
        didSet {
            if lessons.isEmpty {
                downloadGroupSchedule()
            } else {
                setupSchedule()
            }
        }
    }
    
    init(type: ScheduleType) {
        self.scheduleType = type
        fetchSchedule()
    }
    
    func lessons(forWeek index: Int) -> [Int: [Lesson]] {
        return index == 0 ? data.value.firstWeekLessons : data.value.secondWeekLessons
    }
    
    private func fetchSchedule() {
        switch scheduleType {
        case .group(let groupId):
            RealmService.fetchLessons(nil, groupId) { [unowned self] res in
                self.lessons = res
            }
        case .teacher(let teacher):
            RealmService.fetchLessons(Int(teacher.id), nil, { [unowned self] res in
                self.lessons = res
            })
        }
    }
    
    private func downloadGroupSchedule() {
        downloadScheduleSignal()
            .subscribe(onSuccess: { [unowned self] response in
                self.parseGroupLessons(response, { [unowned self] in
                    self.downloadTeachersSchedule()
                })
            }) { error in
                DispatchQueue.main.async {
                    self.delegate?.didRecieveError(error: error)
                }
            }
            .disposed(by: self.bag)
    }
    
    private func downloadTeachersSchedule() {
        
        var signals: [Observable<Any>] = []
        
        teachersIds.forEach { signals.append(downloadScheduleSignal(teacherId: $0).asObservable()) }
        
        Observable
            .zip(signals)
            .subscribe(onNext: { [unowned self] results in
                var lessons: [Lesson] = []
                results.forEach { lessons.append(contentsOf: self.parseTeacherLessons($0)) }
                
                AppDataManager.shared.saveLessons(lessons, {
                    self.fetchSchedule()
                })
                
            }, onError: { [unowned self] error in
                self.delegate?.didRecieveError(error: error)
            }, onCompleted: {
                debugPrint("Fetched teachers schedule")
            }) {
                debugPrint("Fetch schedule signal disposed")
        }.disposed(by: bag)
    }
    
    private func downloadScheduleSignal(teacherId: Int? = nil) -> PrimitiveSequence<SingleTrait, Any> {
        if let id = teacherId {
            return provider.request(.loadTeacherSchedule(teacherId: id))
        } else {
            let groupId = AppDataManager.shared.currentGroupId.value ?? ""
            return provider.request(.loadFullSchedule(groupId: groupId))
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
    
    private func parseGroupLessons(_ data: Any, _ completion: (() -> Void)? = nil) {
        
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
                    
                        // Save unique IDs to fetch teachers' schedule later
                    lesson.teachers.forEach { teachersIds.insert($0.id) }
                }
            }
        }
        
        AppDataManager.shared.saveLessons(lessons) {
            completion?()
        }
    }
    
    private func parseTeacherLessons(_ data: Any) -> [Lesson] {
        
        let json = JSON(data)
        let lessonsJSONArray = json["results"].arrayValue
        
        var lessons: [Lesson] = []
        
        for lessonJSON in lessonsJSONArray {
            let lesson = Lesson(json: lessonJSON)
            lessons.append(lesson)
        }
        
        return lessons
    }
}

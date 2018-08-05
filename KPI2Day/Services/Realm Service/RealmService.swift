//
//  RealmService.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 13.05.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class RealmService {
    
    static let queue = DispatchQueue(label: "realm_queue", qos: .background)
    static var errors = Variable<Error?>(nil)
    
    static func fetchLessons(_ teacherId: Int? = nil,
                             _ groupId: String? = nil,
                             _ completion: @escaping (AnyBidirectionalCollection<Lesson>) -> Void) {
        DispatchQueue.main.async {
            
            let realm = try! Realm()
            
            let lessons: AnyBidirectionalCollection<Lesson>
            
            if let teahcerId = teacherId {
                lessons = AnyBidirectionalCollection(realm.objects(Lesson.self).filter { $0.teachers.containsById(teahcerId) })
            } else if let group = groupId, let groupId = Int(group) {
                 lessons = AnyBidirectionalCollection(realm.objects(Lesson.self).filter { $0.groups.containsById(groupId) })
            } else {
                 lessons = AnyBidirectionalCollection(realm.objects(Lesson.self))
            }
            
            completion(lessons)
        }
    }
    
    static func save(_ objects: [Lesson], _ completion: (() -> Void)? = nil) {
        
        queue.async {

            let realm = try! Realm()
            
            let savedLessons = realm.objects(Lesson.self)

            do {
                
                for lesson in objects {
                    
                    guard !savedLessons.contains(where: { $0.id == lesson.id }) else { continue }
                    
                    try realm.write {
                        realm.add(lesson)
                    }
                }
                
                completion?()
            } catch {
                postError(error)
            }
        }
    }
    
    static func clearLessons() {
        queue.async {

            let realm = try! Realm()

            let lessons = realm.objects(Lesson.self)

            do {
                try realm.write {
                    realm.delete(lessons)
                }
            } catch {
                postError(error)
            }
        }
    }
    
    private static func postError(_ error: Error) {
        errors.value = error
    }
}

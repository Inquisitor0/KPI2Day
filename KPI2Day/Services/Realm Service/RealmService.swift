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
    
    static func fetchLessons(_ completion: @escaping (Results<Lesson>) -> Void) {
        DispatchQueue.main.async {
            
            let realm = try! Realm()
            
            let lessons = realm.objects(Lesson.self)
            completion(lessons)
        }
    }
    
    static func save<T: Object>(_ objects: [T]) {
        
        queue.async {

            let realm = try! Realm()

            do {
                try realm.write {
                    realm.add(objects)
                }
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

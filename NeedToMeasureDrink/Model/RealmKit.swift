//
//  RealmKit.swift
//  NeedToMeasureDrink
//
//  Created by 백상휘 on 2020/07/21.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import Foundation
import RealmSwift

class RealmKit {
    var realm: Realm
    init(realm: Realm) {
        self.realm = realm
    }
    
    var categories: Results<Category> {
        realm.objects(Category.self)
    }
    var dailyLogs: Results<DailyLog> {
        realm.objects(DailyLog.self)
    }
    
    func realmInsert(_ category: Category) {
        do {
            try self.realm.write {
                self.realm.add(category)
            }
        } catch {
            fatalError("[INSERT] Error in Realm ::: \(error)")
        }
    }
    
    func realmInsert(_ dailyLog: DailyLog) {
        do {
            try self.realm.write {
                self.realm.add(dailyLog)
            }
        } catch {
            fatalError("[INSERT] Error in Realm ::: \(error)")
        }
    }
    
    func realmUpdate(_ category: Category) {
        let objects = realm.objects(Category.self)
        do {
            try self.realm.write {
                objects.first?.setValue(category.categoryKey, forKey: "categoryKey")
                objects.first?.setValue(category.type, forKey: "type")
                objects.first?.setValue(category.name, forKey: "name")
                objects.first?.setValue(category.numberOfCheckBox, forKey: "numberOfCheckBox")
                objects.first?.setValue(category.updateDt, forKey: "updateDt")
                objects.first?.setValue(category.dailyLog, forKey: "dailyLog")
            }
        } catch {
            fatalError("[UPDATE] Error in Realm ::: \(error)")
        }
    }
    
    func realmUpdate(_ dailyLog: DailyLog) {
        let objects = realm.objects(DailyLog.self)
        do {
            try self.realm.write {
                objects.first?.setValue(dailyLog.type, forKey: "type")
                objects.first?.setValue(dailyLog.name, forKey: "name")
                objects.first?.setValue(dailyLog.checked, forKey: "checked")
                objects.first?.setValue(dailyLog.unchecked, forKey: "unchecked")
                objects.first?.setValue(dailyLog.curretChecked, forKey: "curretChecked")
                objects.first?.setValue(dailyLog.date, forKey: "date")
            }
        } catch {
            fatalError("[UPDATE] Error in Realm ::: \(error)")
        }
    }
    
    func realmDelete(_ category: Category) {
        do {
            try realm.write {
                realm.delete(category)
            }
        } catch {
            fatalError("[DELETE] Error in Realm ::: \(error)")
        }
    }
    
    func realmDelete(_ dailyLog: DailyLog) {
        do {
            try realm.write {
                realm.delete(dailyLog)
            }
        } catch {
            fatalError("[DELETE] Error in Realm ::: \(error)")
        }
    }
    
    func realmDelete(_ dailyLogs: Results<DailyLog>) {
        do {
            try realm.write {
                realm.delete(dailyLogs)
            }
        } catch {
            fatalError("[DELETE] Error in Realm ::: \(error)")
        }
    }
}

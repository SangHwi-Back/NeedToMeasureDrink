//
//  DailyLog.swift
//  NeedToMeasureDrink
//
//  Created by 백상휘 on 2020/03/21.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import Foundation
import RealmSwift

class DailyLog: Object {
    //dynamic = dynamically Update Realm when application running.
    @objc dynamic var type : String = "" // Water, Liquor, Tea
    @objc dynamic var name: String = "" // Name
    @objc dynamic var checked : Bool = false
    @objc dynamic var unchecked : Bool = false
    @objc dynamic var curretChecked : Int = 0
    @objc dynamic var date : Date = Date.init()
    let category = LinkingObjects(fromType: Category.self, property: "dailyLog")
}

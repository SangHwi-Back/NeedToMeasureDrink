//
//  Category.swift
//  NeedToMeasureDrink
//
//  Created by 백상휘 on 2020/03/23.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var categoryKey = ""
    @objc dynamic var type : String = "" // Water, Liquor, Tea
    @objc dynamic var name: String = "" // Name
    @objc dynamic var numberOfCheckBox: Int = 8
    @objc dynamic var updateDt: Date = Date.init()
    let dailyLog = List<DailyLog>()
    
    override class func primaryKey() -> String? {
        "categoryKey"
    }
}

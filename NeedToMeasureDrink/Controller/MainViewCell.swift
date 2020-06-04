//
//  MainViewCell.swift
//  NeedToMeasureDrink
//
//  Created by 백상휘 on 2020/03/20.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class MainViewCell: UITableViewCell {
    var realm = try! Realm()
    var category: Category?
    var delegate: SwipeTableViewCellDelegate?
    
    @IBOutlet var stepper: UIStepper!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var checkBox1: UIButton!
    @IBOutlet var checkBox2: UIButton!
    @IBOutlet var checkBox3: UIButton!
    @IBOutlet var checkBox4: UIButton!
    @IBOutlet var checkBox5: UIButton!
    @IBOutlet var checkBox6: UIButton!
    @IBOutlet var checkBox7: UIButton!
    @IBOutlet var checkBox8: UIButton!
    @IBOutlet var checkBox9: UIButton!
    @IBOutlet var stepperStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stepper.maximumValue = 8
        stepper.minimumValue = 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func stepperButtonPressed(_ sender: UIStepper) {
        let checkBoxArr = [checkBox1, checkBox2, checkBox3, checkBox4, checkBox5, checkBox6, checkBox7, checkBox8, checkBox9]
        let dailyLog = DailyLog()
        var selectedCategory: Category?
        
        do{
            selectedCategory = realm.object(ofType: Category.self, forPrimaryKey: self.category?.categoryKey)
            if let safeCategory = selectedCategory {
                for i in 0 ..< checkBoxArr.count {
                    if i < Int(sender.value) {
                        checkBoxArr[i]?.tintColor = #colorLiteral(red: 0.9999076724, green: 0.6898844838, blue: 0.00432372978, alpha: 1)
                    }else{
                        checkBoxArr[i]?.tintColor = #colorLiteral(red: 0.3333052099, green: 0.3333491981, blue: 0.3332902789, alpha: 1)
                    }
                }
                
                dailyLog.type = safeCategory.type
                dailyLog.name = safeCategory.name
                dailyLog.curretChecked = Int(sender.value)
                dailyLog.checked = Int(sender.value) > 0 ? true : false
                dailyLog.unchecked = Int(sender.value) < 0 ? true : false
                dailyLog.date = Date.init()
                try realm.write{
                    //Realm Result or Results들은 한 개의 트랜잭션에서 실행해야 하므로
                    //realm.write block 에서 모두 모아 한번에 실행합니다.
                    safeCategory.updateDt = Date.init()
                    safeCategory.numberOfCheckBox = Int(sender.value)
                    
                    //위에서 만든 dailyLog를 safeCategory의 하위관계로 추가합니다. 업데이트도 이런식으로 하면 되나?
                    safeCategory.dailyLog.append(dailyLog)
                }
                nameLabel.text = "\(safeCategory.name)(\(safeCategory.numberOfCheckBox))"
            }
        }catch{
            print("Error Printing in stepperButtonPressed \(error)")
        }
    }
    
    func checkCollectively(_ numberOfCheckBox: Int) {}
    
    func checkBoxArrayFactory() -> [UIButton]{
        let checkBoxArr: [UIButton] = [checkBox1, checkBox2, checkBox3, checkBox4, checkBox5, checkBox6, checkBox7, checkBox8, checkBox9]
        return checkBoxArr
    }
    
    
}

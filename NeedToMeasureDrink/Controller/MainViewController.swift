//
//  MainViewController.swift
//  NeedToMeasureDrink
//
//  Created by 백상휘 on 2020/03/19.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class MainViewController: UITableViewController {
    var realm = try! Realm()
    var dailyLog: Results<DailyLog>?
    var categories: Results<Category>?
    var textFieldPickerValue: String?
    var simpleDateFormmater = DateFormatter.dateFormat(fromTemplate: "yyyy-mm-dd", options: 0, locale: Locale(identifier: "ko_KR"))
    
    let drinks = ["Water", "Beer", "Tea"]
    let defaults = UserDefaults.standard
    var imageView: UIImageView?
    let alertAddController = UIAlertController(title: "alertAddTitle", message: "AddMessage", preferredStyle: .alert)
    let alertController = UIAlertController(title: "alertTitle", message: "AddMessage", preferredStyle: .alert)
    let alertCategoryActionSheet = UIAlertController(title: "actionSheetTitle", message: "actionSheetMessage", preferredStyle: .actionSheet)
    let currentDate = Date.init()
    var parameterCell: MainViewCell?
    @IBOutlet var categorySearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.flatSkyBlueDark()
        loadCategories()
        self.hidekeyboard()
        let nibName = UINib(nibName: "MainViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "drinkItem")
        
        let alertAddAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let category = Category()
            category.categoryKey = UUID().uuidString
            if let safeTextField = self.textFieldPickerValue {
                category.type = safeTextField
            }
            if let safeLastText = self.alertAddController.textFields?.last?.text {
                category.name = safeLastText
            }
            
            category.numberOfCheckBox = 0
            
            do {
                try self.realm.write {
                    self.realm.add(category)
                }
                self.loadCategories()
                self.tableView.reloadData()
            } catch {
                print("error in Realm Init ::: \(error)")
            }
        }
        
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertAddController.addTextField { (textField) in
            textField.placeholder = "Type"
            
            let pickerView = UIPickerView(); pickerView.dataSource = self; pickerView.delegate = self
            let toolBar = UIToolbar(); toolBar.barStyle = UIBarStyle.default; toolBar.isTranslucent = true
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissPickerPressed))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            toolBar.sizeToFit()
            
            textField.inputAccessoryView = toolBar
            textField.inputView = pickerView
        }
        alertAddController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        
        alertAddController.addAction(alertAddAction)
        alertAddController.addAction(alertCancelAction)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        self.present(alertAddController, animated: true, completion: nil)
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    @objc func showTextFieldPickerView() {}
    func updateTextField(_ text: String) {}
    
    // MARK: - UITableViewDatasource, UITableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "drinkItem", for: indexPath) as! MainViewCell
        
        if let safeCategory = categories?[indexPath.row] {
            cell.backgroundColor = UIColor.flatSkyBlue()
            cell.thumbnailImageView.image = UIImage(named: safeCategory.type)
            cell.nameLabel.text = safeCategory.name+"(\(safeCategory.numberOfCheckBox))"
            cell.category = safeCategory
            cell.stepper.value = Double(safeCategory.numberOfCheckBox)
            
            let calendar = Calendar.current
            if calendar.compare(currentDate, to: safeCategory.updateDt, toGranularity: .day) == .orderedDescending {
                for temp in cell.checkBoxArrayFactory() {
                    temp.tintColor = #colorLiteral(red: 0.3333052099, green: 0.3333491981, blue: 0.3332902789, alpha: 1)
                }
                do{
                    try realm.write {
                        safeCategory.numberOfCheckBox = 0
                        safeCategory.updateDt = currentDate
                    }
                }catch{
                    print("Error MainViewController tableView cellForRowAt update")
                }
            } else {
                for i in 0 ..< safeCategory.numberOfCheckBox {
                    cell.checkBoxArrayFactory()[i].tintColor = #colorLiteral(red: 0.9999076724, green: 0.6898844838, blue: 0.00432372978, alpha: 1)
                }
            }
            
            cell.accessoryType = .disclosureIndicator
        }else{
            cell.textLabel?.text = "No Categories"
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDailyLog" {
            if let destinationVC = segue.destination as? DailyLogTableViewController {
                destinationVC.parameterCategory = self.parameterCell?.category
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parameterCell = tableView.cellForRow(at: indexPath) as? MainViewCell
        performSegue(withIdentifier: "showDailyLog", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let defaultAction = SwipeAction(style: .default, title: "LOG") { (action, indexPath) in
            self.parameterCell = tableView.cellForRow(at: indexPath) as? MainViewCell
            self.performSegue(withIdentifier: "showDailyLog", sender: self)
        }
        return [defaultAction]
    }
}

//MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension MainViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return drinks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            self.textFieldPickerValue = drinks[0]
            self.alertAddController.textFields?.first?.text = drinks[0]
        }
        return drinks[row]
    }
}

extension MainViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textFieldPickerValue = drinks[row]
        self.alertAddController.textFields?.first?.text = drinks[row]
    }
}

//MARK: - UISearchBar Delegate Methods
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        categories = realm.objects(Category.self).filter("name CONTAINS[cd] %@", searchBar.text ?? "").sorted(byKeyPath: "updateDt", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategories()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

//MARK: - Tab Gesture
extension MainViewController {
    func hidekeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func dismissPickerPressed(){
        view.endEditing(true)
    }
}

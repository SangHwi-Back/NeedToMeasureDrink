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
import RxSwift
import RxCocoa

class MainViewController: UITableViewController {
//    var realm = try! Realm()
    var dbKit = RealmKit()
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
    
    let calendar = Calendar.current
    let bag = DisposeBag()
    
    @IBOutlet var categorySearchBar: UISearchBar!
    @IBOutlet var drinkTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.flatSkyBlueDark()
        categories = dbKit.categories
        self.hidekeyboard()
        let nibName = UINib(nibName: "MainViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "drinkItem")
        
        let alertAddAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let category = Category()
            
            guard let safeTextField = self.textFieldPickerValue, let safeLastText = self.alertAddController.textFields?.last?.text else {
                return
            }
            
            category.categoryKey = UUID().uuidString
            category.type = safeTextField
            category.name = safeLastText
            category.numberOfCheckBox = 0
            
            self.dbKit.realmInsert(category)
            self.loadCategories()
            self.loadCell(self.dbKit.categories)
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
        
        if let categories = categories {
            loadCell(categories)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        self.present(alertAddController, animated: true, completion: nil)
    }
    
    func loadCategories() {
        categories = dbKit.categories
        tableView.reloadData()
    }
    
    @objc func showTextFieldPickerView() {}
    func updateTextField(_ text: String) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDailyLog" {
            if let destinationVC = segue.destination as? DailyLogTableViewController {
                destinationVC.parameterCategory = self.parameterCell?.category
            }
        }
    }
    
// MARK: - UITableViewDatasource, UITableViewDelegate
    
    func loadCell(_ results: Results<Category>) {
        tableView.delegate = nil
        tableView.dataSource = nil
        
        let observable = Observable.of(results)
        
        observable.bind(to: drinkTableView.rx.items(cellIdentifier: "drinkItem", cellType: MainViewCell.self))
        { row, item, cell in
            cell.backgroundColor = UIColor.flatSkyBlue()
            cell.thumbnailImageView.image = UIImage(named: item.type)
            cell.nameLabel.text = item.name + "(\(String(item.numberOfCheckBox)))"
            cell.category = item
            cell.stepper.value = Double(item.numberOfCheckBox)
            
            if self.calendar.compare(self.currentDate, to: item.updateDt, toGranularity: .day) == .orderedDescending {
                for checkBox in cell.checkBoxArrayFactory() {
                    checkBox.tintColor = #colorLiteral(red: 0.3333052099, green: 0.3333491981, blue: 0.3332902789, alpha: 1)
                }
                item.numberOfCheckBox = 0
                item.updateDt = self.currentDate
                self.dbKit.realmUpdate(item)
                
//                do { try self!.realm.write {
//                    item.numberOfCheckBox = 0
//                    item.updateDt = self!.currentDate
//                    }
//                } catch {
//                    fatalError("Error MainViewController cellForRowAt update")
//                }
            } else {
                for i in 0..<item.numberOfCheckBox {
                    cell.checkBoxArrayFactory()[i].tintColor = #colorLiteral(red: 0.9999076724, green: 0.6898844838, blue: 0.00432372978, alpha: 1)
                }
            }
        }
        .disposed(by: bag)
        
        drinkTableView.rx.modelSelected(MainViewCell.self)
            .subscribe(onNext: {cell in
                self.parameterCell = cell
            })
            .disposed(by: bag)
        
        
        
        
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
        categories = dbKit.categories.filter("name CONTAINS[cd] %@", searchBar.text ?? "").sorted(byKeyPath: "updateDt", ascending: true)
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

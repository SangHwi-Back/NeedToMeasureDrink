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

class MainViewController: UIViewController, UITableViewDelegate {

    private var dbKit = (UIApplication.shared.delegate as? AppDelegate)?.realmKit ?? RealmKit(realm: try! Realm())
    private var dailyLog: Results<DailyLog>?
    private var categories: Results<Category>?
    private var textFieldPickerValue: String?
    private var simpleDateFormmater = DateFormatter.dateFormat(fromTemplate: "yyyy-mm-dd", options: 0, locale: Locale(identifier: "ko_KR"))
    
    private let drinks = ["Water", "Beer", "Tea"]
    private let defaults = UserDefaults.standard
    private var imageView: UIImageView?
    private let alertAddController = UIAlertController(title: "alertAddTitle", message: "AddMessage", preferredStyle: .alert)
    private let alertController = UIAlertController(title: "alertTitle", message: "AddMessage", preferredStyle: .alert)
    private let alertCategoryActionSheet = UIAlertController(title: "actionSheetTitle", message: "actionSheetMessage", preferredStyle: .actionSheet)
    private let currentDate = Date.init()
    private var parameterCell: MainViewCell?
    
    private let calendar = Calendar.current
    private let bag = DisposeBag()
    
    @IBOutlet var categorySearchBar: UISearchBar!
    @IBOutlet var drinkTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.categories = dbKit.categories
        self.hidekeyboard()
        let nibName = UINib(nibName: "MainViewCell", bundle: nil)
        self.drinkTableView.register(nibName, forCellReuseIdentifier: "drinkItem")
        
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
    
    private func loadCategories() {
        self.categories = dbKit.categories
        self.drinkTableView.reloadData()
    }
    
    @objc func showTextFieldPickerView() {}
    private func updateTextField(_ text: String) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDailyLog" {
            if let destinationVC = segue.destination as? DailyLogTableViewController {
                destinationVC.parameterCategory = self.parameterCell?.category
            }
        }
    }
    
// MARK: - UITableViewDatasource, UITableViewDelegate
    
    private func loadCell(_ results: Results<Category>) {
        self.drinkTableView.delegate = nil
        self.drinkTableView.dataSource = nil
        
        let observable = Observable.of(results)
        
        observable.bind(to: drinkTableView.rx.items(cellIdentifier: "drinkItem", cellType: MainViewCell.self))
        { row, item, cell in
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
        self.drinkTableView.reloadData()
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

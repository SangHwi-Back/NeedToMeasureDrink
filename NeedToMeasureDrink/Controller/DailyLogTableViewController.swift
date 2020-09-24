//
//  DailyLogTableViewController.swift
//  NeedToMeasureDrink
//
//  Created by 백상휘 on 2020/03/22.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class DailyLogTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    private var dbKit = (UIApplication.shared.delegate as? AppDelegate)?.realmKit ?? RealmKit(realm: try! Realm())
    private var dailyLogs: Results<DailyLog>?
    private var category: Results<Category>?
    private var typeParameter: String?
    private var nameParameter: String?
    var parameterCategory: Category?
    private var dailyLogSection = [[DailyLog]]()
    private var tempIndex = 0
    
    private let dateFormmater = DateFormatter()
    
    @IBOutlet var dailyLogSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidekeyboard()
        self.settingData()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func deleteLogButtonClicked(_ sender: UIButton) {
        if let safeDailyLogs = dailyLogs {
            dbKit.realmDelete(safeDailyLogs)
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func deleteCategoryButtonClicked(_ sender: UIBarButtonItem) {
        if let safeCategory = parameterCategory {
            dbKit.realmDelete(safeCategory)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func settingData() {
        if let safeCategory = parameterCategory {
            dailyLogs = dbKit.dailyLogs.filter("ANY category.categoryKey = %@", safeCategory.categoryKey)
            dailyLogSection = [[DailyLog]]()
            
            guard dailyLogs!.count > 0 && dailyLogs != nil else {return}
            dailyLogs = dailyLogs?.sorted(byKeyPath: "date", ascending: false)
            var sectionDate: Date?
            let calendar = Calendar.current
            
            for temp in dailyLogs! {
                if sectionDate == nil || calendar.compare(sectionDate!, to: temp.date, toGranularity: .day) == .orderedDescending {
                    sectionDate = temp.date
                    dailyLogSection.append([temp])
                }else if calendar.compare(sectionDate!, to: temp.date, toGranularity: .day) == .orderedSame {
                    dailyLogSection[dailyLogSection.count-1].append(temp)
                }
            }
        }
    }
    
    // MARK: - UITableViewDatasource, UITableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dailyLogSection.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {   return dailyLogSection[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let safeDate = dailyLogSection[section].first?.date,
            dailyLogSection.count > 0 else {
            return "no Section"
        }
        
        dateFormmater.dateFormat = "yyyy-MM-dd"
        return dateFormmater.string(from: safeDate)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dailyLogCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        dateFormmater.dateFormat = "yyyy-MM-dd hh:mm"
        // Configure the cell...
        if let safeLog = dailyLogs?[tempIndex] {
            cell.textLabel?.text = "\(dateFormmater.string(from: safeLog.date)) : \(safeLog.name)(\(safeLog.type))를 \(safeLog.checked ? "+" : "-")1(\(safeLog.curretChecked))"
            tempIndex += 1
        }else{
            cell.textLabel?.text = "No Data"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - SwipeTableViewCellDelegate Method
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if let dailyLog = self.dailyLogs?[indexPath.row] {
                self.dbKit.realmDelete(dailyLog)
            }
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}

//MARK: - UISearchController Delegate Methods
extension DailyLogTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let safeCategory = parameterCategory {
            dailyLogs = dbKit.dailyLogs.filter("ANY category.categoryKey %@", safeCategory.categoryKey)
        }
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            settingData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

extension DailyLogTableViewController {
    func hidekeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

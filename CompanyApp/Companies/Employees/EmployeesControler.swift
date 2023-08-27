//
//  EmployeesController.swift
//  CompanyApp
//
//  Created by Nikita Popov on 07.03.2021.
//

import UIKit
import CoreData

class IndentedLabel: UILabel{
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = rect.inset(by: insets)
        super.drawText(in: customRect)
    }
}

class EmployeesControler: UITableViewController, CreateEmployeeControllerDelegate{
    
    
    func didAddEmployee(employee: Employee) {
//        fetchEmployee()
//        tableView.reloadData()
        guard let section = employeeTypes.firstIndex(of: employee.type!) else { return }
        let row = allEmployees[section].count
        
        let insertionIndexPath = IndexPath(row: row, section: section)
        allEmployees[section].append(employee)
        
        tableView.insertRows(at: [insertionIndexPath], with: .middle)
    }
    
    
    var company: Company?
    
//    var employees = [Employee]()
    
    let cellId = "CellID"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = company?.name
        
    }
    
    var employeeTypes = [
        EmployeType.Executive.rawValue,
        EmployeType.SeniorManagement.rawValue,
        EmployeType.Staff.rawValue
        ]
    
    private func fetchEmployee(){
        guard let companyEmployees = company?.employees?.allObjects as? [Employee] else { return }
        allEmployees = []
        employeeTypes.forEach { (employeeType) in
            allEmployees.append(
                companyEmployees.filter { $0.type == employeeType }
            )
        }
    }
    
    override func viewDidLoad() {
        tableView.backgroundColor = .darkBlue
        setupPlusBarButtonInNavBar(selector: #selector(handleAdd))
        fetchEmployee()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    @objc private func handleAdd(){
        print("Trying to add an employee...")
        let employeeViewController = CreateEmployeeController()
        employeeViewController.delegate = self
        employeeViewController.company = company
        let navController = UINavigationController(rootViewController: employeeViewController)
        navController.modalPresentationStyle = .fullScreen
        
        present(navController, animated: true, completion: nil)
    }
    

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        
        label.text = employeeTypes[section]
        
        label.textColor = .darkBlue
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = .lightBlue
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allEmployees[section].count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        allEmployees.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let employee = allEmployees[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = employee.name
        if let employeeBirthDate = employee.employeeInformation?.birthday{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            cell.textLabel?.text = "\(employee.name ?? "") - \(dateFormatter.string(from: employeeBirthDate))"
        }
        
        cell.backgroundColor = .cellBlueColor
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        return cell
    }
    
//    var executive = [Employee]()
//    var seniorManagement = [Employee]()
//    var staff = [Employee]()
    
    var allEmployees = [[Employee]]()
    
}

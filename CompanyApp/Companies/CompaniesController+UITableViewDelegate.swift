//
//  CompaniesController+UITableViewDelegate.swift
//  CompanyApp
//
//  Created by Nikita Popov on 07.03.2021.
//

import UIKit

extension CompaniesControler {
    
    // MARK: - TableViewDataSource and TableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .lightBlue
        return view
    }
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No companies available..."
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return companies.count == 0 ? 150 : 0
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        companies.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! CompanyCell
        let company = companies[indexPath.row]
        cell.company = company
        return cell
    }

    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            let company = self.companies[indexPath.row]
            print("trying to delete \(company.name ?? " ")")
            self.companies.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            let context = CoreDataManager.shared.persistentContainer.viewContext
            context.delete(company)
            do{
                try context.save()
            }catch let error as NSError{
                print("Error with the context saving after deletion: \(error)")
            }
        }
        
        let editAct = UIContextualAction(style: .normal, title: "Edit") { (_, _, _) in
            print("Editing")
            let editCompanyController = CreateCompanyController()
            editCompanyController.delegate = self
            editCompanyController.company = self.companies[indexPath.row]
            let navController = UINavigationController(rootViewController: editCompanyController)
            self.present(navController, animated: true, completion: nil)
        }
        
        deleteAction.backgroundColor = .tintLightRed
        editAct.backgroundColor = .darkBlue
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAct])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let company = companies[indexPath.row]
        let employeesController = EmployeesControler()
        employeesController.company = company
        navigationController?.pushViewController(employeesController, animated: true)
    }
}


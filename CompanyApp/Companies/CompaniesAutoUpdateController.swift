//
//  CompaniesAutoUpdateController.swift
//  CompanyApp
//
//  Created by Nikita Popov on 12.03.2021.
//

import UIKit
import CoreData

class CompaniesAutoUpdateController: UITableViewController, NSFetchedResultsControllerDelegate{
    
    let cellId = "CellID"
    
    lazy var fetchResultsController: NSFetchedResultsController<Company> = {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
            ]
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        frc.delegate = self
        do{
            try frc.performFetch()
        }catch let error{
            print("Fetching error:", error)
        }
        return frc
    }()
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
     
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
     
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Company autoupdates"
        tableView.backgroundColor = .darkBlue
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd)),
            UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))
            ]
        

        tableView.register(CompanyCell.self, forCellReuseIdentifier: cellId)
        fetchResultsController.fetchedObjects?.forEach({ (company) in
            print(company.name ?? "")
        })
        
//        APIServise.shared.downloadCompaniesFromServer()
        let refreshCOntroll = UIRefreshControl()
        refreshCOntroll.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshCOntroll.tintColor = .white
        self.refreshControl = refreshCOntroll
    }
    
    @objc func refresh(){
        APIServise.shared.downloadCompaniesFromServer()
        self.refreshControl?.endRefreshing()
    }
    
    @objc private func handleDelete(){
        let request: NSFetchRequest<Company> = Company.fetchRequest()
//        request.predicate = NSPredicate(format: "name CONTAINS %@", "C")
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let companiesWithB = try! context.fetch(request)
        companiesWithB.forEach { (company) in
            context.delete(company)
        }
        try? context.save()
    }
    
    @objc private func handleAdd(){
//        let companyCreateController = CreateCompanyController()
//        let navController = UINavigationController(rootViewController: companyCreateController)
//        navController.modalPresentationStyle = .fullScreen
//        present(navController, animated: true, completion: nil)
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let company = Company(context: context)
        company.name = "CCC"
        
        do{
            try context.save()
            tableView.reloadData()
        }catch let error{
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        label.backgroundColor = .lightBlue
        label.text = fetchResultsController.sectionIndexTitles[section]
        return label
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        fetchResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CompanyCell
        let company = fetchResultsController.object(at: indexPath)
        
        cell.company = company
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let employeeVC = EmployeesControler()
        employeeVC.company = fetchResultsController.object(at: indexPath)
        navigationController?.pushViewController(employeeVC, animated: true)
    }
    
}

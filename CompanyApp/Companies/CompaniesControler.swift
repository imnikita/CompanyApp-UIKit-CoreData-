//
//  ViewController.swift
//  CompanyApp
//
//  Created by Nikita Popov on 05.03.2021.
//

import UIKit
import CoreData

class CompaniesControler: UITableViewController {
    
    var companies = [Company]()
    
    
    @objc private func doWork(){
        print("Trying to do work...")
    
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (backgroundContext) in
            
            (0...10).forEach { (value) in
                let company = Company(context: backgroundContext)
                company.name = String(value)
                
                do{
                    try backgroundContext.save()
                    DispatchQueue.main.async {
                        self.companies = CoreDataManager.shared.fetchCompanies()
                        self.tableView.reloadData()
                    }
                }catch{
                    print("FAAAAAILED")
                }
            }
        }
    }
    
    
    @objc private func doUpdates(){
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (backgroundContext) in
            
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            do{
                let companies = try backgroundContext.fetch(request)
                companies.forEach { (company) in
                    print(company.name ?? "")
                    company.name = "B: \(company.name ?? "")"
                }
                do{
                    try backgroundContext.save()
                    DispatchQueue.main.async {
                        CoreDataManager.shared.persistentContainer.viewContext.reset()
                        self.companies = CoreDataManager.shared.fetchCompanies()
                        self.tableView.reloadData()
                    }
                }catch let error{
                    print(error)
                }
            }catch let error{
                print("Error while fetching companies on background thread:", error)
            }
        }
    }
    
    
    @objc func doNestedUpdates(){
        print("Doing nested updates...")
        
        DispatchQueue.global(qos: .background).async {
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
            
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            request.fetchLimit = 1
            do{
                let companies = try privateContext.fetch(request)
                companies.forEach { (company) in
                    print(company.name ?? "")
                    company.name = "D: \(company.name ?? "")"
                }
                do{
                    try privateContext.save()
                    DispatchQueue.main.async {
                        do{
                            let context = CoreDataManager.shared.persistentContainer.viewContext
                            if context.hasChanges{
                                try context.save()
                            }
                            self.tableView.reloadData()
                        }catch let error{
                            print("Error while fetching companies on background parent thread:", error)
                        }
                    }
                }catch let error{
                    print("Error while fetching companies on background child thread:", error)
                }
            }catch let error{
                print("Error while fetching companies on background child thread:", error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companies = CoreDataManager.shared.fetchCompanies()
        
        view.backgroundColor = .white
        navigationItem.title = "Companies"
        setupPlusBarButtonInNavBar(selector: #selector(handleAddCompany))
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset)),
            UIBarButtonItem(title: "DoUpdates", style: .plain, target: self, action: #selector(doNestedUpdates))
            ]
        
        tableView.backgroundColor = .darkBlue
        tableView.separatorColor = .white
        tableView.register(CompanyCell.self, forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView()
        

    }
    
    @objc private func handleReset(){
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        
        do{
            try context.execute(batchDeleteRequest)
            var indexPathToRemove = [IndexPath]()
            for(index, _) in companies.enumerated(){
                let indexPath = IndexPath(row: index, section: 0)
                indexPathToRemove.append(indexPath)
            }
            companies.removeAll()
            tableView.deleteRows(at: indexPathToRemove, with: .left)
        }catch let error{
            print("Cold not execute batchDeleteRequest: \(error)")
        }
    }
        
    @objc func handleAddCompany(){
        print("Adding company")
        let createCompanyControler = CreateCompanyController()
        let navController = UINavigationController(rootViewController: createCompanyControler)
        createCompanyControler.delegate = self
        present(navController, animated: true, completion: nil)
    }
    
}





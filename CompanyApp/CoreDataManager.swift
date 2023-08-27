//
//  CoreDataManager.swift
//  CompanyApp
//
//  Created by Nikita Popov on 06.03.2021.
//

import CoreData

struct CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CompaniesDB")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error{
                fatalError("Loading of store is failed: \(error)")
            }
            
        }
        return container
    }()
    
    
    func fetchCompanies() -> [Company] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        do{
            let companies = try context.fetch(fetchRequest)
            return companies
        }catch{
            print("Could not fetch data.")
            return[]
        }
    }
    
    func createEmployee(employeeName: String, employeeType: String, birthday: Date, company: Company) -> (Employee?, Error?){
        let context = persistentContainer.viewContext
        let employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as! Employee
        employee.company = company
        employee.setValue(employeeName, forKey: "name")
        let employeeInformation = NSEntityDescription.insertNewObject(forEntityName: "EmployeeInformation", into: context) as! EmployeeInformation
        employeeInformation.birthday = birthday
        employee.employeeInformation = employeeInformation
        employee.type = employeeType
        do{
            try context.save()

            return (employee, nil)
        }catch let error{
            print("Could not save employee:", error)
            return (nil, error)
        }
    }
    
}

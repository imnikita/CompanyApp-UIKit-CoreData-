//
//  APIServise.swift
//  CompanyApp
//
//  Created by Nikita Popov on 12.03.2021.
//

import UIKit
import CoreData

struct APIServise {
    
    static let shared = APIServise()
    
    let urlString = "https://api.letsbuildthatapp.com/intermediate_training/companies"
    
    func downloadCompaniesFromServer(){
        print("It works")
        guard let url = URL(string: urlString) else { return }
        let session = URLSession.shared.dataTask(with: url) { (data, reaponse, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            } else{
                guard let safeData = data else { return }
                let jsonDecoder = JSONDecoder()
                
                let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
                
                do{
                    let jsonCompanies = try jsonDecoder.decode([JSONCmpany].self, from: safeData)
                    jsonCompanies.forEach { (jsonCompany) in
                        print(jsonCompany.name)
                        let company = Company(context: privateContext)
                        company.name = jsonCompany.name
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd.MM.yyyy"
                        let date = dateFormatter.date(from: jsonCompany.founded)
                        company.founded = date
                        
                        jsonCompany.employees?.forEach({ (jsonEmployee) in
                            let employee = Employee(context: privateContext)
                            employee.name = jsonEmployee.name 
                            employee.type = jsonEmployee.type
                            employee.company = company
                            
                            let birthDate = dateFormatter.date(from: jsonEmployee.birthday)
                            let employeInformation = EmployeeInformation(context: privateContext)
                            employeInformation.birthday = birthDate
                            employee.employeeInformation = employeInformation
                            
                            
                        })

                        do{
                            try privateContext.save()
                            try privateContext.parent?.save()
                        }catch let error {
                            print("Error with saving data from API in CoreData: ", error)
                        }
                                                            
                    }
                }catch let error{
                    print("Failed to decode JSON: ", error )
                }
                
                
                
                
            }
        }.resume()
        
    }
    
    
    
}

struct JSONCmpany: Decodable{
    let name: String
    let founded: String
    var employees: [JSONEmployees]?
    
}

struct JSONEmployees: Decodable {
    let name: String
    let birthday: String
    let type: String
}

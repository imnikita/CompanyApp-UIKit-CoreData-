//
//  CompaniesController+CreateCompantController.swift
//  CompanyApp
//
//  Created by Nikita Popov on 07.03.2021.
//

import UIKit


// MARK: - CreateCompanyControllerDelegate Protocol

protocol CreateCompanyControllerDelegate {
    func didAddCompany(company: Company)
    func didEditCompany(company: Company)
}


// MARK: - CreateCompanyControllerDelegate Methods

extension CompaniesControler: CreateCompanyControllerDelegate{
    
    func didAddCompany(company: Company) {
        companies.append(company)
        let newIndexPath = IndexPath(row: companies.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func didEditCompany(company: Company){
        let row = companies.firstIndex(of: company)
        let reloadIndexPath = IndexPath(row: row!, section: 0)
        tableView.reloadRows(at: [reloadIndexPath], with: .middle)
    }

}

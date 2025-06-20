//
//  ViewController.swift
//  FinacialApp
//
//  Created by Alexis Horteales Espinosa on 19/06/25.
//

import UIKit

class SearchTableViewController: UITableViewController {

    
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
      
    }
    
    
    private func  setupNavigationBar(){
        navigationItem.searchController = searchController
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        return cell
    }

}



// Mark: Protocol
extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

//
//  ViewController.swift
//  FinacialApp
//
//  Created by Alexis Horteales Espinosa on 19/06/25.
//

import UIKit
import Combine

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
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: SearchResults?
    @Published private var searchQuery = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🚀 ViewDidLoad iniciado")
        setupNavigationBar()
        setupTableView()
        observeForm()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        print("🔧 Navigation bar configurado")
    }
    
    private func setupTableView() {
        // Asegúrate de que el identifier sea correcto
        // Si no funciona con "cellId", intenta con el identifier exacto del storyboard
        tableView.keyboardDismissMode = .onDrag
        print("🔧 TableView configurado")
    }
    
    private func observeForm() {
        print("🔍 Configurando observador de búsqueda")
        
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchQuery in
                guard let self = self else { return }
                
                print("🔍 Query recibida: '\(searchQuery)'")
                
                guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
                    print("🔍 Query vacía, limpiando resultados")
                    DispatchQueue.main.async {
                        self.searchResults = nil
                        self.tableView.reloadData()
                    }
                    return
                }
                
                print("🔍 Iniciando búsqueda para: '\(searchQuery)'")
                self.performSearch(query: searchQuery)
            }
            .store(in: &subscribers)
    }
    
    private func performSearch(query: String) {
        apiService.fetchSymbolSearch(for: query)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("❌ Error en la búsqueda: \(error)")
                    if let urlError = error as? URLError {
                        print("❌ URLError code: \(urlError.code.rawValue)")
                        print("❌ URLError description: \(urlError.localizedDescription)")
                    }
                    if let decodingError = error as? DecodingError {
                        print("❌ DecodingError: \(decodingError)")
                    }
                    DispatchQueue.main.async {
                        self?.searchResults = nil
                        self?.tableView.reloadData()
                    }
                case .finished:
                    print("✅ Búsqueda completada exitosamente")
                }
            } receiveValue: { [weak self] searchResponse in
                print("📊 Respuesta recibida")
                print("📊 Número de resultados: \(searchResponse.items.count)")
                
                // Debug: imprimir primeros resultados
                for (index, item) in searchResponse.items.prefix(3).enumerated() {
                    print("📊 [\(index + 1)] \(item.symbol) - \(item.name) (\(item.type)) [\(item.currency)]")
                }
                
                DispatchQueue.main.async {
                    self?.searchResults = searchResponse
                    print("📊 Resultados asignados, recargando tabla...")
                    self?.tableView.reloadData()
                    print("📊 Tabla recargada")
                }
            }
            .store(in: &subscribers)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = searchResults?.items.count ?? 0
        print("📋 numberOfRowsInSection: \(count)")
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("📋 cellForRowAt: \(indexPath.row)")
        
        // Intentar diferentes identifiers comunes
        var cell: SearchTableViewCell?
        
        // Primero intenta con "cellId"
        cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? SearchTableViewCell
        
        // Si no funciona, intenta con otros identifiers comunes
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell
        }
        
        guard let tableCell = cell else {
            print("❌ No se pudo crear la celda con ningún identifier")
            // Crear una celda básica como fallback
            let basicCell = UITableViewCell(style: .subtitle, reuseIdentifier: "basic")
            if let searchResults = self.searchResults, indexPath.row < searchResults.items.count {
                let item = searchResults.items[indexPath.row]
                basicCell.textLabel?.text = "\(item.symbol) - \(item.name)"
                basicCell.detailTextLabel?.text = "\(item.type) • \(item.currency)"
            }
            return basicCell
        }
        
        if let searchResults = self.searchResults, indexPath.row < searchResults.items.count {
            let searchResult = searchResults.items[indexPath.row]
            print("📋 Configurando celda para: \(searchResult.symbol)")
            tableCell.configure(with: searchResult)
        }
        
        return tableCell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let searchResults = self.searchResults,
              indexPath.row < searchResults.items.count else { return }
        
        let selectedResult = searchResults.items[indexPath.row]
        print("🎯 Símbolo seleccionado: \(selectedResult.symbol)")
        
        // Opcional: obtener datos históricos del símbolo seleccionado
        fetchTimeSeriesData(for: selectedResult.symbol)
    }
    
    private func fetchTimeSeriesData(for symbol: String) {
        print("📈 Obteniendo datos históricos para: \(symbol)")
        
        apiService.fetchDailyTimeSeries(for: symbol)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("❌ Error al obtener datos históricos: \(error.localizedDescription)")
                case .finished:
                    print("✅ Datos históricos obtenidos exitosamente")
                }
            } receiveValue: { timeSeriesResponse in
                print("📈 Símbolo: \(timeSeriesResponse.metaData.symbol)")
                print("📈 Última actualización: \(timeSeriesResponse.metaData.lastRefreshed)")
                
                let sortedDates = timeSeriesResponse.timeSeries.keys.sorted { $0 > $1 }
                
                print("📈 --- Datos más recientes ---")
                for (index, date) in sortedDates.prefix(3).enumerated() {
                    if let dailyData = timeSeriesResponse.timeSeries[date] {
                        print("📈 [\(index + 1)] \(date): Cierre $\(dailyData.close)")
                    }
                }
            }
            .store(in: &subscribers)
    }
}

// MARK: - UISearchResultsUpdating, UISearchControllerDelegate
extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        print("🔍 updateSearchResults llamado con: '\(searchText)'")
        self.searchQuery = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

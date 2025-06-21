//
//  APIService.swift
//  FinacialApp
//
//  Created by Alexis Horteales Espinosa on 19/06/25.
//

import Foundation
import Combine

struct APIService {
    
    /// Propiedad computada para elegir una API key aleatoria
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    
    let keys = ["5J71X508YTDOFCO3", "QJPF66GGMCCQA5R9", "PEFETPNOTYT59QQX"]
    
    // FUNCIÓN PRINCIPAL: Para buscar símbolos (SYMBOL_SEARCH)
    func fetchSymbolSearch(for query: String) -> AnyPublisher<SearchResults, Error> {
        // Codificar la query para URLs
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(encodedQuery)&apikey=\(API_KEY)"
        
        print("🌐 URL de búsqueda: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ URL inválida: \(urlString)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .handleEvents(
                receiveSubscription: { _ in
                    print("🌐 Iniciando request...")
                },
                receiveOutput: { data, response in
                    print("🌐 Respuesta recibida: \(data.count) bytes")
                    if let httpResponse = response as? HTTPURLResponse {
                        print("🌐 Status code: \(httpResponse.statusCode)")
                    }
                    
                    // Debug: imprimir la respuesta JSON
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("🌐 JSON Response: \(jsonString.prefix(500))...")
                    }
                },
                receiveCompletion: { completion in
                    print("🌐 Request completado: \(completion)")
                }
            )
            .map(\.data)
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Función para obtener datos de series temporales diarias
    func fetchDailyTimeSeries(for symbol: String) -> AnyPublisher<TimeSeriesResponse, Error> {
        let encodedSymbol = symbol.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? symbol
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(encodedSymbol)&apikey=\(API_KEY)"
        
        print("🌐 URL de series temporales: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ URL inválida para series temporales: \(urlString)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .handleEvents(
                receiveOutput: { data, response in
                    print("📈 Datos de series temporales recibidos: \(data.count) bytes")
                    if let httpResponse = response as? HTTPURLResponse {
                        print("📈 Status code: \(httpResponse.statusCode)")
                    }
                }
            )
            .map(\.data)
            .decode(type: TimeSeriesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Función para obtener datos intradiarios
    func fetchIntradayTimeSeries(for symbol: String, interval: String = "5min") -> AnyPublisher<IntradayTimeSeriesResponse, Error> {
        let encodedSymbol = symbol.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? symbol
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(encodedSymbol)&interval=\(interval)&apikey=\(API_KEY)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: IntradayTimeSeriesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

//
//  SearchResults.swift
//  FinacialApp
//
//  Created by Alexis Horteales Espinosa on 19/06/25.
//

import Foundation


struct SearchResults: Decodable{
    
    let items: [SearchResult]
    
    enum CodingKeys: String, CodingKey{
        case items = "bestMatches"
    }
    
}


struct SearchResult: Decodable{
    let symbol: String
    let name: String
    let type: String
    let currency: String
    
    enum CodingKeys: String, CodingKey{
        case symbol = "1. symbol"
        case name = "2. name"
        case type = "3. type"
        case currency = "4. currency"
    }
}

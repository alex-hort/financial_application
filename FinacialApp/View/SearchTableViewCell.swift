//
//  SearchTableViewCell.swift
//  FinacialApp
//
//  Created by Alexis Horteales Espinosa on 19/06/25.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetSymbolLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Configuración visual opcional
        assetNameLabel?.numberOfLines = 0
        assetSymbolLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        assetTypeLabel?.font = UIFont.systemFont(ofSize: 14)
        assetTypeLabel?.textColor = UIColor.systemGray
    }
    
    func configure(with searchResult: SearchResult) {
        print("🔧 Configurando celda para: \(searchResult.symbol)")
        
        assetNameLabel?.text = searchResult.name
        assetSymbolLabel?.text = searchResult.symbol
        assetTypeLabel?.text = "\(searchResult.type) • \(searchResult.currency)"
        
        // Debug: verificar que los outlets estén conectados
        if assetNameLabel == nil {
            print("❌ assetNameLabel es nil - verifica la conexión en el storyboard")
        }
        if assetSymbolLabel == nil {
            print("❌ assetSymbolLabel es nil - verifica la conexión en el storyboard")
        }
        if assetTypeLabel == nil {
            print("❌ assetTypeLabel es nil - verifica la conexión en el storyboard")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assetNameLabel?.text = nil
        assetSymbolLabel?.text = nil
        assetTypeLabel?.text = nil
    }
}

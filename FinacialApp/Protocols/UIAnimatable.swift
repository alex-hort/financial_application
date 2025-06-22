//
//  UIAnimatable.swift
//  FinacialApp
//
//  Created by Alexis Horteales Espinosa on 22/06/25.
//


import Foundation
import MBProgressHUD

protocol UIAnimatable where Self: UIViewController{
    func showLoadingAnimation()
    func hideLoadingAnimation()
}

extension UIAnimatable{
    
    func showLoadingAnimation(){
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    func hideLoadingAnimation(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}

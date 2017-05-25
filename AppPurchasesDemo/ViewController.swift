//
//  ViewController.swift
//  AppPurchasesDemo
//
//  Created by Xinxibin on 2017/5/24.
//  Copyright © 2017年 xiaoxin. All rights reserved.
//

import UIKit
import SwiftyStoreKit


class ViewController: UIViewController {
    
    @IBAction func onBuyBtnClick(_ sender: Any) {
        
        SwiftyStoreKit.purchaseProduct("商品ID", quantity: 3, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                
                let receipt = AppleReceiptValidatorX(service: .production)
                let password = "公共秘钥在 itunesConnect App 内购买项目查看"
                SwiftyStoreKit.verifyReceipt(using: receipt, password: password, completion: { (result) in
                    switch result {
                    case .success(let receipt):
                        print("receipt--->\(receipt)")
                        break
                    case .error(let error):
                        print("error--->\(error)")
                        break
                    }
                })
                
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getList()
    }
    
    func getList() {
        SwiftyStoreKit.retrieveProductsInfo(["商品ID"]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            } else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            } else {
                print("Error: \(result.error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


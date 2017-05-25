//
//  AppleReceiptValidator.swift
//  AppPurchasesDemo
//
//  Created by Xinxibin on 2017/5/25.
//  Copyright © 2017年 xiaoxin. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import Alamofire

class AppleReceiptValidatorX: ReceiptValidator {
    
    public enum VerifyReceiptURLType: String {
        // 服务器地址这里使用了 Python 建立的服务器
        // 线上环境
        // ···case productionAppSotre = "https://sandbox.itunes.apple.com/verifyReceipt"
        case production = "http://192.168.1.157:5000/"
        // 测试环境
        case sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"
    }
    
    public init(service: VerifyReceiptURLType = .production) {
        self.service = service
    }
    
    private let service: VerifyReceiptURLType
    
    func validate(receipt: String, password autoRenewPassword: String?, completion: @escaping (VerifyReceiptResult) -> Void) {
        
        var parame = ["receipt-data":receipt]
        if let password = autoRenewPassword {
            parame["password"] = password
        }
        
        Alamofire
            .request(service.rawValue, method: .post, parameters: parame, headers: nil)
            .responseJSON(completionHandler: { (response: DataResponse<Any>) in
                
                switch response.result {
                case .success(let value):
                    completion(.success(receipt: value as! ReceiptInfo))
                case .failure(_):
                    completion(.error(error: .receiptInvalid(receipt: [:], status: ReceiptStatus.none)))
                }
            })
    }
}

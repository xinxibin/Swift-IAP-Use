## iOS 开发内购实现

## 代码环境
- iOS IAP by Swift 3.1.1 , Xcode 8.3.2
- Really Really Easy to use

## 需要的轮子
- [SwiftyStoreKit](https://github.com/bizz84/SwiftyStoreKit)
- [Alamofire](https://github.com/Alamofire/Alamofire)

## 开始使用 （ItunesConnect）

[Github Demo 地址](https://github.com/xinxibin/Swift-IAP-Use)

<!--more-->
### 你需要有一个 App ( 肯定要有 付费的开发者账号 )

- 在 itunesconnect.apple.com，中配置内购项目，如图右侧有一个（查看公共秘钥）（验证购买时需要使用）
![](http://oahmyhzk1.bkt.clouddn.com/image/jpg14956962545142.jpg)
- 点击加号新建购买项目
![](http://oahmyhzk1.bkt.clouddn.com/image/png4CB8F5CE-A1A5-4036-83DA-7ADEB3F2336E.png)

- 根据你们产品的不同选择对应的项目
- 创建就很简单了，每一项都有介绍这里就不多说了
- 创建沙箱技术测试员用于内购测试使用
![](http://oahmyhzk1.bkt.clouddn.com/image/png08C982C8-C3C9-4405-8014-61947C73F3DD.png)
- 内容可以随便填写，需要注意的是 邮箱 和 密码需要记住（后面需要使用）
![](http://oahmyhzk1.bkt.clouddn.com/image/png66BDEA86-FCE4-4510-BFBA-BF99A35F7206.png)


### 使用此 App 的bundleID 唯一标示
- 创建一个项目，项目的 bundleID 要与 iTunesconnect 中项目的id相同。

### Cocoapods 导入 SwiftyStoreKit

- pod 'SwiftyStoreKit'  （内购轮子）
- pod 'Alamofire'       （网络请求轮子）

## 一切准备就绪-下面代码部分
- AppDelegate 添加以下代码，在启动时添加应用程序的观察者可确保在应用程序的所有启动过程中都会持续，从而允许您的应用程序接收所有支付队列通知。如果此时有任何待处理的事务，将触发block，以便可以更新应用程序状态和UI。如果没有待处理的事务，则不会调用。

```swift
import SwiftyStoreKit


func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

	SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
	
	    for purchase in purchases {
	
	        if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
	
               if purchase.needsFinishTransaction {
                   // Deliver content from server, then:
                   SwiftyStoreKit.finishTransaction(purchase.transaction)
               }
               print("purchased: \(purchase)")
	        }
	    }
	}
 	return true
}
```

- 获取内购项目列表

```swift 
func getList() {
        SwiftyStoreKit.retrieveProductsInfo(["图1 内购项目的 产品ID 这个一般存储在服务器里"]) { result in
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

```
- 这里是我的列表，因为就创建一个内购项目所以就一个
![](http://oahmyhzk1.bkt.clouddn.com/image/pngC65895BF-CF49-47B1-87DD-27BDB7609FED.png)

- 购买 需要使用刚你在沙箱测试添加的邮箱密码登录（退出AppStore账号），购买的时候会提示你输入账号密码，此账号非appid账号，不能登录在appstore 走成功就说明购买成功了，简单点就是扣钱了，这时候是没有验证处理的。

```swift 
SwiftyStoreKit.purchaseProduct("产品ID", quantity: 1, atomically: true) { result in
    switch result {
    case .success(let purchase):
        print("Purchase Success: \(purchase.productId)")
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
```
- 验证购买，
    * 本地验证 （不推荐，越狱设备可能存在刷单漏洞）
    * 服务端验证 （推荐使用）
    
```swift 
    // 本地验证（SwiftyStoreKit 已经写好的类） AppleReceiptValidator
    // .production 苹果验证  .sandbox 本地验证
 let receipt = AppleReceiptValidator(service: .production)
 let password = "公共秘钥"
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
```

- 服务器验证 AppleReceiptValidatorX 是我重写的类，里面就是把得到的data发给服务器让服务器来验证，返回成功失败即可不需要其他数据。

    
## 完成了，是不是很简单，是不是很好理解。

- SwiftyStoreKit 不知能做购买，还能恢复购买，具体使用方法见 [SwiftyStoreKit](https://github.com/bizz84/SwiftyStoreKit)


## 基本阅读 --> SwiftyStoreKit 

 * [Apple - WWDC16, Session 702: Using Store Kit for In-app Purchases with Swift 3](https://developer.apple.com/videos/play/wwdc2016/702/)
* [Apple - TN2387: In-App Purchase Best Practices](https://developer.apple.com/library/content/technotes/tn2387/_index.html)
* [Apple - About Receipt Validation](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Introduction.html)
* [Apple - Receipt Validation Programming Guide](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1)
* [Apple - Validating Receipts Locally](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateLocally.html)
* [Apple - Working with Subscriptions](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/Subscriptions.html#//apple_ref/doc/uid/TP40008267-CH7-SW6)
* [Apple - Offering Subscriptions](https://developer.apple.com/app-store/subscriptions/)
* [Apple - Restoring Purchased Products](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/Restoring.html#//apple_ref/doc/uid/TP40008267-CH8-SW9)
* [objc.io - Receipt Validation](https://www.objc.io/issues/17-security/receipt-validation/)
* [Apple TN 2413 - Why are my product identifiers being returned in the invalidProductIdentifiers array?](https://developer.apple.com/library/content/technotes/tn2413/_index.html#//apple_ref/doc/uid/DTS40016228-CH1-TROUBLESHOOTING-WHY_ARE_MY_PRODUCT_IDENTIFIERS_BEING_RETURNED_IN_THE_INVALIDPRODUCTIDENTIFIERS_ARRAY_)
* [Invalid Product IDs](http://troybrant.net/blog/2010/01/invalid-product-ids/): Checklist of common mistakes

## 延伸阅读

[App 内购验证](http://www.cnblogs.com/zhaoqingqing/p/4597794.html)

[官方文档]
(https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html)

## License
AppPurchasesDemo is released under the MIT license. See LICENSE for details.


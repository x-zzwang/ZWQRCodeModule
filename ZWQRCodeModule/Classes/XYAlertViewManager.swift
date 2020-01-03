//
//  XYAlertViewManager.swift
//  ScanDemo
//
//  Created by Zane wang on 2019/12/12.
//  Copyright © 2019 Zane wang. All rights reserved.
//

import UIKit

class XYAlertViewManager: NSObject {

    func alertMessage(message : String) {
        let alert = UIAlertController.init(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.sync { ///保证在主线程执行
            UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
}

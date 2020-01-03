//
//  XYSelImageServer.swift
//  ScanDemo
//
//  Created by Zane wang on 2019/12/11.
//  Copyright © 2019 Zane wang. All rights reserved.
//

import UIKit

protocol XYSelImageServerDelegate : NSObjectProtocol {
    
    func selCompl(_ image : UIImage)
    
}

///选择照片识别
class XYSelImageServer : NSObject {
    
    weak var delegate : XYSelImageServerDelegate?
    
    lazy var picker : UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        return picker
    }()
    
    func startSelImage() {
        ///先检查用户相册授权
        let authormanager = XYImageAuthorManager()
        authormanager.delegate = self as XYImageAuthorManagerDelegate
        authormanager.checkAndRequestAccessForType(type: kPrivacyTypePhotos)
    }
    
    func toSelImage() {
        DispatchQueue.main.async {
            UIApplication.shared.delegate?.window??.rootViewController?.present(self.picker, animated: true, completion: nil)
        }
    }
    
}

///授权的回调
extension XYSelImageServer : XYImageAuthorManagerDelegate {
    
    func accessCompl() {
        self.toSelImage()
    }
    
    func refuse(_ msg: String) {
        let alertManager = XYAlertViewManager.init()
        alertManager.alertMessage(message: msg)
    }
    
}

///选择图片的回调
extension XYSelImageServer : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage];
        if self.delegate != nil {
            self.delegate?.selCompl(image as! UIImage)
        }
    }
    
}

extension XYSelImageServer : UINavigationControllerDelegate { }

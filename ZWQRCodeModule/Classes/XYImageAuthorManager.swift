//
//  XYImageAuthorManager.swift
//  ScanDemo
//
//  Created by Zane wang on 2019/12/12.
//  Copyright © 2019 Zane wang. All rights reserved.
//

import UIKit
import Photos

let kPrivacyTypePhotos = 1
let kPrivacyTypeCamera = 2

protocol XYImageAuthorManagerDelegate : NSObjectProtocol {
    
    func accessCompl()            ///权限检查成功
    func refuse(_ msg : String)   ///权限检查失败
    
}

class XYImageAuthorManager: NSObject {

    weak var delegate : XYImageAuthorManagerDelegate?
    
    func checkAndRequestAccessForType(type: Int) {
        switch type {
        case kPrivacyTypePhotos: do {
            ///相册权限
            let authorizationStatus = PHPhotoLibrary.authorizationStatus()
            if authorizationStatus == PHAuthorizationStatus.authorized {
                if self.delegate != nil {
                    self.delegate?.accessCompl()
                }
            }
            else {
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == PHAuthorizationStatus.authorized {
                        if self.delegate != nil {
                            self.delegate?.accessCompl()
                        }
                    }
                    else {
                       if self.delegate != nil && (self.delegate?.responds(to: Selector.init(("refuse:"))))! {
                            self.delegate?.refuse("使用照片识别二维码或者设置头像，请打开手机设置->隐私->照片，并允许APP访问照片")
                        }
                    }
                }
            }
            }
        case kPrivacyTypeCamera: do {
            ///相机权限
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if authorizationStatus == AVAuthorizationStatus.authorized {
                if self.delegate != nil {
                    self.delegate?.accessCompl()
                }
            }
            else {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if granted {
                        if self.delegate != nil {
                            self.delegate?.accessCompl()
                        }
                    }
                    else {
                       if self.delegate != nil {
                            self.delegate?.refuse("使用相机扫码或者设置头像，请打开手机设置->隐私->相机，并允许APP访问相机")
                        }
                    }
                })
            }
            }
        default: break
        }
    }
    
}

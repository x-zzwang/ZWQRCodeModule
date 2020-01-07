//
//  XYScanViewModel.swift
//  ScanDemo
//
//  Created by Zane wang on 2019/12/11.
//  Copyright © 2019 Zane wang. All rights reserved.
//

import UIKit

class XYScanViewModel : NSObject {
    
    weak var viewController : UIViewController?
    
    ///扫码管理类
    lazy var scanServer : XYScanServer = {
        let config : XYScanConfig = XYScanConfig.init()
        let optionAreaLeft : CGFloat = 57.0
        let optionAreaWidth = kScreenW - (optionAreaLeft * 2.0)
        let optionAreaHeight = optionAreaWidth + 180.0
        let optionAreaTop = (kScreenH - optionAreaHeight) / 2.0
        config.rectOfInterest = CGRect.init(x: optionAreaTop / kScreenH,
                                            y: optionAreaLeft / kScreenW,
                                            width: (optionAreaTop + optionAreaHeight) / kScreenH,
                                            height: (optionAreaLeft + optionAreaWidth) / kScreenW)
        config.scanArea = kScreenBounds
        let scanServer = XYScanServer.init(config: config, currentController: self.viewController!)
        scanServer.delegate = self as XYScanServerDelegate
        return scanServer
    }()
    
    ///图片选择管理类
    lazy var selImageServer : XYSelImageServer = {
        let selImageServer = XYSelImageServer()
        selImageServer.delegate = self as XYSelImageServerDelegate
        return selImageServer
    }()
    
    ///是否可以开关闪光灯
    func canTroch() -> Bool {
        return self.scanServer.device != nil && self.scanServer.device!.hasTorch
    }
    
}

///用户操作事件
extension XYScanViewModel : XYScanOptionViewDelegate {
    
    public func openPhotoLibrary() {
        self.selImageServer.startSelImage()
    }
    
    public func switchFlash(_ sender: UIButton) {
        if !self.canTroch() {
            self.scanServer.deviceInitError()
            return
        }
        self.scanServer.switchFlash(sender)
    }
}

///识别的回调
extension XYScanViewModel : XYScanServerDelegate {
    
    func scanImageError(_ error: String) {
        print(error)
    }
    
    func scanImageResult(_ result: String) {
        print(result)
    }
    
    func scanResult(_ result: String) {
        print(result)
    }
    
}

///选择图片的回调
extension XYScanViewModel : XYSelImageServerDelegate {
    
    func selCompl(_ image: UIImage) {
        self.scanServer.scanImage(image)
    }
    
}

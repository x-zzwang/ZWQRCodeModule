//
//  XYScanServer.swift
//  ScanDemo
//
//  Created by Zane wang on 2019/12/11.
//  Copyright © 2019 Zane wang. All rights reserved.
//

import UIKit
import AVFoundation

///扫描配置类
class XYScanConfig: NSObject {
    
    ///相机区域
    var scanArea: CGRect?
    ///扫描区域
    var rectOfInterest: CGRect?
    ///识别类型
    lazy var metadataObjectTypes : [AVMetadataObject.ObjectType] = {
        let metadataObjectTypes : [AVMetadataObject.ObjectType] = [
            AVMetadataObject.ObjectType.qr,
            AVMetadataObject.ObjectType.ean13,
            AVMetadataObject.ObjectType.ean8,
            AVMetadataObject.ObjectType.code128,
            AVMetadataObject.ObjectType.code39,
            AVMetadataObject.ObjectType.code93,
            AVMetadataObject.ObjectType.code39Mod43,
            AVMetadataObject.ObjectType.pdf417,
            AVMetadataObject.ObjectType.aztec,
            AVMetadataObject.ObjectType.upce,
            AVMetadataObject.ObjectType.interleaved2of5,
            AVMetadataObject.ObjectType.itf14,
            AVMetadataObject.ObjectType.dataMatrix
        ]
        return metadataObjectTypes
    }()
    
}

///扫描结果回调协议
protocol XYScanServerDelegate : NSObjectProtocol {
    
    ///扫描结果的回调
    func scanResult(_ result : String)
    ///识别图片失败
    func scanImageError(_ error : String)
    ///识别图片成功
    func scanImageResult(_ result : String)
    
}

class XYScanServer : NSObject {
    
    ///回调协议
    weak var delegate : XYScanServerDelegate?
    ///Config
    var config : XYScanConfig?
    ///Controller
    weak var currentController : UIViewController?
    ///AVFoundation
    var device : AVCaptureDevice?             ///创建相机
    var input : AVCaptureDeviceInput?         ///创建输入设备
    var output : AVCaptureMetadataOutput?     ///创建输出设备
    var session : AVCaptureSession?           ///创建捕捉类
    var preview : AVCaptureVideoPreviewLayer? ///视觉输出预览层
    
    
    init(config : XYScanConfig, currentController : UIViewController) {
        ///初始化扫描
        super.init()
        self.config = config
        self.currentController = currentController
        let authormanager = XYImageAuthorManager()
        authormanager.delegate = self as XYImageAuthorManagerDelegate
        authormanager.checkAndRequestAccessForType(type: kPrivacyTypeCamera)
    }
    
    ///配置扫描
    func capture() {
        self.device = AVCaptureDevice.default(for: AVMediaType.video)
        if device == nil {///这是模拟器
            self.deviceInitError()
            return
        }
        do {
            self.input = try  AVCaptureDeviceInput.init(device: self.device!)
        }
        catch {
            self.deviceInitError()
            return
        }
        self.output = AVCaptureMetadataOutput.init()
        self.output?.setMetadataObjectsDelegate(self as AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
        self.output?.rectOfInterest = self.config!.rectOfInterest!
        self.session = AVCaptureSession.init()
        self.session?.canSetSessionPreset(AVCaptureSession.Preset.high)
        if (self.session?.canAddInput(self.input!))! {
            self.session?.addInput(self.input!)
        }
        else {
            self.deviceInitError()
            return
        }
        if (self.session?.canAddOutput(self.output!))! {
            self.session?.addOutput(self.output!)
            self.output?.metadataObjectTypes = self.config?.metadataObjectTypes
        }
        else {
            self.deviceInitError()
            return
        }
        self.preview = AVCaptureVideoPreviewLayer.init(session: self.session!)
        self.preview!.frame = self.config!.scanArea!;
        self.currentController?.view.layer.insertSublayer(self.preview!, at: 0)
        self.session?.startRunning()
    }
    
    ///设备初始化失败
    func deviceInitError() {
        XYAlertViewManager.init().alertMessage(message: "设备初始化失败")
    }
    
    ///开关闪光灯
    func switchFlash(_ sender : UIButton) {
        if self.device != nil && self.device!.hasTorch {
            if device?.torchMode == .off { /// 开灯
                do {
                    try device?.lockForConfiguration()
                }
                catch {
                    return
                }
                device?.torchMode = .on
                device?.unlockForConfiguration()
                sender.isSelected = true
            }
            else { /// 关灯
                do {
                    try device?.lockForConfiguration()
                }
                catch {
                    return
                }
                device?.torchMode = .off
                device?.unlockForConfiguration()
                sender.isSelected = false
            }
        }
    }
    
    ///开始扫描
    @objc func startScan() {
        if (self.session != nil) {
            self.session?.startRunning()
        }
    }
    
    ///取消扫描
    func cancelScan() {
        if (self.session != nil) {
            self.session?.stopRunning()
        }
    }
    
    ///识别图片中的二维码
    func scanImage(_ image : UIImage) {
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: CIImage.init(cgImage: image.cgImage!))
        if features?.count == 0 {
            if self.delegate != nil {
                self.delegate?.scanImageError("未识别到二维码")
            }
        }
        else {
            var scanResult : [String] = [];
            for feature in features! {
                let qrCodeFeature = feature as! CIQRCodeFeature
                scanResult.append(qrCodeFeature.messageString!)
            }
            if self.delegate != nil {
                self.delegate?.scanImageResult(scanResult.first!)
            }
        }
    }
    
}

///授权的回调
extension XYScanServer : XYImageAuthorManagerDelegate {
    
    func accessCompl() {
        self.capture()
    }
    
    func refuse(_ msg: String) {
        let alertManager = XYAlertViewManager.init()
        alertManager.alertMessage(message: msg)
    }
    
}

///视频流回调
extension XYScanServer : AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count > 0 {
            if self.delegate != nil {
                let result = metadataObjects.first! as? AVMetadataMachineReadableCodeObject
                self.delegate?.scanResult((result?.stringValue)!)
                self.cancelScan()
                self.perform(#selector(startScan), with: nil, afterDelay: 2.5)
            }
        }
        else { ///无识别结果
        }
        
    }
    
}

//
//  XYScanViewController.swift
//  ScanDemo
//
//  Created by Zane wang on 2019/12/11.
//  Copyright © 2019 Zane wang. All rights reserved.
//

import UIKit
import Masonry

///上下文字对齐的按钮
class XYOptionButton : UIButton {
    
    func updateButtonInset() {
        let interval = CGFloat(10.0)
        let imageSize : CGSize = self.imageView!.frame.size
        let titleSize : CGSize = self.titleLabel!.frame.size
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left:-imageSize.width, bottom: -imageSize.height - interval, right: 0)
        self.imageEdgeInsets = UIEdgeInsets(top: -titleSize.height - interval, left: 0, bottom: 0, right: -titleSize.width)
    }
    
}

///扫描操作区
protocol XYScanOptionViewDelegate : NSObjectProtocol {
    func openPhotoLibrary()
    func switchFlash(_ sender : UIButton)
}

class XYScanOptionView : UIView {
    
    ///按钮标示
    let kOpenLibrTag = 11
    let kSweitchFlashTag = 12
    ///回调协议
    weak var delegate : XYScanOptionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xy_addSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let openLibrary : XYOptionButton = self.viewWithTag(kOpenLibrTag) as! XYOptionButton
        let openFlash : XYOptionButton = self.viewWithTag(kSweitchFlashTag) as! XYOptionButton
        
        openLibrary.mas_makeConstraints({ (make) in
            make?.left.bottom()?.inset()(15.0)
            make?.width.height()?.offset()(84.0)
        })
        
        openLibrary.updateButtonInset()
        
        openFlash.mas_makeConstraints({ (make) in
            make?.right.bottom()?.inset()(15.0)
            make?.width.height()?.offset()(84.0)
        })
        
        openFlash.updateButtonInset()
        
    }
    
    @objc func xy_addSubView() {
        ///打开相册
        let openPhotoLibraryBtn = XYOptionButton.init(type: UIButton.ButtonType.custom)
        openPhotoLibraryBtn.setImage(UIImage.init(named: "scan_image"), for: UIControl.State.normal)
        openPhotoLibraryBtn.setTitle("从相册导入", for: UIControl.State.normal)
        openPhotoLibraryBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        openPhotoLibraryBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        openPhotoLibraryBtn.tag = kOpenLibrTag
        openPhotoLibraryBtn.addTarget(self, action: #selector(xy_clickBtn(_:)), for: UIControl.Event.touchUpInside)
        self.addSubview(openPhotoLibraryBtn)
        ///切换闪光灯
        let switchFlashBtn = XYOptionButton.init(type: UIButton.ButtonType.custom)
        switchFlashBtn.setImage(UIImage.init(named: "scan_open_light"), for: UIControl.State.normal)
        switchFlashBtn.setImage(UIImage.init(named: "scan_close_light"), for: UIControl.State.selected)
        switchFlashBtn.setTitle("打开手电筒", for: UIControl.State.normal)
        switchFlashBtn.setTitle("关闭手电筒", for: UIControl.State.selected)
        switchFlashBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        switchFlashBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        switchFlashBtn.tag = kSweitchFlashTag
        switchFlashBtn.addTarget(self, action: #selector(xy_clickBtn(_:)), for: UIControl.Event.touchUpInside)
        self.addSubview(switchFlashBtn)
        
    }
    
    @objc func xy_clickBtn(_ sender : UIButton) {
        switch sender.tag {
        case kOpenLibrTag: do {
            ///打开相册
            if self.delegate != nil {
                self.delegate?.openPhotoLibrary()
            }
            }
        case kSweitchFlashTag: do {
            ///切换闪光灯
            if self.delegate != nil {
                self.delegate?.switchFlash(sender)
            }
            }
        default: break
        }
    }
    
}

///视图管理类
public class XYScanViewController: UIViewController {
    
    var maskWithHole : CAShapeLayer?
    
    ///ViewModel
    lazy var viewMode : XYScanViewModel = {
        let viewModel = XYScanViewModel()
        viewModel.viewController = self
        return viewModel
    }()
    
    ///扫描的操作区
    lazy var scanOptionView : XYScanOptionView = {
        let scanOptionView = XYScanOptionView()
        scanOptionView.delegate = self.viewMode as XYScanOptionViewDelegate
        return scanOptionView
    }()
    
    ///扫码框
    lazy var scanBoxView : UIImageView = {
        let scanBoxView = UIImageView.init(image: UIImage.init(named: "scan_box"))
        return scanBoxView
    }()
    
    ///添加蒙层
    func addShapLayerToScreen() {
        let maskWithHole = CAShapeLayer()
        let smallFrame = self.scanBoxView.superview?.convert(self.scanBoxView.frame, to: self.view)
        let smallerRect = CGRect.init(x: (kScreenW - smallFrame!.width) / 2.0,
                                      y: (kScreenH - smallFrame!.height) / 2.0,
                                      width: smallFrame!.width,
                                      height: smallFrame!.height)
        let maskPath = UIBezierPath()
        maskPath.move(to: CGPoint.init(x: kScreenBounds.minX, y:  kScreenBounds.minY))
        maskPath.addLine(to: CGPoint.init(x: kScreenBounds.minX, y:  kScreenBounds.maxY))
        maskPath.addLine(to: CGPoint.init(x: kScreenBounds.maxX, y:  kScreenBounds.maxY))
        maskPath.addLine(to: CGPoint.init(x: kScreenBounds.maxX, y:  kScreenBounds.minY))
        maskPath.addLine(to: CGPoint.init(x: kScreenBounds.minX, y:  kScreenBounds.minY))
        maskPath.move(to: CGPoint.init(x: smallerRect.minX, y:  smallerRect.minY))
        maskPath.addLine(to: CGPoint.init(x: smallerRect.minX, y:  smallerRect.maxY))
        maskPath.addLine(to: CGPoint.init(x: smallerRect.maxX, y:  smallerRect.maxY))
        maskPath.addLine(to: CGPoint.init(x: smallerRect.maxX, y:  smallerRect.minY))
        maskPath.addLine(to: CGPoint.init(x: smallerRect.minX, y:  smallerRect.minY))
        maskWithHole.path = maskPath.cgPath
        maskWithHole.fillRule = kCAFillRuleEvenOdd
        maskWithHole.fillColor = UIColor.init(white: 0, alpha: 0.5).cgColor
        self.view.layer.addSublayer(maskWithHole)
        self.maskWithHole = maskWithHole
        self.view.layer.masksToBounds = true
    }
    
    ///页面生命周期
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(scanBoxView)
        self.view.addSubview(scanOptionView)
        self.title = "扫码"
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewMode.scanServer.startScan()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewMode.scanServer.cancelScan()
    }
    
    ///布局
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scanBoxView.mas_makeConstraints { (make) in
            make?.centerX.centerY()?.offset()
        }
        
        scanOptionView.mas_makeConstraints { (make) in
            make?.centerX.offset()
            make?.top.equalTo()(scanBoxView.mas_bottom)
            make?.width.equalTo()(248.0)
            make?.height.equalTo()(114.0)
        }
        
        if (self.maskWithHole == nil) {
            self.addShapLayerToScreen()
        }
        
    }
    
}

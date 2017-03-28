//
//  TwoDimensionViewController.swift
//  THSC
//
//  Created by mac on 16/4/17.
//  Copyright © 2016年 黄杰. All rights reserved.
//

import UIKit

typealias TwoDimensionViewControllerCancelCallback=(twoDimensionViewController: TwoDimensionViewController) -> Void
typealias TwoDimensionViewControllerSuncessCallback=(twoDimensionViewController: TwoDimensionViewController, typeNum: NSString) -> Void
typealias TwoDimensionViewControllerFailCallback=(twoDimensionViewController: TwoDimensionViewController) -> Void

class TwoDimensionViewController: BaseViewController {
    
    var SYQRCodeCancelBlock = TwoDimensionViewControllerCancelCallback?()
    var SYQRCodeSuncessBlock = TwoDimensionViewControllerSuncessCallback?()
    var SYQRCodeFailBlock = TwoDimensionViewControllerFailCallback?()
    
    private var line: UIImageView!//交互线
    private var lineTimer: NSTimer!//交互线控制
    private var qrVideoPreviewLayer: AVCaptureVideoPreviewLayer!////读取
    private var qrSession: AVCaptureSession!//会话

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigation()
        
        self.initAVCaptureDevice()
        
        self.setOverlayPickerView()
        
        self.startSYQRCodeReading()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        self.navigationController?.navigationBar.lt_setBackgroundColor(UIColor.whiteColor())
    }
    
    //MARK:设置导航栏
    private func setupNavigation() {
        
        self.titleViewColor = UIColor(hexString: "434343")
        self.setupTitleView("扫一扫")
        
//        self.backColor = UIColor(hexString: "434343")
//        self.setupPushBackBtn(true)
    }
    
    func createBackBtn() {
        
        let btn = UIButton( type: .Custom)
        btn.setTitle("返回", forState: .Normal)
        btn.imageView?.contentMode = .Left
        btn.frame = CGRectMake(0, 0, 44, 44)
        btn.setImage(UIImage(named: "back_btn"), forState: .Normal)
        btn.addTarget(self, action: #selector(TwoDimensionViewController.cancleSYQRCodeReading), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    //取消扫描
    func cancleSYQRCodeReading() {
        
        self.SYQRCodeCancelBlock!(twoDimensionViewController: self)
        
        self.dismissViewControllerAnimated(true) { 
            
        }
        
    }
    
    private func initAVCaptureDevice() {
        
        let kReaderViewWH: CGFloat = 200.0
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var input = AVCaptureDeviceInput()
        let output = AVCaptureMetadataOutput()//设置输出(Metadata元数据)
        do {
            input = try AVCaptureDeviceInput(device: device)
        }catch {
            return
        }
        
        //设置输出的代理
        //使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        output.rectOfInterest = self.getReaderViewBoundsWithSize(CGSizeMake(kReaderViewWH, kReaderViewWH))
        
        //拍摄会话
        let session = AVCaptureSession()
        // 读取质量，质量越高，可读取小尺寸的二维码
        if session.canSetSessionPreset(AVCaptureSessionPreset1920x1080) {
            session.sessionPreset = AVCaptureSessionPreset1920x1080
        }else if session.canSetSessionPreset(AVCaptureSessionPreset1280x720) {
            session.sessionPreset = AVCaptureSessionPreset1280x720
        }else {
            session.sessionPreset = AVCaptureSessionPresetPhoto
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        //设置输出的格式
        //一定要先设置会话的输出为output之后，再指定输出的元数据类型
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
        //设置预览图层
        let preview = AVCaptureVideoPreviewLayer( session: session)
        //设置preview图层的属性
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        //设置preview图层的大小
        preview.frame = self.view.layer.bounds
        //将图层添加到视图的图层
        self.view.layer.insertSublayer(preview, atIndex: 0)
        self.qrVideoPreviewLayer = preview
        self.qrSession = session
    }
    
    private func setOverlayPickerView() {
        
        let kReaderViewWH: CGFloat = 200.0
        let kLineMaxY: CGFloat = 385.0
        
        //画中间的基准线
        let lineX: CGFloat = (Common.screenWidth - 300) / 2.0
        let lineY: CGFloat = 185
        let lineW: CGFloat = 300
        let lineH: CGFloat = 12 * 300 / 320.0
        self.line = UIImageView(frame: CGRectMake(lineX, lineY, lineW, lineH))
        self.line.image = UIImage(named: "QRCodeLine")
        self.view.addSubview(self.line)
        
        //最上部view
        let upView = UIImageView(frame: CGRectMake(0, 0, Common.screenWidth, lineY))
        upView.alpha = 0.3
        upView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(upView)
        
        //左侧的view
        let leftView = UIImageView(frame: CGRectMake(0, lineY, (Common.screenWidth - kReaderViewWH) / 2.0, kReaderViewWH))
        leftView.alpha = 0.3
        leftView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(leftView)
        
        //右侧的view
        let rightView = UIImageView(frame: CGRectMake(Common.screenWidth - CGRectGetMaxX(leftView.frame), lineY, CGRectGetMaxX(leftView.frame), kReaderViewWH))
        rightView.alpha = 0.3
        rightView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(rightView)
        
        let space_h: CGFloat = Common.screenHeight - kLineMaxY
        //底部view
        let downView = UIImageView(frame: CGRectMake(0, kLineMaxY, Common.screenWidth, space_h))
        downView.alpha = 0.3
        downView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(downView)
        
        //四个边角
        var cornerImage = UIImage(named: "QRCodeTopLeft")
        
        //左侧的view
        let leftView_image = UIImageView(frame: CGRectMake(CGRectGetMaxX(leftView.frame) - (cornerImage?.size.width)! / 2.0, CGRectGetMaxY(upView.frame) - (cornerImage?.size.height)! / 2.0, (cornerImage?.size.width)!, (cornerImage?.size.height)!))
        leftView_image.image = cornerImage
        self.view.addSubview(leftView_image)
        
        cornerImage = UIImage(named: "QRCodeTopRight")
        //右侧的view
        let rightView_image = UIImageView(frame: CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage!.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage!.size.height / 2.0, (cornerImage?.size.width)!, (cornerImage?.size.height)!))
        rightView_image.image = cornerImage
        self.view.addSubview(rightView_image)
        
        cornerImage = UIImage(named: "QRCodebottomLeft")
        //底部view
        let downView_image = UIImageView(frame: CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage!.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage!.size.height / 2.0, (cornerImage?.size.width)!, (cornerImage?.size.height)!))
        downView_image.image = cornerImage
        self.view.addSubview(downView_image)
        
        cornerImage = UIImage(named: "QRCodebottomRight")

        let downViewRight_image = UIImageView(frame: CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage!.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage!.size.height / 2.0, (cornerImage?.size.width)!, (cornerImage?.size.height)!))
        downViewRight_image.image = cornerImage
        self.view.addSubview(downViewRight_image)
        
        //说明label
        let labIntroudction = UILabel()
        labIntroudction.backgroundColor = UIColor.clearColor()
        labIntroudction.frame = CGRectMake(CGRectGetMaxX(leftView.frame), CGRectGetMinY(downView.frame) + 25, kReaderViewWH, kReaderViewWH)
        labIntroudction.textAlignment = .Center
        labIntroudction.font = UIFont.boldSystemFontOfSize(13.0)
        labIntroudction.textColor = UIColor.whiteColor()
        labIntroudction.text = "将二维码置于框内,即可自动扫描"
        self.view.addSubview(labIntroudction)
        
        let scanCropView = UIView(frame: CGRectMake(CGRectGetMaxX(leftView.frame) - 1, lineY, self.view.frame.size.width - 2 * CGRectGetMaxX(leftView.frame) + 2, kReaderViewWH + 2))
        scanCropView.layer.borderColor = UIColor.greenColor().CGColor
        scanCropView.layer.borderWidth = 2.0
        self.view.addSubview(scanCropView)
    }
    
    private func getReaderViewBoundsWithSize(asize: CGSize) -> CGRect {
        Common.screenHeight
        Common.screenWidth
        return CGRectMake(185 / Common.screenHeight, ((Common.screenWidth - asize.width) / 2.0) / Common.screenWidth, asize.height / Common.screenHeight, asize.width / Common.screenWidth)
        
    }
    
    //MARK:交互事件
    func startSYQRCodeReading() {
        
        self.lineTimer = NSTimer.eoc_scheduledTimerWithTimeInterval(1.0 / 20, block: {
            self.animationLine()
            }, repeats: true)
        if self.qrSession != nil {
            self.qrSession.startRunning()
        }
    }
    
    func stopSYQRCodeReading() {
        
        if (self.lineTimer != nil) {
            self.lineTimer.invalidate()
            self.lineTimer = nil
        }
        
        self.qrSession.stopRunning()
        
    }
    
    //MARK:上下滚动交互线
    func animationLine() {
        
        let kLineMinY: CGFloat = 185
        let kLineMaxY: CGFloat = 385
        var frame = self.line.frame
            
        if self.line.frame.origin.y >= kLineMaxY {
            frame.origin.y = kLineMinY
            self.line.frame = frame
        }else {
            UIView.animateWithDuration(1.0 / 20, animations: {
                frame.origin.y = frame.origin.y + 5
                self.line.frame = frame
                }, completion: { (finish) in
                    
            })
        }
        
    }
    
    func cancel(mathFunction:(twoDimensionViewController: TwoDimensionViewController) -> Void ){
        SYQRCodeCancelBlock = mathFunction
    }
    
    func suncess(mathFunction:(twoDimensionViewController: TwoDimensionViewController, typeNum: NSString) -> Void ){
        SYQRCodeSuncessBlock = mathFunction
    }
    
    func fail(mathFunction:(twoDimensionViewController: TwoDimensionViewController) -> Void ){
        SYQRCodeFailBlock = mathFunction
    }
    
    deinit {
        if (self.qrSession != nil) {
            self.qrSession.stopRunning()
            self.qrSession = nil
        }
        
        if (self.qrVideoPreviewLayer != nil) {
            self.qrVideoPreviewLayer = nil
        }
        
        if (self.lineTimer != nil) {
            self.lineTimer.invalidate()
            self.lineTimer = nil
        }
        
    }
    
}

//MARK:AVCaptureMetadataOutputObjectsDelegate
extension TwoDimensionViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    //此方法是在识别到QRCode，并且完成转换
    //如果QRCode的内容越大，转换需要的时间就越长
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        let metadataObject = metadataObjects[0]
        //输出扫描字符串
        if metadataObjects.count > 0 {
            self.SYQRCodeSuncessBlock!(twoDimensionViewController: self, typeNum: metadataObject.stringValue)
        }
        
        self.stopSYQRCodeReading()
        
        self.dismissViewControllerAnimated(false) { 
            
        }
    }
}

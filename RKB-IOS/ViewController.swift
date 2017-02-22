import UIKit
import VideoCore
import AVFoundation
import SwiftyJSON
import PermissionScope
class ViewController: UIViewController,
    VCSessionDelegate,
AVCaptureMetadataOutputObjectsDelegate {
    
    
    @IBOutlet weak var previewView: UIView!
    	
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var rtmpUrlTXF: UITextField!
    @IBOutlet weak var gameIdTXF: UITextField!
    
    @IBOutlet weak var bitrateText: UILabel!
    @IBOutlet weak var btnConnect: UIButton!
    
    @IBOutlet weak var scoreView: UIView!
    
    @IBOutlet weak var gameInfo: UILabel!
    
    
    
    var isPanelViewMoving: Bool = false
    var isAutoCon: Bool = false
    var session: VCSimpleSession?
    var bitrate: Int = 0;
    
    var liveData: LiveData!
    var picker: Picker!
    
    var captureSession: AVCaptureSession!
    
    let pscope = PermissionScope()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true;
        
        
        
        
        // self.pscope.addPermission(CameraPermission(),
        //                           message: "直播需要摄像头权限")
        // //                    self.pscope.addPermission(NotificationsPermission(notificationCategories: nil),
        // //                                         message: "We use this to send you\r\nspam and love notes")
        // //                    self.pscope.addPermission(LocationWhileInUsePermission(),
        // //                                         message: "We use this to track\r\nwhere you live")
        
        // // Show dialog with callbacks
        // self.pscope.show({ finished, results in
        //     print("got results \(results)")
        // }, cancelled: { (results) -> Void in
        //     print("thing was cancelled")
        // })
        //                    self.checkCamera();
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted: Bool) in
                if granted {
                    print("granted")
                    
                }
                else {
                    print("not granted")
                    
                    //                     self.pscope.addPermission(CameraPermission(),
                    //                                          message: "直播需要摄像头权限")
                    // //                    self.pscope.addPermission(NotificationsPermission(notificationCategories: nil),
                    // //                                         message: "We use this to send you\r\nspam and love notes")
                    // //                    self.pscope.addPermission(LocationWhileInUsePermission(),
                    // //                                         message: "We use this to track\r\nwhere you live")
                    
                    //                     // Show dialog with callbacks
                    //                     self.pscope.show({ finished, results in
                    //                         print("got results \(results)")
                    //                     }, cancelled: { (results) -> Void in
                    //                         print("thing was cancelled")
                    //                     })
                    //                    self.checkCamera();
                }
            })
        }
        // Do any additional setup after loading the view, typically from a nib.
        initVideoCore()
        initUI()
        loadLocalData()
        //        test()
    }
    func loadLocalData(){
        let data = UserDefaults.standard;
        
        if let rtmpUrl  = data.string(forKey: "rtmpUrl"){
            print(rtmpUrl);
            self.rtmpUrlTXF.text = rtmpUrl;
        }
        
    }
    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authStatus {
        case AVAuthorizationStatus.authorized:
            print("AVAuthorizationStatus.Authorized")
        case AVAuthorizationStatus.denied:
            print("AVAuthorizationStatus.Denied")
        case AVAuthorizationStatus.notDetermined:
            print("AVAuthorizationStatus.NotDetermined")
        case AVAuthorizationStatus.restricted:
            print("AVAuthorizationStatus.Restricted")
        default:
            print("AVAuthorizationStatus.Default")
        }
        
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        previewView = nil
        session?.delegate = nil;
    }
    /// override
    
    func test() {
        rtmpUrlTXF.text = "rtmp://rtmp.icassi.us/live/test"
        rtmpUrlTXF.text = "rtmp://202.96.203.27/live/test"
        gameIdTXF.text = "78"
    }
    
    @IBAction func onTouchScan(_ sender: Any) {
        view.backgroundColor = UIColor.black
        rescanCount = 3
        getQRCode()
    }
    
    @IBAction func onTouchSync(_ sender: Any) {
        //        Timer.scheduledTimer(timeInterval: 0.033, target: self, selector: #selector(captureWebView), userInfo: nil, repeats: true);
        //        captureWebView()
        if liveData == nil {
            liveData = LiveData(wsUrl: "http://tcp.lb.liangle.com:3081", gameId: gameIdTXF.text ?? "")
        } else {
            liveData.con(wsUrl: "http://tcp.lb.liangle.com:3081", gameId: gameIdTXF.text ?? "")
        }
        
        self.liveData.session = session
        self.liveData.onMsg = self.onMsg
        view.endEditing(true);
    }
    
    @IBAction func onBit(_ sender: Any) {
        picker.fadeIn()
    }
    
    @IBAction func onTouchBtnConnect(_ sender: Any) {
        con()
    }
    
    @IBAction func onVolChange(_ sender: Any) {
        //        volSlider.value
    }
    
    //                     gesture
    @IBAction func onTapView(_ sender: Any) {
        view.endEditing(true);
        picker.fadeOut()
    }
    
    @IBAction func onSwipeRight(_ sender: Any) {
        print("swipe right")
        //        volSlider.isHidden = false
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("shake!")
            //            abort()
            //            UIControl().sendAction(Selector("suspend"), to: UIApplication.shared, for: nil)
        }
    }
    
    
    func onSwipeDown(recognizer: UISwipeGestureRecognizer) {
        print("swipe down")
        if panelView.isHidden && !isPanelViewMoving {
            isPanelViewMoving = true
            self.panelView.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                var basketTopFrame = self.panelView.frame
                basketTopFrame.origin.y += 120
                self.panelView.frame = basketTopFrame
            }, completion: {
                finished in
                self.isPanelViewMoving = false
            })
            
            
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
                var bf = self.scoreView.frame
                bf.origin.y += 80
                self.scoreView.frame = bf
            }, completion: {
                finished in
                //                self.isPanelViewMoving = false
            })
        }
        
    }
    
    func onSwipe(recognizer: UISwipeGestureRecognizer) {
        print("swipe up")
        if !panelView.isHidden && !isPanelViewMoving {
            isPanelViewMoving = true
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                var basketTopFrame = self.panelView.frame
                basketTopFrame.origin.y -= 120
                self.panelView.frame = basketTopFrame
            }, completion: {
                finished in
                self.isPanelViewMoving = false
                self.panelView.isHidden = true
            })
            
            
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
                var bf = self.scoreView.frame
                bf.origin.y -= 80
                self.scoreView.frame = bf
            }, completion: {
                finished in
                //                self.isPanelViewMoving = false
            })
        }
        
        //        let point = recognizer.locationInView(self.view)
        //这个点是滑动的起点
        //        print(point.x)
        //        print(point.y)
    }
    //                     gesture
    
    
    
    //    func initWebView() {
    //        if let url = URL(string: "http://apple.com") {
    //            print("load url")
    //            let request = URLRequest(url: url)
    //            webView.loadRequest(request)
    //        }
    //    }
    ///scan
    func found(code: String) {
        //        {"rtmp":"rtmp://rtmp.icassi.us/live/test1","gameId":"78"}
        if let dataFromString = code.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            
            if let url = json["rtmp"].string {
                rtmpUrlTXF.text = url
            }
            
            if let gameId = json["gameId"].string {
                gameIdTXF.text = gameId
            }
        }
        print(code)
    }
    
    
    var rescanCount: Int = 0
    
    func getQRCode() {
        rescanCount -= 1
        UIGraphicsBeginImageContextWithOptions(previewView.bounds.size, true, UIScreen.main.scale)
        previewView.drawHierarchy(in: previewView.bounds, afterScreenUpdates: true)
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        let image = CIImage.init(image: uiImage!)
        UIGraphicsEndImageContext()
        let ciContext = CIContext.init()
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: ciContext, options: nil)
        let features = detector?.features(in: image!)
        guard features != nil && features!.count > 0 else {
            if (rescanCount > 0) {
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getQRCode), userInfo: nil, repeats: false);
            }
            return;
        }
        let feature = features?[0] as! CIQRCodeFeature
        found(code: feature.messageString!)
        
        if oneButtonAlert == nil {
            oneButtonAlert = UIAlertView(title: "！",
                                         message: "扫码完成", delegate: nil, cancelButtonTitle: "确定")
            
        }
        oneButtonAlert?.show()
        
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hideAlert), userInfo: nil, repeats: false);
    }
    
    var oneButtonAlert: UIAlertView?
    func hideAlert() {
        oneButtonAlert?.dismiss(withClickedButtonIndex: 0, animated: true)
    }
    
    let rect1 = CGRect(x: 300, y: 300, width: 512, height: 512);
    //////////////////////scan
    
    //    func captureWebView() {
    //        //capture the screenshot
    ////        let rect = CGRect(x: 300, y: 300, width: 512, height: 512);
    //        UIGraphicsBeginImageContext(rect1.size)
    //        if let ctx = UIGraphicsGetCurrentContext() {
    //            webView.layer.render(in: ctx)
    //            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
    ////            UIGraphicsEndImageContext()
    //
    //            self.session?.addPixelBufferSource(screenshot, with: rect1)
    //        }
    //
    //    }
    func connectionStatusChanged(_ sessionState: VCSessionState) {
        print("state:", session!.rtmpSessionState)
        switch session!.rtmpSessionState {
        case .starting:
            btnConnect.setTitle("链接中...", for: UIControlState())
        case .started:
            btnConnect.setTitle("断开链接", for: UIControlState())
        default:
            btnConnect.setTitle("开始推流", for: UIControlState())
            if isAutoCon {
                isAutoCon = false
                con()
            }
        }
    }
    
    func onMsg(msg: String) {
        print(msg)
        gameInfo.text = msg
    }
    
    func onVol(v:Float){
        session?.micGain = v
    }
    
    func onPick(b: Int,title:String) {
        picker.fadeOut()
        
        self.bitrate = b
        bitrateText.text = title
        
        session?.endRtmpSession()
        session?.previewView.removeFromSuperview()
        
        initVideoCore()
        isAutoCon = true
    }
    
    func con() {
        if rtmpUrlTXF.text != "" {
            let data = UserDefaults.standard;
            data.setValue(rtmpUrlTXF.text, forKey: "rtmpUrl")
            switch session?.rtmpSessionState {
            case .none, .previewStarted?, .ended?, .error?:
                session?.startRtmpSession(withURL: rtmpUrlTXF.text, andStreamKey: "")
            default:
                session?.endRtmpSession()
                break
            }
        }
    }
    
    func initVideoCore() {
        if bitrate == 0 {
            bitrate = 1000000
        }
        session = VCSimpleSession(videoSize: CGSize(width: 1280, height: 720), frameRate: 30, bitrate: Int32(bitrate), useInterfaceOrientation: true)
        session?.aspectMode = VCAspectMode.aspectModeFit
        
        //        session?.micGain = 1.0
        //        session?.continuousAutofocus = true
        //        session?.continuousExposure = true
        //        session!.orientationLocked = true
        
        previewView.addSubview(session!.previewView)
        session!.previewView.frame = previewView.bounds
        session!.delegate = self
    }
    
    func initUI() {
        picker = Picker(parent:view)
        picker.onVol = self.onVol
        picker.onPick = self.onPick
        
        let bottomFrame = CGRect(origin: CGPoint(x: 0, y: view.bounds.size.height), size: scoreView.frame.size)
        scoreView.frame = bottomFrame
        
        //
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeDown))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(swipeDown)
    }
    
}


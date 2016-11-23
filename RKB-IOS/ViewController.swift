import UIKit
import VideoCore
import AVFoundation
import SwiftyJSON

class ViewController: UIViewController,
        VCSessionDelegate,
        AVCaptureMetadataOutputObjectsDelegate {


    @IBOutlet weak var previewView: UIView!

    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var rtmpUrlTXF: UITextField!
    @IBOutlet weak var gameIdTXF: UITextField!

    @IBOutlet weak var btnConnect: UIButton!

    @IBOutlet weak var scoreView: UIView!

    @IBOutlet weak var gameInfo: UILabel!

    @IBOutlet weak var volSlider: UISlider!


    var isPanelViewMoving: Bool = false
    var session: VCSimpleSession?
    var bitrate: Int = 0;

    var liveData: LiveData!
    var picker: Picker!

    var captureSession: AVCaptureSession!

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true;
        // Do any additional setup after loading the view, typically from a nib.
        initVideoCore()
        initUI()

        test()
    }

    @IBAction func onSwipeRight(_ sender: Any) {
        print("swipe right")
        volSlider.isHidden = false
    }

    @IBAction func onVolChange(_ sender: Any) {
//        volSlider.value
    }

    func test() {
        rtmpUrlTXF.text = "rtmp://rtmp.icassi.us/live/test"
        gameIdTXF.text = "78"
    }
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

    @IBAction func onBit(_ sender: Any) {
//        if (self.menu?.isDescendant(of: self.view) == true) {
//            self.menu?.hideMenu()
//        } else {
//            self.menu?.showMenuFromView(self.view)
//        }
    }
//////////////////////scan
    @IBAction func onTouchScan(_ sender: Any) {
        view.backgroundColor = UIColor.black
        rescanCount = 3
        getQRCode()
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

    @IBAction func onTouchSync(_ sender: Any) {
//        Timer.scheduledTimer(timeInterval: 0.033, target: self, selector: #selector(captureWebView), userInfo: nil, repeats: true);
//        captureWebView()
        if liveData == nil {
            liveData = LiveData(wsUrl: "http://tcp.lb.hoopchina.com:3081", gameId: gameIdTXF.text ?? "")
        } else {
            liveData.con(wsUrl: "http://tcp.lb.hoopchina.com:3081", gameId: gameIdTXF.text ?? "")
        }
        self.liveData.session = session
        self.liveData.onMsg = self.onMsg
        view.endEditing(true);
    }

    func onMsg(msg: String) {
        print(msg)
        gameInfo.text = msg
    }

    func onPick(b: Int) {
        self.bitrate = b
        session?.bitrate = Int32(b)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    @IBAction func onTapView(_ sender: Any) {
        view.endEditing(true);
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("shake!")
//            abort()
//            UIControl().sendAction(Selector("suspend"), to: UIApplication.shared, for: nil)
        }
    }

    @IBAction func onTouchBtnConnect(_ sender: Any) {
        if rtmpUrlTXF.text != "" {
            switch session?.rtmpSessionState {
            case .none, .previewStarted?, .ended?, .error?:
                session?.startRtmpSession(withURL: rtmpUrlTXF.text, andStreamKey: "")
            default:
                session?.endRtmpSession()
                break
            }
        }

    }

    func initUI() {
        picker = Picker()
        view.addSubview(picker.ui)
        picker.onPick = self.onPick

        let bottomFrame = CGRect(origin: CGPoint(x: 0, y: view.bounds.size.height), size: scoreView.frame.size)
        scoreView.frame = bottomFrame
        volSlider.frame.origin = CGPoint(x: 50, y: view.bounds.size.height - 75)
        volSlider.isHidden = true


        //
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeDown))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(swipeDown)

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

    func initVideoCore() {
//        if self.bitrate!=0{
//
//        }
        session = VCSimpleSession(videoSize: CGSize(width: 1280, height: 720), frameRate: 30, bitrate: 1000000, useInterfaceOrientation: true)
        session?.aspectMode = VCAspectMode.aspectModeFit
        

//        session?.continuousAutofocus = true
//        session?.continuousExposure = true


//        session!.orientationLocked = true
        previewView.addSubview(session!.previewView)
        session!.previewView.frame = previewView.bounds
        session!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        previewView = nil
        session?.delegate = nil;
    }


    func connectionStatusChanged(_ sessionState: VCSessionState) {
        switch session!.rtmpSessionState {
        case .starting:
            btnConnect.setTitle("链接中...", for: UIControlState())

        case .started:
            btnConnect.setTitle("断开链接", for: UIControlState())

        default:
            btnConnect.setTitle("开始推流", for: UIControlState())
        }
    }

//    @IBAction func btnFilterTouch(_ sender: AnyObject) {
//        switch self.session!.filter {
//
//        case .normal:
//            self.session!.filter = .gray
//
//        case .gray:
//            self.session!.filter = .invertColors
//
//        case .invertColors:
//            self.session!.filter = .sepia
//
//        case .sepia:
//            self.session!.filter = .fisheye
//
//        case .fisheye:
//            self.session!.filter = .glow
//
//        case .glow:
//            self.session!.filter = .normal
//
//        default: // Future proofing
//            break
//        }
//    }

}


import UIKit
import VideoCore
import AVFoundation
import SwiftyJSON

class ViewController: UIViewController, VCSessionDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var rtmpUrlTXF: UITextField!
    @IBOutlet weak var gameIdTXF: UITextField!

    @IBOutlet weak var btnConnect: UIButton!

    @IBOutlet weak var scoreView: UIView!

//    @IBOutlet weak var gameInfo: UITextField!
//    @IBOutlet weak var leftInfo: UILabel!

//    @IBOutlet weak var leftInfo: UITextView!
    @IBOutlet weak var gameInfo: UILabel!

    var isPanelViewMoving: Bool = false
    var session: VCSimpleSession?

    var liveData: LiveData!


    var captureSession: AVCaptureSession!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        UIApplication.shared.isIdleTimerDisabled = true;
        // Do any additional setup after loading the view, typically from a nib.
        initVideoCore()

    }
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

//////////////////////scan
    @IBAction func onTouchScan(_ sender: Any) {
        view.backgroundColor = UIColor.black
        UIGraphicsBeginImageContextWithOptions(previewView.bounds.size, true, UIScreen.main.scale)
        previewView.drawHierarchy(in: previewView.bounds, afterScreenUpdates: true)
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        let image = CIImage.init(image: uiImage!)
        UIGraphicsEndImageContext()
        let ciContext = CIContext.init()
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: ciContext, options: nil)
        let features = detector?.features(in: image!)
        guard features != nil && features!.count > 0 else {
            return;
        }
        let feature = features?[0] as! CIQRCodeFeature
        found(code: feature.messageString!)


    }

    @IBAction func onTouchSync(_ sender: Any) {
        liveData = LiveData(wsUrl: "http://tcp.lb.hoopchina.com:3081", gameId: gameIdTXF.text ?? "")
        self.liveData.session = session

        self.liveData.onMsg = self.onMsg
        view.endEditing(true);
    }

    func onMsg(msg: String) {

        print(msg)
        gameInfo.text = msg
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
            abort()
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
        let bottomFrame = CGRect(origin: CGPoint(x: 0, y: view.bounds.size.height), size: scoreView.frame.size)
        scoreView.frame = bottomFrame

//        
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
        session = VCSimpleSession(videoSize: CGSize(width: 1280, height: 720), frameRate: 30, bitrate: 1000000, useInterfaceOrientation: true)
        session?.aspectMode = VCAspectMode.aspectModeFit
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


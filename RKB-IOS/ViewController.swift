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
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning();
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: readableObject.stringValue);
        }

        dismiss(animated: true)
    }

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
//        view.addSubview(session!.previewView)
        print(code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
//////////////////////scan
    @IBAction func onTouchScan(_ sender: Any) {
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            failed()
            return
        }

//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
//        previewLayer.frame = view.layer.bounds;
//        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//        view.layer.addSublayer(previewLayer);

        captureSession.startRunning();
    }

    @IBAction func onTouchSync(_ sender: Any) {
        liveData = LiveData(wsUrl: "http://tcp.lb.hoopchina.com:3081", gameId: gameIdTXF.text ?? "")
        self.liveData.session = session
        view.endEditing(true);
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("shake!")
            abort()
//            UIControl().sendAction(Selector("suspend"), to: UIApplication.shared, for: nil)
        }
    }

    @IBAction func onTouchBtnConnect(_ sender: Any) {
        switch session?.rtmpSessionState {
        case .none, .previewStarted?, .ended?, .error?:
            session?.startRtmpSession(withURL: rtmpUrlTXF.text, andStreamKey: "")

        default:
            session?.endRtmpSession()
            break
        }
    }


    func initUI() {
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
        }

//        let point = recognizer.locationInView(self.view)
        //这个点是滑动的起点
//        print(point.x)
//        print(point.y)
    }

    func initVideoCore() {
        session = VCSimpleSession(videoSize: CGSize(width: 1280, height: 720), frameRate: 30, bitrate: 1000000, useInterfaceOrientation: false)
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


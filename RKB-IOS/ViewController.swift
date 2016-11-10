import UIKit
import VideoCore

class ViewController: UIViewController, VCSessionDelegate {

    @IBOutlet weak var previewView: UIView!
//    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var gameIdTXF: UITextField!

    @IBOutlet weak var btnConnect: UIButton!


    var isPanelViewMoving:Bool = false
//    var uiView: UIView!
//    var btnCon: UIButton!
//    var gameIDText: UITextField!
    var session: VCSimpleSession?

    var liveData: LiveData!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        UIApplication.shared.isIdleTimerDisabled = true;
        // Do any additional setup after loading the view, typically from a nib.
        initVideoCore()
    }
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
////        UIView.animate(withDuration:0.7, delay: 1.0, options: .curveEaseOut, animations: {
////            var basketTopFrame = self.panelView.frame
////            basketTopFrame.origin.y -= 100
////
//////            var basketBottomFrame = self.basketBottom.frame
//////            basketBottomFrame.origin.y += basketBottomFrame.size.height
////
////            self.panelView.frame = basketTopFrame
//////            self.basketBottom.frame = basketBottomFrame
////        }, completion: { finished in
////            print("Basket doors opened!")
////        })
//    }
    @IBAction func onTouchSync(_ sender: Any) {
        liveData = LiveData(wsUrl: "http://tcp.lb.hoopchina.com:3081", gameId: gameIdTXF.text ?? "")
        self.liveData.session = session
//
        view.endEditing(true);


//
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {

        if motion == .motionShake {
            print("shake!")
            UIControl().sendAction(Selector("suspend"), to: UIApplication.shared, for: nil)

        }
//        if motion == .motionShake && randomNumber == SHAKE
//        {
//            debugPrint("SHAKE RECEIVED")
//            correctActionPerformed = true
//        }
//        else if motion == .motionShake && randomNumber != SHAKE
//        {
//            debugPrint("WRONG ACTION")
//            wrongActionPerformed = true
//        }
//        else
//        {
//            debugPrint("WRONG ACTION")
//            wrongActionPerformed = true
//        }
    }
//    override func motionEnded(motion: UIEventSubtype,
//                              withEvent event: UIEvent?) {
//
//        if motion == .MotionShake {
//
//            //Comment: to terminate app, do not use exit(0) bc that is logged as a crash.
//            UIControl().sendAction(#selector(NSURLSessionTask.suspend), to: UIApplication.sharedApplication(), forEvent: nil)
//
//            UIControl().sendAction(Selector("suspend"), to: UIApplication.sharedApplication(), forEvent: nil)
//        }
//    }

    @IBAction func onTouchBtnConnect(_ sender: Any) {
        switch session?.rtmpSessionState {
        case .none, .previewStarted?, .ended?, .error?:
            session?.startRtmpSession(withURL: "rtmp://rtmp.icassi.us/live", andStreamKey: "test1")

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
        if panelView.isHidden && !isPanelViewMoving{
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
        if !panelView.isHidden && !isPanelViewMoving{
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

    @IBAction func btnFilterTouch(_ sender: AnyObject) {
        switch self.session!.filter {

        case .normal:
            self.session!.filter = .gray

        case .gray:
            self.session!.filter = .invertColors

        case .invertColors:
            self.session!.filter = .sepia

        case .sepia:
            self.session!.filter = .fisheye

        case .fisheye:
            self.session!.filter = .glow

        case .glow:
            self.session!.filter = .normal

        default: // Future proofing
            break
        }
    }
}


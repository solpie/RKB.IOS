/*

 Video Core
 Copyright (c) 2014 James G. Hurley

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

 */

//
//  ViewController.swift
//  SampleBroadcaster-Swift
//
//  Created by Josh Lieberman on 4/11/15.
//  Copyright (c) 2015 videocore. All rights reserved.
//

import UIKit
import VideoCore

class ViewController: UIViewController, VCSessionDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var btnConnect: UIButton!


    var uiView: UIView!
    var btnCon: UIButton!

    var session: VCSimpleSession?

    var liveData: LiveData = LiveData(wsUrl: "http://tcp.lb.hoopchina.com:3081", gameId: "78")


    override func viewDidLoad() {
        super.viewDidLoad()


        self.initUI()
        // 22:23
        UIApplication.shared.isIdleTimerDisabled = true;
        // Do any additional setup after loading the view, typically from a nib.

        initVideoCore()

        self.liveData.session = session
    }

    func initUI() {
        self.uiView = UIView(frame: CGRect(x: 10, y: 100, width: 500, height: 100))
        self.view.addSubview(self.uiView)

        let gameIdLabel = UILabel(frame: CGRect(x: 10, y: 50, width: 100, height: 50))
        gameIdLabel.text = "Game ID:"
        gameIdLabel.textColor = UIColor.red
        gameIdLabel.backgroundColor = UIColor.white
        self.uiView.addSubview(gameIdLabel)

        self.btnCon = UIButton(frame: CGRect(x: 10, y: 100, width: 120, height: 50))
        self.btnCon.setTitle("开始推流", for: UIControlState.normal)
//        self.btnCon.rou
        self.uiView.addSubview(self.btnCon)

        //
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipeDown))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
    }

    func onSwipeDown(recognizer: UISwipeGestureRecognizer) {
        print("swipe down")

        self.uiView.isHidden = false

    }

    func onSwipe(recognizer: UISwipeGestureRecognizer) {
        print("swipe up")
        self.uiView.isHidden = true

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
        btnCon = nil
        btnConnect = nil
        previewView = nil
        session?.delegate = nil;
    }

    @IBAction func btnConnectTouch(_ sender: AnyObject) {
        switch session?.rtmpSessionState {
        case .none, .previewStarted?, .ended?, .error?:
            session?.startRtmpSession(withURL: "rtmp://rtmp.icassi.us/live", andStreamKey: "test")

        default:
            session?.endRtmpSession()
            break
        }
    }

    func connectionStatusChanged(_ sessionState: VCSessionState) {
        switch session!.rtmpSessionState {
        case .starting:
            btnConnect.setTitle("Connecting", for: UIControlState())

        case .started:
            btnConnect.setTitle("Disconnect", for: UIControlState())

        default:
            btnConnect.setTitle("Connect", for: UIControlState())
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


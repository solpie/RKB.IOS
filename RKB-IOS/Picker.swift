//
// Created by ocean on 2016/11/23.
// Copyright (c) 2016 videocore. All rights reserved.
//

import Foundation

//: Playground - noun: a place where people can play

import UIKit

class Picker {
    let ui: UIView
//    var bg: UIView?
    let ctn:UIView
    let btnArr = ["2.5M 码率": ["idx": 0, "bitrate": 2500000],
                  "2M 码率": ["idx": 1, "bitrate": 2000000],
                  "1.5M 码率": ["idx": 2, "bitrate": 1500000],
                  "1M 码率": ["idx": 3, "bitrate": 1000000],
                  "退出": ["idx": 4, "bitrate": 0]]
    var onPick: ((_: Int,_:String) -> Void)!

    init(parent:UIView) {
        let btnHeight = 60
        
        ctn = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: btnHeight * 5))
        ctn.backgroundColor = UIColor.white
        
        ui = UIView(frame: CGRect(x: 0, y: 0, width:Int(parent.frame.size.width), height: Int(parent.frame.size.height)))
//        ui.alpha = 0.3
        ui.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        ui.addSubview(ctn)
        
        for (title, v) in btnArr {
            let e = UITapGestureRecognizer(target: self, action: #selector(self.tgButton(_:)))
            let btn = UIButton(frame: CGRect(x: 0, y: btnHeight * v["idx"]!, width: 200, height: btnHeight))
            btn.setTitle(title, for: .normal)
            btn.layer.borderWidth = 1
            btn.tag = v["bitrate"]!
            btn.addGestureRecognizer(e)
            btn.setTitleColor(UIColor.black, for: .normal)
            ctn.addSubview(btn)
        }
        
        self.ctn.frame.origin = CGPoint(x: parent.bounds.size.width, y: 0)
        parent.addSubview(ui)
        
        ui.isHidden = true
    }

    func fadeOut() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            var f = self.ctn.frame
            f.origin.x = (self.ui.superview?.frame.size.width)!
            self.ctn.frame = f
        }, completion: {
            finished in
            self.ui.isHidden = true
        })
    }
    func fadeIn()
    {
        self.ui.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            var f = self.ctn.frame
            f.origin.x = self.ui.frame.size.width - 200
            self.ctn.frame = f
        }, completion: {
            finished in
            
        })
        
    }
    func getTitle(b:Int)->String{
        for (title,v) in btnArr{
            if v["bitrate"]==b{
                return title
            }
        }
        return ""
    }
    
    @objc func tgButton(_ sender: UITapGestureRecognizer) {
        if let b = sender.view?.tag {
            print("trigger", b)
            if b == 0 {
                abort()
            } else {
                self.onPick!(b,getTitle(b: b))
            }
        }
    }

}


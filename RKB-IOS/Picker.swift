//
// Created by ocean on 2016/11/23.
// Copyright (c) 2016 videocore. All rights reserved.
//

import Foundation

//: Playground - noun: a place where people can play

import UIKit

class Picker {
    let ui: UIView
    let btnArr = ["2M 码率": 2000000,
                  "1.5M 码率": 1500000,
                  "退出": 0]
    var onPick: ((_: Int) -> Void)!

    init() {
        ui = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        ui.backgroundColor = UIColor.white
        var i = 0
        for (title, b) in btnArr {
            let e = UITapGestureRecognizer(target: self, action: #selector(self.tgButton(_:)))
            let btn = UIButton(frame: CGRect(x: 0, y: 30 * i, width: 200, height: 30))
            btn.setTitle(title, for: .normal)
            btn.layer.borderWidth = 1
            btn.tag = b
            btn.addGestureRecognizer(e)
            btn.setTitleColor(UIColor.black, for: .normal)
            ui.addSubview(btn)
            i += 1
        }
    }

    @objc func tgButton(_ sender: UITapGestureRecognizer) {
        if let b = sender.view?.tag {
            print("trigger", b)
            if b == 0 {
                abort()
            } else {
                self.onPick!(b)
            }
        }
    }
}


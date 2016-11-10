//
//  LiveData.swift
//  SampleBroadcaster-Swift
//
//  Created by ocean on 2016/11/9.
//  Copyright © 2016年 videocore. All rights reserved.
//

import Foundation
import SIOSocket
import SwiftyJSON
import VideoCore

class GameData{
    
    var GameIdx:Int;
    var L_name:String;
    var L_score:Int;
    var L_foul:Int;
    
    var R_name:String;
    var R_score:Int;
    var R_foul:Int;
    
    init(idx:Int ,
         leftName:String,leftScore:Int,leftFoul:Int,
         rightName:String,rightScore:Int,rightFoul:Int) {
        self.GameIdx = idx;
        
        self.L_name = leftName;
        self.L_score = leftScore;
        self.L_foul = leftFoul;
        
        self.R_name = rightName;
        self.R_score = rightScore;
        self.R_foul = rightFoul;
    }
    
    func getDrawText() -> String {
        return "idx:\(self.GameIdx) state:\n"+"LP:\(self.L_name) S:\(self.L_score) F:\(self.L_foul)\n"+"RP:\(self.R_name) S:\(self.R_score) F:\(self.R_foul)\n";
    }
    
    
    
    func getInfoDrawText() -> String {
        return "idx:\(self.GameIdx) state:\n"
    }
    
    
    func getLPDrawText() -> String {
        return "LP:\(self.L_name) \nS:\(self.L_score) F:\(self.L_foul)\n"
        
//        +"RP:\(self.R_name) S:\(self.R_score) F:\(self.R_foul)\n";
    }
    
    
    func getRPDrawText() -> String {
        return "RP:\(self.R_name) \nS:\(self.R_score) F:\(self.R_foul)\n";
    }
}
class LiveData {
//    var ws:SIOSocket;
    var gameId:String;
    var gameData:GameData?;
    var session:VCSimpleSession?;
    
    init(wsUrl:String ,gameId:String){
        print("new LiveData\n")
//        var ws:SIOSocket;
        self.gameId = gameId;
        
        
        SIOSocket.socket(withHost: wsUrl, response: {
            [weak self](socket: SIOSocket?)->Void in
            
            socket?.onConnect = {
                ()->Void in
                print("connected\n gameId: \(gameId)")
//                self!.socket.emit("connected", args: [self!.userName])
                
                socket?.emit("passerbyking", args: [ ["game_id":gameId,"page":"score"]])

            }
//
            socket?.on("wall", callback: { (data:Any) in
                let jd = JSON(data)[0]
                let evt = jd["et"].stringValue
                print("event",evt)
                switch evt {
                case "init":
                    self!.onInit(data: jd)
                case "updateScore":
                    self!.onUpdate(data: jd)
                case "commitGame":
                    self!.onCommit(data: jd)
                default:
                    print(jd)
                }
            })
//            
        })
        
    }
    
    
    func onInit(data:JSON) {
        
//        print(
        let lp = data["player"]["left"];
        let rp = data["player"]["right"];
        
        self.gameData = GameData(idx:data["gameIdx"].intValue,
                                 leftName: lp["name"].stringValue, leftScore:lp["leftScore"].intValue, leftFoul: lp["leftFoul"].intValue,
                                 rightName: rp["name"].stringValue, rightScore: rp["rightScore"].intValue, rightFoul: rp["rightFoul"].intValue)
        print(self.gameData?.getDrawText() ?? "");
//        print("init",self.gameData ?? default value)
        
        self.render()
    }
    
    
    func onCommit(data:JSON) {
        
//        self.gameData?.L_score =
        
    }
    
    
    func onUpdate(data:JSON) {
        let ls = data["leftScore"]
        let lf = data["leftFoul"]
        let rs = data["rightScore"]
        let rf = data["rightFoul"]
        
        if ls.error == nil{
            self.gameData?.L_score = ls.intValue
        }
        if lf.error == nil{
            self.gameData?.L_foul = lf.intValue
        }
        
        if rs.error == nil{
            self.gameData?.R_score = rs.intValue
        }
        if rf.error == nil{
            self.gameData?.R_foul = rf.intValue
        }
        
        print(self.gameData?.getDrawText() ?? "");
        
        self.render()
        
    }
    
    func render(){
        if (self.session != nil){
        
            UIGraphicsBeginImageContext(CGSize(width: 512, height: 512))
            let ctx = UIGraphicsGetCurrentContext();
            //fill bg
            ctx?.setFillColor(UIColor.gray.cgColor)
            ctx?.fill(CGRect(x: 0, y: 0, width: 512, height: 512))
            //draw text
            ctx?.setTextDrawingMode(CGTextDrawingMode.fill)
            ctx?.setFillColor(UIColor.red.cgColor)
            var s = self.gameData?.getInfoDrawText() ?? ""
//            let text = s as NSString
            let font = UIFont(name:"Arial",size:40)
            (s as NSString).draw(at: CGPoint(x:0,y:0), withAttributes: [NSFontAttributeName:font!,NSForegroundColorAttributeName:UIColor.green])
            s = self.gameData?.getLPDrawText() ?? ""
            (s as NSString).draw(at: CGPoint(x:0,y:40), withAttributes: [NSFontAttributeName:font!,NSForegroundColorAttributeName:UIColor.red])
            s = self.gameData?.getRPDrawText() ?? ""
            (s as NSString).draw(at: CGPoint(x:0,y:120), withAttributes: [NSFontAttributeName:font!,NSForegroundColorAttributeName:UIColor.blue])
            let image2 = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            let rect = CGRect(x:300, y:600, width:512, height:512);
            self.session?.addPixelBufferSource(image2, with: rect)
        }
    }
}

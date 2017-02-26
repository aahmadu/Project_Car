//
//  GameViewController.swift
//  iOS_P_RC
//
//  Created by Ahmed Ahmadu on 07/01/2017.
//  Copyright © 2017 Ahmed Ahmadu. All rights reserved.
//

import UIKit
import CoreMotion
import CocoaAsyncSocket

class GameViewController: UIViewController, GCDAsyncSocketDelegate {
    
    let addr = "192.168.0.9"
    let port:UInt16 = 5050
    var cSocket:GCDAsyncSocket!
    
    var rollCurrMinMax: [Double] = [0.0, 0.0, 0.0]
    var pitchCurrMinMax: [Double] = [0.0, 0.0, 0.0]
    var mappedRoll: Double = 0.0
    var mappedPitch: Double = 0.0
    
    var package: [UInt8] = [0,0,0]
    var stringData = String()
    
    var motionManager = CMMotionManager()
    
    var driveButtonPressed = false
    
    var currentCheckPoint: String = ""
    var checkPoints: [String: [UInt8]] = ["A": [151, 23, 174, 33, 15], "B": [35, 85, 138, 217, 37]]
    
    var trackArray = [String]()
    //var CP = CheckPoint()
    
    var timeTrail: TimeTrialGame!
    
    var cancelGame = false
    
    var gameStarted = false
    
    @IBOutlet weak var throttleShift: UIImageView!
    @IBOutlet weak var throttleSlider: UIImageView!
    @IBOutlet weak var driveButton: UIButton!
    @IBAction func showButton(_ sender: Any) {
        if throttleSlider.isHidden {
            throttleSlider.isHidden = false
            throttleShift.isHidden = false
            driveButton.isHidden = true
        }else{
            throttleSlider.isHidden = true
            throttleShift.isHidden = true
            driveButton.isHidden = false
        }
    }
    
    @IBOutlet weak var videoView: UIWebView!
    
    @IBOutlet var rollLabel: UILabel!
    @IBOutlet var pitchLabel: UILabel!
    
    @IBOutlet weak var NoOfCPoints: UILabel!
    @IBOutlet weak var CPsCrossed: UILabel!
    @IBOutlet weak var NextCP: UILabel!
    @IBOutlet weak var timeMinLabel: UILabel!
    @IBOutlet weak var timeSecLabel: UILabel!
    @IBOutlet weak var timeMilLabel: UILabel!


    var counter = [0, 0, 0]
    
    
    @IBAction func driveButtonIn(_ sender: AnyObject) {
        rollCurrMinMax[2] = rollCurrMinMax[0] + 0.90
        rollCurrMinMax[1] = rollCurrMinMax[0] - 0.90
        
        pitchCurrMinMax[2] = pitchCurrMinMax[0] + 0.50
        pitchCurrMinMax[1] = pitchCurrMinMax[0] - 0.50
        
        driveButtonPressed = true
        
    }
    @IBAction func driveButtonOut(_ sender: AnyObject) {
        driveButtonPressed = false
        mappedRoll=0.0
        mappedPitch=0.0
        rollLabel.text=("0")
        pitchLabel.text=("0")
        
    }
    
    @IBAction func AlertAreYouSure(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to exit", preferredStyle: UIAlertControllerStyle.alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){(ACTION) in
            self.cancelGame = true
            self.performSegue(withIdentifier: "gameToHome", sender: nil)
        }
        
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapValues(array: [Double]) -> (Double)?{
        
        let xValue = array[0]
        let inMin  = array[1]
        let inMax  = array[2]
        let outMin  = array[3]
        let outMax  = array[4]
        var mappedValue = (xValue - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
        
        if mappedValue < 0 {mappedValue=0;}
        else if mappedValue > 255 {mappedValue=255;}
        
        return mappedValue
    }
    
    func outputRPY(_ data: CMDeviceMotion){
        if throttleSlider.isHidden{
            rollCurrMinMax[0]    = data.attitude.roll
        }else{
            rollCurrMinMax    = [Double(throttleSlider.center.y),330,50]
            pitchCurrMinMax[2] =  0.50
            pitchCurrMinMax[1] = -0.50
        }
        pitchCurrMinMax[0]   = data.attitude.pitch
        
        if driveButtonPressed == true {
            if gameStarted == false {
                timeTrail.start(currentVC: self, min: timeMinLabel, sec: timeSecLabel, mil: timeMilLabel)
                gameStarted = true
            }
            usleep(useconds_t(0.0001))
            mappedRoll = mapValues(array: [rollCurrMinMax[0], rollCurrMinMax[1], rollCurrMinMax[2], 0, 256])!
            rollLabel.text  = String(format: "%.0f", mappedRoll)
            package[0]=UInt8(mappedRoll)
            
            mappedPitch = mapValues(array: [pitchCurrMinMax[0], pitchCurrMinMax[1], pitchCurrMinMax[2], 0, 256])!
            pitchLabel.text  = String(format: "%.0f", mappedPitch)
            package[1]=UInt8(mappedPitch)
            
            let data2 = Data(bytes: package)
            cSocket.write(data2, withTimeout: -1.0, tag: 0)
            
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self.view)
            if position.x > 550 && position.y >= 50 && position.y <= 300{
                driveButtonPressed = true
                throttleSlider.center.y = position.y
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touches.first != nil) {
            throttleSlider.center.y = CGFloat(10+(330+10)/2)
            driveButtonPressed = false
            mappedRoll=0.0
            mappedPitch=0.0
            rollLabel.text=("0")
            pitchLabel.text=("0")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
// declare here and change trackArray
        //NoOfCPoints.text = String(trackArray.count)
        driveButton.isHidden = true
        
//        CP.setTrack(trackArray: trackArray, CPDict: checkPoints)
// so check which game was selected and ...
        
        //Gyro config
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (deviceMotion: CMDeviceMotion?, NSError) -> Void in
            self.outputRPY(deviceMotion!)
            if (NSError.self != nil){
                print("\(NSError)")
            }
            
        })
        //
        //Video config
        let vidURL = "http://\(addr):8080"
        
        videoView.allowsInlineMediaPlayback = true
        videoView.loadHTMLString("<iframe width=\"320\" height=\"320\" scrolling=\"no\" src=\"\(vidURL)?&playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if cancelGame {
            let destViewController = segue.destination as? HomeScreenVC
            
            destViewController?.cSocket = cSocket
            destViewController?.cSocketDeclared = true
        } else {
            let destViewController = segue.destination as? FinalScreenVC
            
//            destViewController?.timeMinLabel.text = timeMinLabel.text
//            destViewController?.timeSecLabel.text = timeSecLabel.text
//            destViewController?.timeMilLabel.text = timeMilLabel.text
            
            destViewController?.cSocket = cSocket
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port p: UInt16) {
        print("Connected to \(addr) on port \(port).")
        cSocket!.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let CheckPointSerial = [UInt8](data)
        print("all good")
        print(CheckPointSerial)
        
        for (key, serial) in checkPoints {
            if serial == CheckPointSerial {
                currentCheckPoint = key
            }
        }
        
        //CPsCrossed.text = String(trackArray.count - CP.track.queueList.count)
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    
    func endGame() -> Int {
        self.performSegue(withIdentifier: "toFinalVC", sender: nil)
        
        return 1
    }
    
    
}

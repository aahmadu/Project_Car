//
//  finalScreen.swift
//  iOS_P_RC
//
//  Created by Ahmed Ahmadu on 08/01/2017.
//  Copyright © 2017 Ahmed Ahmadu. All rights reserved.
//

import UIKit
import AVFoundation
import CocoaAsyncSocket

class FinalScreenVC: UIViewController, GCDAsyncSocketDelegate {
    
    var audioPlayer = AVAudioPlayer()
    
    var cSocket:GCDAsyncSocket!
    
    var tagGame: Game!
    var games = ["Time Trial", "Any Route", "Lap Count"]
    
    @IBOutlet weak var timeLabels: UIView!
    @IBOutlet weak var lapCountLabels: UIView!
    @IBOutlet weak var gameNameLabel: UILabel!
    
    @IBAction func stopMusic(_ sender: Any) {
        audioPlayer.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(string: Bundle.main.path(forResource: "SuperMario", ofType: "mp3")!)!)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print(error)
        }
        
        gameNameLabel.text = "The \(tagGame.gameName) Game"
        lapCountLabels.backgroundColor = UIColor.clear
        timeLabels.backgroundColor = UIColor.clear
        lapCountLabels.isHidden = true
        timeLabels.isHidden = true
        
        switch tagGame.gameName {
        case games[0]:
            let timeTrial = tagGame as! TimeTrialGame
            let finalTime = self.timeLabels.viewWithTag(1) as! UILabel
            finalTime.text = String(format: "%02d:%02d.%02d", timeTrial.finalTime[0], timeTrial.finalTime[1], timeTrial.finalTime[2])
            timeLabels.isHidden = false
        case games[1]:
            print("a")
            let anyRoute = tagGame as! AnyRouteGame
            let finalTime = self.timeLabels.viewWithTag(1) as! UILabel
            finalTime.text = String(format: "%02d:%02d.%02d", anyRoute.finalTime[0], anyRoute.finalTime[1], anyRoute.finalTime[2])
            timeLabels.isHidden = false
        case games[2]:
            print("b")
            let lapCount = tagGame as! LapCountGame
            let setTime = self.lapCountLabels.viewWithTag(1) as! UILabel
            let lapsDone = self.lapCountLabels.viewWithTag(2) as! UILabel
            setTime.text = String(format: "%02d:%02d", lapCount.timerTime[0], lapCount.timerTime[1])
            lapsDone.text = "\(lapCount.lapsDone)"
            lapCountLabels.isHidden = false
        default:
            print("not set")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destViewController = segue.destination as? HomeScreenVC
        
        destViewController?.cSocket = cSocket
        destViewController?.cSocketDeclared = true
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port p: UInt16) {
        cSocket!.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("packets received")
        sock.readData(withTimeout: -1, tag: 0)
    }
    
}

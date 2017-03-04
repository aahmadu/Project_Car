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
    
    var Min = ""
    var Sec = ""
    var Msec = ""
    
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
    
}

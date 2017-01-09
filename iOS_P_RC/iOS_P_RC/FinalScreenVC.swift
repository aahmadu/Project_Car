//
//  finalScreen.swift
//  iOS_P_RC
//
//  Created by Ahmed Ahmadu on 08/01/2017.
//  Copyright © 2017 Ahmed Ahmadu. All rights reserved.
//

import UIKit
import AVFoundation

class FinalScreenVC: UIViewController {
    
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var timeMinLabel: UILabel!
    @IBOutlet weak var timeSecLabel: UILabel!
    @IBOutlet weak var timeMilLabel: UILabel!
    
    var Min = ""
    var Sec = ""
    var Msec = ""
    
    @IBAction func stopMusic(_ sender: Any) {
        audioPlayer.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        timeMinLabel.text = Min
        timeSecLabel.text = Sec
        timeMilLabel.text = Msec
        // Do any additional setup after loading the view, typically from a nib.
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
    
    
}

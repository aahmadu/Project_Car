//
//  HomeScreenVC.swift
//  iOS_P_RC
//
//  Created by ahmed on 16/01/2017.
//  Copyright © 2017 Ahmed Ahmadu. All rights reserved.
//

import UIKit
import AVFoundation
import CocoaAsyncSocket


class HomeScreenVC: UIViewController, GCDAsyncSocketDelegate {
    
    let addr = "192.168.2.17"
    let port:UInt16 = 5050
    var cSocket:GCDAsyncSocket!
    
    var nextVCisFreeMode = false
    
    
    @IBAction func freeModeClicked(_ sender: Any) {
        nextVCisFreeMode = true
    }
    
    @IBOutlet weak var addrTxtField: UITextField!
    
    @IBAction func connectButton(_ sender: Any) {
        connectToCar(addr: addrTxtField.text!)
    }
    
    func connectToCar(addr: String) -> Bool {
        cSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try cSocket.connect(toHost: addr, onPort: port)
        } catch let e {
            print(e)
        }
        
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if nextVCisFreeMode {
            let destViewController = segue.destination as? FreeModeVC
            destViewController?.cSocket = cSocket
        }else{
            let destViewController = segue.destination as? GameSetupVC
            destViewController?.cSocket = cSocket
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

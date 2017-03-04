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
    
    let addr = "192.168.0.1"
    let port:UInt16 = 5050
    var cSocket:GCDAsyncSocket!
    var cSocketDeclared = false
    
    var nextVCisFreeMode = false
    
    func checkConnection() -> Bool {
        if cSocketDeclared{
            if cSocket.isConnected {
                connectionStatusLabel.text = "Connected"
                connectionStatusImage.image = #imageLiteral(resourceName: "green")
            }
            return true
        } else {
            connectionStatusLabel.text = "Not Connected"
            connectionStatusImage.image = #imageLiteral(resourceName: "red")
            
            return false
        }
    }
    
    func showNotConnected() {
        let alertController = UIAlertController(title: "Not Connected", message: "Check connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Close", style: .cancel) { _ in }
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var connectionStatusImage: UIImageView!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    
    
    @IBAction func freeModeClicked(_ sender: Any) {
        if checkConnection() {
            nextVCisFreeMode = true
            self.performSegue(withIdentifier: "SegueToFreeMode", sender: nil)
        } else {
            showNotConnected()
        }
    }
    
    @IBAction func createRaceClicked(_ sender: Any) {
        if checkConnection() {
            self.performSegue(withIdentifier: "SegueToCreateRace", sender: nil)
        } else {
            showNotConnected()
        }
    }
    
    
    @IBAction func connectButton(_ sender: Any) {
        self.cSocketDeclared = true
        if self.connectToCar(addr: addr) {
            self.connectionStatusLabel.text = "Connected"
            self.connectionStatusImage.image = #imageLiteral(resourceName: "green")
        }
    }
    
    func connectToCar(addr: String) -> Bool {
        cSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try cSocket.connect(toHost: addr, onPort: port)
        } catch let e {
            print(e)
        }
        sleep(1)
        if cSocket.isConnected {
            return true
        } else {
            return false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if !checkConnection() {
            print("connect car")
        }
        
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
    
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port p: UInt16) {
        print("Connected to \(addr) on port \(port).")
        cSocket!.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("working")
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    
}

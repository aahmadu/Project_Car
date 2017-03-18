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
    
    let addr = "192.168.0.1"    // The address of the raspberry pi on the network
    let port:UInt16 = 5050  // The port being used for controlling and receiving data from the car
    
    var cSocket:GCDAsyncSocket! // socket class
    var cSocketDeclared = false
    
    var nextVCisFreeMode = false    // used to detect if player selected free mode or create game
    
    @IBOutlet weak var connectionStatusLabel: UILabel!
    // This function checks if the car is connected to the pi and return a bool, it also changes the status at the buttom left
    // of the page
    @discardableResult func checkConnection() -> Bool {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 27,y: 341), radius: CGFloat(7.5), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.lineWidth = 3.0
        
        view.layer.addSublayer(shapeLayer)
        
        if cSocketDeclared{
            if cSocket.isConnected {
                connectionStatusLabel.text = "Connected"
                shapeLayer.fillColor = UIColor.green.cgColor
            }
            return true
        } else {
            connectionStatusLabel.text = "Not Connected"
            shapeLayer.fillColor = UIColor.red.cgColor
            
            return false
        }
    }
    
    // This function brings up a pop up alert to tell the user the car is not connected.
    func showNotConnected() {
        let alertController = UIAlertController(title: "Not Connected", message: "Check connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Close", style: .cancel) { _ in }
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    

    @IBAction func freeModeClicked(_ sender: Any) {
        if checkConnection() {
            nextVCisFreeMode = true
            self.performSegue(withIdentifier: "SegueToGame", sender: nil)
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
            checkConnection()
        }
    }
    
    // this fuction tries to connect to the server socket returns true if succesful.
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

        checkConnection()
        
    }
    
    // Data to be transfferd to next screen. Screen depending on user selection
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if nextVCisFreeMode {
            let destViewController = segue.destination as? GameViewController
            destViewController?.cSocket = cSocket
            destViewController?.isFreeMode = true
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

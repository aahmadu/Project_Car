//
//  GameSetupVC.swift
//  iOS_P_RC
//
//  Created by Ahmed Ahmadu on 07/01/2017.
//  Copyright © 2017 Ahmed Ahmadu. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class Queue<QueueType> {
    var queueList = [QueueType]()
    
    func enqueue(item: QueueType) {
        queueList.append(item)
    }
    func dequeue() -> QueueType{
        if queueList.count > 1 {
            let item = queueList[0]
            var newList = [QueueType]()
            for newItem in queueList[1...queueList.count-1] {
                newList.append(newItem)
            }
            queueList = newList
            return item
        }else if queueList.count == 1 {
            let item = queueList[0]
            queueList = [QueueType]()
            return item
        }else {
            return queueList.count as! QueueType
        }
    }
    func peek() -> QueueType{
        if queueList.count > 0 {
            return queueList[0]
        }else {
            return queueList as! QueueType
        }
    }
}

class Watch {
    
    var timer: Timer = Timer()
    var countTime = [0,0,0]
    var count = 0
    var setTime = 0
    var typeIsTimer = false
    var min: UILabel!
    var sec: UILabel!
    var mil: UILabel!
    
    init(min: UILabel, sec: UILabel, mil: UILabel) {
        self.min = min
        self.sec = sec
        self.mil = mil
    }
    
    
    func startWatch(currentVC: UIViewController, watchTypeTimer: Bool) {
        self.countTime = [0,0,0]
        self.typeIsTimer = watchTypeTimer
        print("ffrwbegbtbbdtbbhbfdgh")
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.UpdateWatch), userInfo: nil, repeats: true)
    }
    
    @objc func UpdateWatch() {
        var finalCount = 0
        
        if typeIsTimer {
            self.setTime -= count
            finalCount = setTime
        } else {
            finalCount = count
        }
        self.count += 1
        
        self.countTime[2] = finalCount % 100
        self.countTime[1] = finalCount/100
        self.countTime[0] = finalCount/6000
        
        self.mil.text = String(format: "%02d", countTime[2])
        self.sec.text = String(format: "%02d", countTime[1])
        self.min.text = String(format: "%02d", countTime[0])
    }
    
}

protocol Game {
    var gameName: String { get }
    func checkCross(checkPointLabel: String, endGame: () -> Int)
    
}

class TimeTrialGame : Game{
    internal var gameName: String = "Time Trial"
    var trackQueue = Queue<String>()
    
    internal func checkCross(checkPointLabel: String, endGame: () -> Int) {
        if checkPointLabel == self.trackQueue.peek() {
            print(self.trackQueue.dequeue())
        }
        if self.trackQueue.queueList == []{
            self.endGamef(endGame: endGame)
        }
    }
    
    func start(currentVC: UIViewController, min: UILabel, sec: UILabel, mil: UILabel) {
        var stopWatch = Watch(min: min, sec: sec, mil: mil)
        stopWatch.startWatch(currentVC: currentVC, watchTypeTimer: false)
        
    }
    
    func endGamef(endGame: () -> Int) -> [Int] {
        //get return time
        print(endGame)
        
        return [1]
    }

}







////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////  ViewController Class  /////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class GameSetupVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, GCDAsyncSocketDelegate {
    
    var cSocket:GCDAsyncSocket!
    
    var timeTrial = TimeTrialGame()
    
    var games = ["Time Trial", "Game 2", "Game 3", "Game 4"]
    var stepperVal = 0.0
    var selectedCP = "A"
    var cancel = false
    var checkPoints: [String] = ["A","B"]
    let cellReuseIdentifier = "cell"
    
    var track = Queue<String>()

    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var gameSelectTable: UITableView!
    @IBOutlet weak var CPPicker: UIPickerView!
    @IBOutlet weak var stepperOutlet: UIStepper!
    @IBOutlet weak var trackCollection: UICollectionView!
    
    @IBAction func stepper(_ sender: UIStepper) {
        if sender.value > stepperVal {
            track.enqueue(item: selectedCP)
            stepperVal = sender.value
            self.trackCollection!.reloadData()
        }else {
            track.queueList.removeLast()
            stepperVal = sender.value
            self.trackCollection!.reloadData()
        }
    }
    
    
    @IBAction func cancelSetup(_ sender: Any) {
        cancel = true
    }
    @IBAction func createButton(_ sender: Any) {
        switch titleName.text! {
        case games[0]:
            timeTrial.trackQueue = track
        default:
            print("not set")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameSelectTable.backgroundColor = UIColor.lightGray
        self.gameSelectTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        gameSelectTable.delegate = self
        gameSelectTable.dataSource = self
        
        self.CPPicker.backgroundColor = UIColor.clear
        CPPicker.delegate = self
        CPPicker.dataSource = self
        
        trackCollection.delegate = self
        trackCollection.dataSource = self
        
        hideAllUI()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if cancel {
            let destViewController = segue.destination as? HomeScreenVC
            
            destViewController?.cSocket = cSocket
            destViewController?.cSocketDeclared = true
        } else {
            let destViewController = segue.destination as? GameViewController
        
            destViewController?.timeTrail = timeTrial
            destViewController?.cSocket = cSocket
        }
    }
    
    
    func hideAllUI() {
        stepperOutlet.isHidden = true
        CPPicker.isHidden = true
        trackCollection.isHidden = true
        titleName.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.gameSelectTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        cell.textLabel?.text = self.games[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            hideAllUI()
            welcomeLabel.isHidden = true
            titleName.isHidden = false
            titleName.text = games[indexPath.row]
            stepperOutlet.isHidden = false
            CPPicker.isHidden = false
            trackCollection.isHidden = false
        case 1:
            hideAllUI()
            titleName.isHidden = false
            titleName.text = games[indexPath.row]
            welcomeLabel.isHidden = true
        case 2:
            hideAllUI()
            titleName.isHidden = false
            titleName.text = games[indexPath.row]
            welcomeLabel.isHidden = true
        case 3:
            hideAllUI()
            titleName.isHidden = false
            titleName.text = games[indexPath.row]
            welcomeLabel.isHidden = true
        default:
            print("no index in switch")
        }
    }

    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return checkPoints[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return checkPoints.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCP = checkPoints[row]
    }
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.track.queueList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as UICollectionViewCell
        
        let checkPointLetter = cell.viewWithTag(1) as! UILabel
        checkPointLetter.text = self.track.queueList[indexPath.row]
        
        let checkPointNumber = cell.viewWithTag(2) as! UILabel
        checkPointNumber.text = String(indexPath.row + 1)
        return cell
    }
    
}




















//class CheckPoint {
//    var track = Queue<String>()
//    var checkpoints: [String: [UInt8]] = [:]
//
//    func setTrack(trackArray: Array<String>, CPDict: Dictionary<String, [UInt8]>) {
//        checkpoints = CPDict
//        for point in trackArray {
//            track.enqueue(item: point)
//        }
//    }
//
//    func checkCross(checkPointLabel: String, endGame: () -> Int) {
//        if checkPointLabel == track.peek() {
//            print(track.dequeue())
//        }
//        if track.queueList == []{
//            endGame()
//        }
//
//    }
//}

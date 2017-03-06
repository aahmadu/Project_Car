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
    var timerTimeCount = 0
    var watchTypeTimer = false
    var timeLabel: UILabel!
    var currentVC: UIViewController!
    var endGameVControllerIdentifier: String!
    
    init(timeLabel: UILabel) {
        self.timeLabel = timeLabel
    }
    
    init(timeLabel: UILabel, timerTimeCount: Int, currentVC: UIViewController, endGameVControllerIdentifier: String) {
        self.timeLabel = timeLabel
        self.timerTimeCount = timerTimeCount
        self.watchTypeTimer = true
        self.currentVC = currentVC
        self.endGameVControllerIdentifier = endGameVControllerIdentifier
        
    }
    
    
    func startWatch(currentVC: UIViewController) {
        self.countTime = [0,0,0]
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.UpdateWatch), userInfo: nil, repeats: true)
    }
    
    @objc func UpdateWatch() {
        var finalCount = 0
        
        if self.watchTypeTimer {
            self.timerTimeCount -= 1
            if timerTimeCount == 0 {
                self.timer.invalidate()
                self.currentVC.performSegue(withIdentifier: self.endGameVControllerIdentifier, sender: nil)
            }
            finalCount = timerTimeCount
        } else {
            finalCount = count
            self.count += 1
        }
        
        self.countTime[2] = finalCount % 100
        self.countTime[1] = (finalCount/100)%60
        self.countTime[0] = finalCount/6000
        
        self.timeLabel.text = String(format: "%02d:%02d.%02d", countTime[0], countTime[1], countTime[2])
        
    }
    
    func endWatch() -> [Int] {
        self.timer.invalidate()
        return self.countTime
        
    }
    
}

protocol Game {
    var gameName: String { get }
    func start()
    func checkCross(currentCheckPoint: String)
    func setup(CPointsCrossedLabel: UILabel, totalCPointLabel: UILabel, currentVC: UIViewController, endGameVControllerIdentifier: String, timeLabel: UILabel, lapsDoneLabel: UILabel?)
}

class TimeTrialGame : Game{
    internal var gameName: String = "Time Trial"
    var trackQueue = Queue<String>()
    var CPointsCrossed = 0
    var totalCPoints = 0
    var currentVC = UIViewController()
    var CPointsCrossedLabel:UILabel!
    var timeLabel: UILabel!
    var endGameVControllerIdentifier = ""
    var finalTime = [0,0,0]
    var stopWatch: Watch!
    
    init(name: String) {
        self.gameName = name
    }
    
    
    internal func setup(CPointsCrossedLabel: UILabel, totalCPointLabel: UILabel, currentVC: UIViewController, endGameVControllerIdentifier: String, timeLabel: UILabel, lapsDoneLabel: UILabel?) {
        self.currentVC = currentVC
        self.CPointsCrossedLabel = CPointsCrossedLabel
        self.endGameVControllerIdentifier = endGameVControllerIdentifier
        self.timeLabel = timeLabel
        self.CPointsCrossedLabel.isHidden = false
        self.totalCPoints = trackQueue.queueList.count
        totalCPointLabel.text = String(totalCPoints)
    }
    
    func start() {
        self.stopWatch = Watch(timeLabel: self.timeLabel)
        stopWatch.startWatch(currentVC: self.currentVC)
        
    }
    
    internal func checkCross(currentCheckPoint: String) {
        if currentCheckPoint == self.trackQueue.peek() {
            print(self.trackQueue.dequeue())
            self.CPointsCrossed += 1
            CPointsCrossedLabel.text = String(self.CPointsCrossed)
        }
        if self.trackQueue.queueList == []{
            self.endGame(endGameVControllerIdentifier: endGameVControllerIdentifier)
        }
    }
    
    func endGame(endGameVControllerIdentifier: String) {
        self.finalTime = self.stopWatch.endWatch()
        self.currentVC.performSegue(withIdentifier: endGameVControllerIdentifier, sender: nil)
        
    }

}


class AnyRouteGame: TimeTrialGame {
    var gameTags = [String]()
    var firstLastTag = ["A", "A"]
    
    override func checkCross(currentCheckPoint: String) {
        if firstLastTag[0] == currentCheckPoint || gameTags.contains(firstLastTag[0]) == false {
            for (index, tags) in gameTags.enumerated() {
                if tags == currentCheckPoint {
                    gameTags.remove(at: index)
                    self.CPointsCrossed += 1
                }
            }
        }
        else if gameTags.count == 1 && firstLastTag[1] == currentCheckPoint {
            self.endGame(endGameVControllerIdentifier: endGameVControllerIdentifier)
        }
    }
}

class LapCountGame: TimeTrialGame {
    var originalTrackQueue = Queue<String>()
    var timerTime = [0,0]
    var timerTimeCount = 0
    var lapsDone = 0
    var lapsDoneLabel: UILabel!
    
    
    override func setup(CPointsCrossedLabel: UILabel, totalCPointLabel: UILabel, currentVC: UIViewController, endGameVControllerIdentifier: String, timeLabel: UILabel, lapsDoneLabel: UILabel?) {
        self.currentVC = currentVC
        self.CPointsCrossedLabel = CPointsCrossedLabel
        self.endGameVControllerIdentifier = endGameVControllerIdentifier
        self.timeLabel = timeLabel
        self.lapsDoneLabel = lapsDoneLabel
        self.timeLabel.text = String(format: "%02d:%02d.%02d", timerTime[0], timerTime[1], 0)
        self.CPointsCrossedLabel.isHidden = false
        self.timerTimeCount = (6000 * timerTime[0]) + (100 * timerTime[1])
        self.trackQueue = self.originalTrackQueue
        self.totalCPoints = trackQueue.queueList.count
        totalCPointLabel.text = String(totalCPoints)
        if let lapsDoneLabel = lapsDoneLabel {
            self.lapsDoneLabel = lapsDoneLabel
        }
    }
    
    override func checkCross(currentCheckPoint: String) {
        if currentCheckPoint == self.trackQueue.peek() {
            print(self.trackQueue.dequeue())
            self.CPointsCrossed += 1
            CPointsCrossedLabel.text = String(self.CPointsCrossed)
        }
        if self.trackQueue.queueList == []{
            self.trackQueue = self.originalTrackQueue
            self.CPointsCrossedLabel.text = String("0")
            self.lapsDone += 1
            self.lapsDoneLabel.text = String(self.lapsDone)
        }
    }
    
    override func start() {
        self.stopWatch = Watch(timeLabel: self.timeLabel, timerTimeCount: self.timerTimeCount, currentVC: self.currentVC, endGameVControllerIdentifier: self.endGameVControllerIdentifier)
        stopWatch.startWatch(currentVC: self.currentVC)
        
    }
}






////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////  ViewController Class  /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class GameSetupVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, GCDAsyncSocketDelegate {
    
    var cSocket:GCDAsyncSocket!
    
    var tagGame:Game!
    
    var timeTrial = TimeTrialGame(name: "Time Trial")
    var anyRoute  = AnyRouteGame(name: "Any Route")
    var lapCount  = LapCountGame(name: "Lap Count")
    
    
    var games = ["Time Trial", "Any Route", "Lap Count"]
    var stepperVal = 0.0
    var selectedCP = "A"
    var cancel = false
    var checkPoints: [String] = ["A","B"]
    let cellReuseIdentifier = "cell"
    
    let minutes = Array(0...60)
    let seconds = Array(0...59)
    var pickerTime = [0,0]
    
    var track = Queue<String>()

    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var gameSelectTable: UITableView!
    @IBOutlet weak var CPPicker: UIPickerView!
    @IBOutlet weak var stepperOutlet: UIStepper!
    @IBOutlet weak var trackCollection: UICollectionView!
    @IBOutlet weak var anyRouteCollection: UICollectionView!
    @IBOutlet weak var firstTagLabels: UIView!
    @IBOutlet weak var lastTagLabels: UIView!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var lapCountLabels: UIView!
    
    
    @IBAction func stepper(_ sender: UIStepper) {
        if sender.value > stepperVal {
            if track.queueList.last != selectedCP {
                track.enqueue(item: selectedCP)
                self.trackCollection!.reloadData()
            }
            stepperVal = sender.value
        }else if  track.queueList.count != 0{
            track.queueList.removeLast()
            stepperVal = sender.value
            self.trackCollection!.reloadData()
        }else{
            stepperVal = sender.value
        }
    }
    
    
    @IBAction func cancelSetup(_ sender: Any) {
        cancel = true
    }
    @IBAction func createButton(_ sender: Any) {
        switch titleName.text! {
        case games[0]:
            if track.queueList.count > 1 {
                timeTrial.trackQueue = track
                tagGame = timeTrial
                self.performSegue(withIdentifier: "createGameSegue", sender: nil)
            } else{
                print("not enough")
            }
        
        case games[1]:
            if anyRoute.gameTags.count > 1 {
                anyRoute.totalCPoints = anyRoute.gameTags.count
                tagGame = anyRoute
                self.performSegue(withIdentifier: "createGameSegue", sender: nil)
            } else{
                print("not enough")
            }
        case games[2]:
            if track.queueList.count > 1 && (pickerTime[0]>0 || pickerTime[1]>0){
                lapCount.originalTrackQueue = track
                lapCount.timerTime = pickerTime
                tagGame = lapCount
                self.performSegue(withIdentifier: "createGameSegue", sender: nil)
            } else{
                print("not enough")
            }
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
        self.timePicker.backgroundColor = UIColor.clear
        
        timePicker.delegate = self
        timePicker.dataSource = self
        
        CPPicker.delegate = self
        CPPicker.dataSource = self
        
        trackCollection.delegate = self
        trackCollection.dataSource = self
        
        anyRouteCollection.delegate = self
        anyRouteCollection.dataSource = self
        
        
        self.view.addSubview(trackCollection)
        self.view.addSubview(anyRouteCollection)
        
        self.view.addSubview(CPPicker)
        self.view.addSubview(timePicker)
        
        hideAllUI()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if cancel {
            let destViewController = segue.destination as? HomeScreenVC
            
            destViewController?.cSocket = cSocket
            destViewController?.cSocketDeclared = true
        } else {
            let destViewController = segue.destination as? GameViewController
        
            //destViewController?.timeTrail = timeTrial
            destViewController?.tagGame = tagGame
            destViewController?.cSocket = cSocket
        }
    }
    
    
    func hideAllUI() {
        stepperOutlet.isHidden = true
        CPPicker.isHidden = true
        trackCollection.isHidden = true
        titleName.isHidden = true
        anyRouteCollection.isHidden = true
        firstTagLabels.isHidden = true
        lastTagLabels.isHidden = true
        timePicker.isHidden = true
        lapCountLabels.isHidden = true
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
            CPPicker.frame.origin.x = 243
            CPPicker.frame.origin.y = 139
            trackCollection.isHidden = false
        case 1:
            hideAllUI()
            titleName.isHidden = false
            titleName.text = games[indexPath.row]
            anyRouteCollection.isHidden = false
            firstTagLabels.isHidden = false
            lastTagLabels.isHidden = false
            welcomeLabel.isHidden = true
        case 2:
            hideAllUI()
            titleName.isHidden = false
            titleName.text = games[indexPath.row]
            welcomeLabel.isHidden = true
            timePicker.isHidden = false
            lapCountLabels.isHidden = false
            CPPicker.isHidden = false
            CPPicker.frame.origin.x = 110
            CPPicker.frame.origin.y = 0
            trackCollection.isHidden = false
            stepperOutlet.isHidden = false
            stepperOutlet.frame.origin.x = 296
            stepperOutlet.frame.origin.y = 94
        default:
            print("no index in switch")
        }
    }

    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.CPPicker {
            return checkPoints[row]
        }else {
            if component == 0 {
                return String(minutes[row])
            } else {
                
                return String(seconds[row])
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.CPPicker {
            return checkPoints.count
        }else {
            //var row = pickerView.selectedRow(inComponent: 0)
            
            if component == 0 {
                return minutes.count
            }
                
            else {
                return seconds.count
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == self.CPPicker {
            return 1
        }else {
            return 2
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.CPPicker {
            selectedCP = checkPoints[row]
        }else {
            if component == 0 {
                pickerTime[0] = row
            }
                
            else {
                pickerTime[1] = row
            }
        }
    }
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.trackCollection {
            return self.track.queueList.count
        }else {
            return checkPoints.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.trackCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeTrialCollectionViewCell", for: indexPath) as UICollectionViewCell
            
            let checkPointLetter = cell.viewWithTag(1) as! UILabel
            checkPointLetter.text = self.track.queueList[indexPath.row]
            
            let checkPointNumber = cell.viewWithTag(2) as! UILabel
            checkPointNumber.text = String(indexPath.row + 1)
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.gray.cgColor
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "anyRouteCollectionViewCell", for: indexPath) as UICollectionViewCell
            
            let checkPointLetter = cell.viewWithTag(1) as! UILabel
            checkPointLetter.text = self.checkPoints[indexPath.row]
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.gray.cgColor
            
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstTag = self.firstTagLabels.viewWithTag(1) as! UILabel
        let lastTag = self.lastTagLabels.viewWithTag(1) as! UILabel
        if collectionView == self.anyRouteCollection {
            if self.anyRoute.gameTags.contains(self.checkPoints[indexPath.row]) {
                if self.anyRoute.gameTags.count == 1 {
                    let cell = collectionView.cellForItem(at: indexPath)
                    cell?.layer.borderWidth = 1
                    cell?.layer.borderColor = UIColor.gray.cgColor
                    for (index, tags) in self.anyRoute.gameTags.enumerated() {
                        if tags == self.checkPoints[indexPath.row] {
                            self.anyRoute.gameTags.remove(at: index)
                        }
                    }
                    firstTag.text = "-"
                    lastTag.text = "-"
                }
                else if self.checkPoints[indexPath.row] != firstTag.text{
                    let cell = collectionView.cellForItem(at: indexPath)
                    cell?.layer.borderWidth = 1
                    cell?.layer.borderColor = UIColor.gray.cgColor
                    for (index, tags) in self.anyRoute.gameTags.enumerated() {
                        if tags == self.checkPoints[indexPath.row] {
                            self.anyRoute.gameTags.remove(at: index)
                        }
                    }
                    
                    lastTag.text = self.anyRoute.gameTags.last
                }
            }else{
                if self.anyRoute.gameTags.isEmpty {
                    let cell = collectionView.cellForItem(at: indexPath)
                    cell?.layer.borderWidth = 2
                    cell?.layer.borderColor = UIColor.blue.cgColor
                    self.anyRoute.gameTags.append(self.checkPoints[indexPath.row])
                    
                    firstTag.text = self.checkPoints[indexPath.row]
                }else{
                    let cell = collectionView.cellForItem(at: indexPath)
                    cell?.layer.borderWidth = 2
                    cell?.layer.borderColor = UIColor.blue.cgColor
                    self.anyRoute.gameTags.append(self.checkPoints[indexPath.row])
                    lastTag.text = self.checkPoints[indexPath.row]
                }
                
            }
        }
        anyRoute.firstLastTag[0] = firstTag.text!
        anyRoute.firstLastTag[1] = lastTag.text!
    }
    
    
}

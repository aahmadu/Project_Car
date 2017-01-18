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

class GameSetupVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, GCDAsyncSocketDelegate {
    
    var stepperVal = 0.0
    var selectedCP = "A"
    
    var cSocket:GCDAsyncSocket!
    
    var cancel = false
    
    @IBAction func stepper(_ sender: UIStepper) {
        if sender.value > stepperVal {
            trackArray.append(selectedCP)
            stepperVal = sender.value
            self.tableView.reloadData()
        }else {
            trackArray.removeLast()
            stepperVal = sender.value
            self.tableView.reloadData()
        }
    }
    

    @IBAction func createGame(_ sender: Any) {
        
    }
    
    @IBOutlet weak var CPPicker: UIPickerView!
    
    var trackArray = [String]()
    var checkPoints: [String] = ["A","B"]
    let cellReuseIdentifier = "cell"
    @IBOutlet var tableView: UITableView!
    
    
    @IBAction func cancelSetup(_ sender: Any) {
        cancel = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        CPPicker.delegate = self
        CPPicker.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if cancel {
            let destViewController = segue.destination as? HomeScreenVC
            
            destViewController?.cSocket = cSocket
        } else {
            let destViewController = segue.destination as? GameViewController
        
            destViewController?.trackArray = trackArray
            destViewController?.cSocket = cSocket
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trackArray.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.trackArray[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
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
    
}

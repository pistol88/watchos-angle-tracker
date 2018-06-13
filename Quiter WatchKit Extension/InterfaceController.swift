///Users/pistol/Desktop/xcode/Quiter/Quiter/ViewController.swift
//  InterfaceController.swift
//  MonkeySmokeQuit WatchKit ExtensionMonkeySmokeQuit WatchKit ExtensionMonkeySmokeQuit WatchKit Extension
//
//  Created by Илья Егоров on 01/06/2018.
//  Copyright © 2018 Илья Егоров. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import CoreLocation
import Alamofire
import HealthKit
import UIKit
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var test: WKInterfaceLabel!
    @IBOutlet var serverData: WKInterfaceLabel!
    fileprivate var motion: CMMotionManager
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    fileprivate var hapticFeedbackTimer: Timer?
    var timer = Timer()
    var smoking = false
    var activated = false
    var session : WCSession!;
    var increment = 1
    var angles = ["1"]
    
    @IBAction func switchSmoke(_ value: Bool) {
        smoking = value;
    }
    //private let locationManager: CLLocationManager = CLLocationManager()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    @IBOutlet var WatchLabel: WKInterfaceLabel!
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //self.label.setText(message["a"]! as? String)
        
        let msg = message["a"] as? String;
        WatchLabel.setText(msg);
        sendMessage();
    }
    
    func sendMessage(){
        session.sendMessage(["b":"hi"], replyHandler: nil, errorHandler: nil);
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override fileprivate init() {
        motion = CMMotionManager()
        //locationManager.allowsBackgroundLocationUpdates = true
        //locationManager.stopUpdatingLocation()
    }
    
    override func willActivate() {
        if(WCSession.isSupported()){
            self.session = WCSession.default;
            self.session.delegate = self;
            self.session.activate();
        }
        //locationManager.startUpdatingLocation()
        if(!activated) {
            sendData()
            startAnglesTracker()
            runTimer()
            activated = false
        }
        
        super.willActivate()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        sendData()
    }
    
    func startAnglesTracker() {
        if motion.isAccelerometerAvailable && !motion.isAccelerometerActive {
            motion.accelerometerUpdateInterval = 10
            motion.startAccelerometerUpdates(to: OperationQueue.main) {
                (data, error) in
                
                let x = String(format: "%.3f", data!.acceleration.x);
                let y = String(format: "%.3f", data!.acceleration.y);
                let z = String(format: "%.3f", data!.acceleration.z);
                
                let parameters: Parameters = [
                    "device":  WKInterfaceDevice.current().name,
                    "smoking": self.smoking,
                    "action": "pull",
                    "accelerometer": [
                        "x": x,
                        "y": y,
                        "z": z
                    ]
                ]
                self.angles.append(x)
                self.session.sendMessage(["b": String(self.angles.count)], replyHandler: nil, errorHandler: nil);
                self.increment = self.increment+1;
                Alamofire.request("https://coinmonkey.io/bracelet.php", method: .post, parameters: parameters).response { response in
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        self.test.setText(utf8Text)
                        //self.session.sendMessage(["b":utf8Text], replyHandler: nil, errorHandler: nil);
                    }
                }
            }
        }
    }
    
    func sendData() {
        print("send-data")
        let parameters: Parameters = [
            "device": WKInterfaceDevice.current().name,
            "action": "activated",
        ]
        session.sendMessage(["b": String(angles.count)], replyHandler: nil, errorHandler: nil);
        increment = self.increment+1;
        Alamofire.request("https://coinmonkey.io/bracelet.php", method: .post, parameters: parameters).response { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                self.test.setText(utf8Text)
                //self.session.sendMessage(["b":utf8Text], replyHandler: nil, errorHandler: nil);
            }
        }
    }
}

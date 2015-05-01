//
//  ViewController.swift
//  FlyNotify
//
//  Created by Matthew Kuzyk on 4/1/15.
//  Copyright (c) 2015 Matthew Kuzyk. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager:CBCentralManager!
    var peripheral:CBPeripheral!
    var blueToothReady = false

    override func viewDidLoad() {
        super.viewDidLoad()
        startUpCentralManager()    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startUpCentralManager() {
        println("Initializing central manager")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func discoverDevices() {
        println("discovering devices")
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("Discovered \(peripheral.name)")
        self.centralManager.stopScan()
        self.peripheral = peripheral
        peripheral.delegate = self
        self.centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
//        peripheral.setDelegate(self)
        peripheral.discoverServices(nil)
        
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("checking state")
        switch (central.state) {
        case .PoweredOff:
            println("CoreBluetooth BLE hardware is powered off")
            
        case .PoweredOn:
            println("CoreBluetooth BLE hardware is powered on and ready")
            blueToothReady = true;
            
        case .Resetting:
            println("CoreBluetooth BLE hardware is resetting")
            
        case .Unauthorized:
            println("CoreBluetooth BLE state is unauthorized")
            
        case .Unknown:
            println("CoreBluetooth BLE state is unknown");
            
        case .Unsupported:
            println("CoreBluetooth BLE hardware is unsupported on this platform");
            
        }
        if blueToothReady {
            discoverDevices()
        }
    }
    
    // Invoked when you discover a service.
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service in peripheral.services {
            NSLog("Discovered service: %@", service.UUIDString)
            peripheral.discoverCharacteristics(nil, forService: service as! CBService)
        }
    }
    
    // Invoked when you discover the characteristics of a specified service.
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        for characteristic in service.characteristics {
            self.peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        scheduleNotification()
    }
    
    func scheduleNotification() {
        var notification:UILocalNotification = UILocalNotification()
        notification.category = "CATEGORY"
        notification.alertBody = "Your fly is down!"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    
}


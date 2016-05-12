//
//  ViewController.swift
//  photonA
//
//  Created by Ishan Shah on 11/8/15.
//  Copyright © 2015 Ishan Shah. All rights reserved.
//

import UIKit
import Spark_SDK
//import SparkSetup

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    var myPhoton : SparkDevice?
    var deviceOK = false
    var logInOK = false
    var devicesName:[String] = []
    var selectedDeviceName = ""
    var logInDoneOnce = false
    var modePicker: UIPickerView!     //
    var devicePicker:UIPickerView!   //
    var selectedMode = "" ;
    var repeatTimer = NSTimer()
    
    
    
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet var UserName: UITextField!
    
    @IBOutlet var unitTemperature: UILabel!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var sliderPower: UISlider! {
        didSet{
            sliderPower.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        }
    }
    
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var sliderLabel: UILabel!
    
    @IBOutlet var backgroundImage: UIImageView!
    
    @IBAction func sliderPowerChanged(sender: UISlider) {
        
        let currentValue = Int(sender.value)
        
        sliderLabel.text = "\(currentValue)"
        
    }
    
    
    @IBOutlet var modePickerView: UIPickerView!
    
    
    
    var modePickerViewDataSource = ["Power","TempC","TempF"];
    
    @IBAction func logOut(sender: AnyObject) {  // log out action button
        
        SparkCloud.sharedInstance().logout()
        self.errorLabel.text = "Logged Out "
        
        
    }
    
    
    

    @IBAction func logIn(sender: AnyObject) {       // login action button
    
        
        
    
        
        SparkCloud.sharedInstance().loginWithUser(UserName.text!, password: password.text!) { (error:NSError!) -> Void in
            if error != nil {
                print("Wrong credentials or no internet connectivity, please try again")
                self.errorLabel.text = "Incorrect Username and Password"
            }
            else {
                print("Logged in")
                self.logInOK = true
                self.errorLabel.text = "Logged In "
            }
        }
    
        
        
        // 1
        if logInDoneOnce == false{
        if logInOK {
            SparkCloud.sharedInstance().getDevices { (sparkDevicesList : [AnyObject]!, error :NSError!) -> Void in
                // 2
                if let sparkDevices = sparkDevicesList as? [SparkDevice]
                {
                    print(sparkDevices)
                    // 3
                    for device in sparkDevices
                    {
                        self.devicesName.append(device.name)
                        
                        self.pickerView.reloadAllComponents()
                        self.logInDoneOnce = true;
                        
                        //  if device.name == "ARKA"
                       
                    }
                }
            }
        }
        
        }
    }           // end of log in action button
    
    
    
    
    @IBAction func startDeviceSetup(sender: AnyObject) {    // action for Turn Off button // TURN OFF
        // 1
        SparkCloud.sharedInstance().getDevices { (sparkDevicesList : [AnyObject]!, error :NSError!) -> Void in
            // 2
            if let sparkDevices = sparkDevicesList as? [SparkDevice]
            {
                print(sparkDevices)
                // 3
                for device in sparkDevices
                {
                   // if device.name == "ARKA"
                        
                   // if device.name == "ISHAN"
                    if device.name == self.selectedDeviceName
                    {
                        // 4
                        device.callFunction("digitalwrite", withArguments: ["D7","LOW"], completion: { (resultCode :NSNumber!, error : NSError!) -> Void in
                            // 5
                            print("Called a function on myDevice")
                            
                        })
                    }
                }
            }
        }
       
        
       if let setupController = SparkSetupMainController(setupOnly: true)
       {
      //  setupController.delegate = self;
      //  setupController.delegate = self
        self.presentViewController(setupController, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    @IBAction func readVariableButtonTapped(sender: AnyObject) {        // TURN ON
       
        
        // 1
        if logInOK {
        SparkCloud.sharedInstance().getDevices { (sparkDevicesList : [AnyObject]!, error :NSError!) -> Void in
            // 2
            if let sparkDevices = sparkDevicesList as? [SparkDevice]
            {
                print(sparkDevices)
                // 3
                for device in sparkDevices
                {
        //          self.devicesName.append(device.name)
                    
        //            self.pickerView.reloadAllComponents()
                    
                    //  if device.name == "ARKA"
                    //    if device.name == "ISHAN"
                    if device.name == self.selectedDeviceName
                    {
                        // 4
                        
                        self.myPhoton = device
                        
                        
                        
                        self.myPhoton!.callFunction("digitalwrite", withArguments: ["D7","HIGH"], completion: { (resultCode :NSNumber!, error : NSError!) -> Void in
                         // digitalwrite is the name of the spark cloud function called 
                            // this function should be a cloud function and should be in the photon io code
                            // tinker app code is loaded in the module right now.
                            
                            
                            // 5
                            print("Called a function on myDevice")
                            print(sparkDevices)
                            print(self.devicesName)
                            self.deviceOK = true
                        })
                    }
                }
            }
        }
        }
        
        
        // comment whole deviceOK Block
        // Block to read temperature
        if deviceOK {
        myPhoton!.getVariable("analogvalue", completion: { (result:AnyObject!, error:NSError!) -> Void in
            if error != nil {
                print("Failed reading temperature from device")
            }
            else {
                if let temp = result as? Float {
                    print("Room temperature is \(temp) degrees")
                    
                    // display the temperature on the screen of the device
                    self.unitTemperature.text = String(temp);
                    
                    
                    
                }
            }
        })
        
        
            let myDeviceVariables : Dictionary? = myPhoton!.variables as? Dictionary<String,String>
            print("MyDevice first Variable is called \(myDeviceVariables!.keys.first) and is from type \(myDeviceVariables?.values.first)")
            
            let myDeviceFunction = myPhoton!.functions
            print("MyDevice first function is called \(myDeviceFunction!.first)")
            
            
            
        
        
        }  // end of deviceOK // end of block to read and print temperature
 
 
        
        
        
        
        /*
        let myDeviceVariables : Dictionary? = myPhoton.variables as? Dictionary<String,String>
        print("MyDevice first Variable is called \(myDeviceVariables!.keys.first) and is from type \(myDeviceVariables?.values.first)")
        
        let myDeviceFunction = myPhoton.functions
        print("MyDevice first function is called \(myDeviceFunction!.first)")
        */
        
        
        
        /*
        
        myPhoton!.getVariable("temperature", completion: { (result:AnyObject!, error:NSError!) -> Void in
            if let e=error {
                print("Failed reading temperature from device")
            }
            else {
                if let temp = result as? Float {
                    print("Room temperature is \(temp) degrees")
                }
            }
        })

*/
        
        
        
        
    }   // end of readVariableButtonTapped
    
    
    
    override func viewWillAppear(animated: Bool) {
        let progressHUD = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        progressHUD.showInView(view, animated: true)
        progressHUD.dismissAfterDelay(3.0)
    }
    
    
    
    var pickerDataSource = ["White","Red","Green","Blue"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        self.modePickerView.dataSource = self;
        self.modePickerView.delegate = self;
        
        repeatTimer = NSTimer.scheduledTimerWithTimeInterval(0.5,target:self, selector: #selector(ViewController.runTimedCode) , userInfo:nil, repeats: true)
        
    }
    
    
    func runTimedCode(){        // referesh background
        if (selectedMode == "Power"){
         //   self.view.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 255/255.0, alpha: 255);
         //   self.view.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 255/255.0, alpha: 255);
        }
        else if (selectedMode == "TempC"){
         //   self.view.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 255);
        }
        else if (selectedMode == "TempF"){
         //   self.view.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0);
        }
        else{
       //     self.view.backgroundColor = UIColor(red: 0.4, green: 1.0, blue: 0.2, alpha: 0.9);
       //     let red = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
       //     self.view.backgroundColor = UIColor(CGColor: red.CGColor)//UIColor(white: 1, alpha: 0.1);
       //     self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        }
        
        
    }
    
    // implementing the picker view controller function 
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return pickerDataSource.count;
        if (pickerView == modePickerView) {
            return modePickerViewDataSource.count;
        }
        else {
            return devicesName.count;
        }
        
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return pickerDataSource[row]
        
        if (pickerView == modePickerView) {
            return modePickerViewDataSource[row]
        }
        else {
        return devicesName[row]
        }
    }
    
    
 
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerView == modePickerView){
            selectedMode = modePickerViewDataSource[row]
            print(selectedMode)
        }
        else {
        selectedDeviceName = devicesName[row]
        
        print(selectedDeviceName)
        }
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        pickerView.reloadAllComponents()
    }
    
    
    

} // end of UIViewController


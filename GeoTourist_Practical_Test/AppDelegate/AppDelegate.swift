//
//  AppDelegate.swift
//  GeoTourist_Practical_Test
//
//  Created by Nirzar Gandhi on 18/08/21.
//

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: - Variable Declaration
    var window: UIWindow?
    var navhomeViewController : UINavigationController?
    let notificationDelegate = NotificationDelegate()
    var backgroundUpdateTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    
    //MARK: - AppDelegate Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if !isKeyPresentInUserDefaults(key: UserDefault.kIsKeyChain) {
            userDefaultKeyChainDataClear()
        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        GeoFenceManager.sharedInstance.checkLocationPermision()
                
        GeoFenceManager.sharedInstance.delegateBackgroundTask = self
        
        Utility().copyFile(fileName: "Tour.sqlite")
        
        Utility().setRootTabbarVC()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        UIPasteboard.general.items = [[String: Any]()]
        
        backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    //MARK: - Do Background Task Method
    func doBackgroundTask() {

        DispatchQueue.global(qos: .userInitiated).async {
            self.beginBackgroundUpdateTask()

            GeoFenceManager.sharedInstance.getUserLocation()

            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(AppDelegate.bgtimer(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
            RunLoop.current.run()

            self.endBackgroundUpdateTask()
        }
    }

    //MARK: - Begin & End BackgroundUpdateTask Methods
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }

    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    }
    
    //MARK: - Background Timer Method
    @objc func bgtimer(_ timer:Timer!){
        updateLocation()
        
        callUpdateGeoLocation()
    }

    //MARK: - Update Location Method
    func updateLocation() {
        objLocationManager.startUpdatingLocation()
        objLocationManager.stopUpdatingLocation()
    }
    
    //MARK: - Call UpdateLocation Method
    func callUpdateGeoLocation() {
        mainThread {
            UIApplication.topViewController()?.view.makeToast("User current location is Latitude : \(objCurrentLocation.latitude) & Longitude : \(objCurrentLocation.longitude)")
        }

        let strDate = Utility().datetimeFormatter(strFormat: DateAndTimeFormatString.strDateFormate_ddMMMyyyyhhmmss, isTimeZoneUTC: false).string(from: Date())

        writeToDocumentsFile(strFileName: "Location Update.txt", strCurrentLocation: "Latitude : \(objCurrentLocation.latitude) & Longitude : \(objCurrentLocation.longitude) & Date - Time : \(strDate)\n\n")
    }
}

//MARK: - GeoFenceManagerDelegate Extension
extension AppDelegate : BackgroundTaskDelegate {

    func startBackgroundTask() {
        
        doBackgroundTask()
        
        GeoFenceManager.sharedInstance.delegateBackgroundTask = nil
    }
}

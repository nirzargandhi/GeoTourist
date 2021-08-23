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
        
        timerUpdateGeoLocation()
        
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
        timerUpdateGeoLocation()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        endBackgroundUpdateTask()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    //MARK: - End Background Update Task Method
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    }
    
    //MARK: - Scheduled Timer With TimeInterval Method
    func timerUpdateGeoLocation() {
        timer = Timer.scheduledTimer(timeInterval: 900, target: self, selector: #selector(self.callUpdateGeoLocation), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
    }
    
    //MARK: - Call UpdateLocation Method
    @objc func callUpdateGeoLocation() {
        UIApplication.topViewController()?.view.makeToast("User current location is Latitude : \(objCurrentLocation.latitude) & Longitude : \(objCurrentLocation.longitude)")
        
        let strDate = Utility().datetimeFormatter(strFormat: DateAndTimeFormatString.strDateFormate_ddMMMyyyyhhmmss, isTimeZoneUTC: false).string(from: Date())
        
        writeToDocumentsFile(strFileName: "Location Update.txt", strCurrentLocation: "Latitude : \(objCurrentLocation.latitude) & Longitude : \(objCurrentLocation.longitude) & Date - Time : \(strDate)\n\n")
    }
}

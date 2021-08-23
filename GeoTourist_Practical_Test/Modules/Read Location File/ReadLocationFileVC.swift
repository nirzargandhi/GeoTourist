//
//  ReadLocationFileVC.swift
//  GeoTourist_Practical_Test
//
//  Created by Nirzar Gandhi on 19/08/21.
//

class ReadLocationFileVC: UIViewController {
    
    //MARK: - UITextView Outlet
    @IBOutlet weak var tvLocationData: UITextView!
    
    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        initialization()
        
        getLocationUpdateFileData()
    }
    
    //MARK: - Initialization Method
    func initialization() {
        
        setNavigationHeader(strTitleName: "Read Location File")
    }
    
    //MARK: - Get Location Update File Data Method
    func getLocationUpdateFileData() {
        
        let strLocationUpdate = readFromDocumentsFile(strFileName: "Location Update.txt")
        
        tvLocationData.text = strLocationUpdate
    }
}

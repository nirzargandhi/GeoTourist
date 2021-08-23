//
//  LocationUpdateVC.swift
//  GeoTourist_Practical_Test
//
//  Created by Nirzar Gandhi on 19/08/21.
//

class LocationUpdateVC: UIViewController {

    //MARK: - UILabel Outlet
    @IBOutlet weak var lblNoData: UILabel!
    
    //MARK: - UITableView Outlet
    @IBOutlet weak var tblLocationUpdate: UITableView!
    
    //MARK: - Variable Declaration
    var arrLocationUpdate : [String]?
    
    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        initialization()
        
        getLocationUpdateData()
    }
    
    //MARK: - Initialization Method
    func initialization() {
        
        setNavigationHeader(strTitleName: "Location Update")
        
        tblLocationUpdate.rowHeight = UITableView.automaticDimension
        tblLocationUpdate.estimatedRowHeight = UITableView.automaticDimension
        tblLocationUpdate.tableFooterView = UIView()
    }
    
    //MARK: - Get Location Update Data Method
    func getLocationUpdateData() {
        
        let strLocationUpdate = readFromDocumentsFile(strFileName: "Location Update.txt")
        
        arrLocationUpdate = strLocationUpdate.components(separatedBy: .newlines)
        
        arrLocationUpdate?.removeAll("")
        
        if arrLocationUpdate?.count ?? 0 > 0 {
            tblLocationUpdate.reloadData()
            
            tblLocationUpdate.isHidden = false
            lblNoData.isHidden = true
        } else {
            lblNoData.isHidden = false
            tblLocationUpdate.isHidden = true
        }
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource Extension
extension LocationUpdateVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLocationUpdate?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.kCellLocationUpdate, for: indexPath) as! LocationUpdateTVC
        
        let arrTemp = (arrLocationUpdate?[indexPath.row] ?? "").components(separatedBy: "&")
        
        if arrTemp.count > 0 {
            cell.lblLat.text = arrTemp[0].trimmingCharacters(in: .whitespaces)
        } else {
            cell.lblLat.text = "Latitude : "
        }
        
        if arrTemp.count > 1 {
            cell.lblLong.text = arrTemp[1].trimmingCharacters(in: .whitespaces)
        } else {
            cell.lblLong.text = "Longitude : "
        }
        
        if arrTemp.count > 2 {
            cell.lblDateTime.text = arrTemp[2].trimmingCharacters(in: .whitespaces)
        } else {
            cell.lblDateTime.text = "Date - Time : "
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

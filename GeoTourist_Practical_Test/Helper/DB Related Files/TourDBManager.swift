//
//  TourDBManager.swift
//  GeoTourist_Practical_Test
//
//  Created by Nirzar Gandhi on 19/08/21.
//

let sharedInstance = TourDBManager()

class TourDBManager: NSObject {
    
    var database: FMDatabase? = nil
    
    class func getInstance() -> TourDBManager {
        if(sharedInstance.database == nil) {
            print("Database Path : \(Utility().getPath(fileName: "Tour.sqlite"))")
            sharedInstance.database = FMDatabase(path: Utility().getPath(fileName: "Tour.sqlite"))
        }
        return sharedInstance
    }
    
    func addTourData(objTourModal: TourModal) -> Bool {
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO tblTourList (tour_name, video_name, video, lat, long) VALUES (?, ?, ?, ?, ?)", withArgumentsIn: [objTourModal.tour_name as Any, objTourModal.video_name as Any, objTourModal.video as Any, objTourModal.lat as Any, objTourModal.long as Any])
        
        if !isInserted {
            print(sharedInstance.database?.lastErrorMessage() as Any)
        }
        
        sharedInstance.database!.close()
        return isInserted
    }
    
    func updateTourData(objTourModal: TourModal) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE tblTourList SET tour_name=?, video_name=?, video=?, lat=?, long=? WHERE id=?", withArgumentsIn: [objTourModal.tour_name as Any, objTourModal.video_name as Any, objTourModal.video as Any, objTourModal.id as Any, objTourModal.lat as Any, objTourModal.long as Any])
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteTourData(objTourModal: TourModal) -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM tblTourList WHERE id=?", withArgumentsIn: [objTourModal.id as Any])
        sharedInstance.database!.close()
        return isDeleted
    }
    
    func getAllTourData() -> [TourModal] {
        
        sharedInstance.database!.open()
        
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM tblTourList", withArgumentsIn:[])
        
        var arrTourModal : [TourModal] = [TourModal]()
        
        if (resultSet != nil) {
            
            while resultSet.next() {
                
                let objTourModal : TourModal = TourModal()
                
                if resultSet.string(forColumn: "tour_name") != nil {
                    objTourModal.tour_name = resultSet.string(forColumn: "tour_name")!
                }
                
                if resultSet.string(forColumn: "video_name") != nil {
                    objTourModal.video_name = resultSet.string(forColumn: "video_name")!
                }
                
                if resultSet.data(forColumn: "video") != nil {
                    objTourModal.video = resultSet.data(forColumn: "video")!
                }
                
                objTourModal.lat = resultSet.double(forColumn: "lat")
                
                objTourModal.long = resultSet.double(forColumn: "long")
                
                arrTourModal.append(objTourModal)
            }
        }
        
        sharedInstance.database!.close()
        
        return arrTourModal
    }
}



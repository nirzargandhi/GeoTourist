//
//  LocationUpdateTVC.swift
//  GeoTourist_Practical_Test
//
//  Created by Nirzar Gandhi on 19/08/21.
//

class LocationUpdateTVC: UITableViewCell {
    
    //MARK: - UILabel Outlets
    @IBOutlet weak var lblLat: UILabel!
    @IBOutlet weak var lblLong: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    
    //MARK: - Cell Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

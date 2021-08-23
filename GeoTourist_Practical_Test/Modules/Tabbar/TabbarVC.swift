//
//  TabbarVC.swift
//  GeoTourist_Practical_Test
//
//  Created by Nirzar Gandhi on 19/08/21.
//

class TabbarVC: UITabBarController {
    
    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialization()
    }
    
    //MARK: - Initialization Method
    func initialization() {
                
        hideNavigationBar()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14)!], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 14)!], for: .normal)
        
        tabBar.tintColor = .white
        tabBar.barTintColor = .appBlack()
        tabBar.isTranslucent = false
    }
}




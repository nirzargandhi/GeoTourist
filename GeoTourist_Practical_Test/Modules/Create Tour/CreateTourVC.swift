//
//  CreateTourVC.swift
//  GeoTourist_Practical_Test
//
//  Created by Nirzar Gandhi on 19/08/21.
//

class CreateTourVC: UIViewController {
    
    //MARK: - MKMapView Outlet
    @IBOutlet weak var vMap: MKMapView!
    
    //MARK: - MKMapView Outlet
    @IBOutlet weak var txtTourname: UITextField!
    
    //MARK: - MKMapView Outlet
    @IBOutlet weak var lblVideoName: UILabel!
    
    //MARK: - MKMapView Outlet
    @IBOutlet weak var vPopUp: UIView!
    @IBOutlet weak var vSubPopUp: UIView!
    
    //MARK: - MKMapView Outlet
    @IBOutlet weak var btnCaptureVideo: UIButton!
    @IBOutlet weak var btnRemoveVideo: UIButton!
    
    //MARK: - Variable Declaration
    var arrTourModal = [TourModal]()
    var objMapTapLocationCoordinate = CLLocationCoordinate2D()
    var dataVideo : Data?

    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeoFenceManager.sharedInstance.delegateGeoFence = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchTour()
    }
    
    override func viewDidLayoutSubviews() {
        vSubPopUp.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
    }
    
    //MARK: - Initialization Method
    func initialization() {
        
        showNavigationBar()
        
        setNavigationHeader(strTitleName: "Create Tour")
        
        vPopUp.backgroundColor = UIColor.appBlack().withAlphaComponent(0.75)
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(handleTap))
        gestureRecognizer.delegate = self
        vMap.addGestureRecognizer(gestureRecognizer)
    }
    
    //MARK: - Fetch Tour Method
    func fetchTour() {
        
        removeAllAnnotations()
        
        arrTourModal = TourDBManager.getInstance().getAllTourData()
        
        loadMap()
        
        displayMarker()
    }
    
    //MARK: - Remove All Annotations Method
    func removeAllAnnotations() {
        let annotations = vMap.annotations.filter {
            $0 !== self.vMap.userLocation
        }
        vMap.removeAnnotations(annotations)
    }
    
    //MARK: - Load Map Method
    func loadMap() {
        
        var objUserLocation = CLLocationCoordinate2D()
        
        if objCurrentLocation.latitude == 0.0 || objCurrentLocation.longitude == 0.0 {
            objUserLocation = CLLocationCoordinate2D(latitude: 55.76412, longitude: -4.17669)
        } else {
            objUserLocation = CLLocationCoordinate2D(latitude: objCurrentLocation.latitude, longitude: objCurrentLocation.longitude)
        }
        
        vMap.delegate = self
        vMap.mapType = .standard
        vMap.isZoomEnabled = true
        vMap.isScrollEnabled = true
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = objUserLocation
        annotation.title = "Your here"
        vMap.addAnnotation(annotation)
    }
    
    //MARK: - Dsiplay Marker Method
    func displayMarker() {
        
        for i in 0..<arrTourModal.count {
            
            let destinationLatitude = CLLocationDegrees(arrTourModal[i].lat ?? 0.0)
            let destinationLongitude = CLLocationDegrees(arrTourModal[i].long ?? 0.0)
            
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2DMake(destinationLatitude, destinationLongitude)
            annotation.coordinate = centerCoordinate
            annotation.title = arrTourModal[i].tour_name ?? ""
            
            vMap.addAnnotation(annotation)
        }
        
        vMap.delegate = self
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func btnCaptureVideoAction(_ sender: Any) {
        
        hideIQKeyboard()
        
        takeAndChooseVideo()
    }
    
    @IBAction func btnRemoveVideoAction(_ sender: Any) {
        
        hideIQKeyboard()
        
        let alert = UIAlertController(title: "Delete", message: AlertMessage.msgGeneralDelete, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
            self.lblVideoName.isHidden = true
            
            self.btnRemoveVideo.isHidden = true
            
            self.dataVideo = nil
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnCancelTourAction(_ sender: Any) {
        
        hideIQKeyboard()
        
        hidePopUp()
    }
    
    @IBAction func btnSaveTourAction(_ sender: Any) {
        
        hideIQKeyboard()
        
        if txtTourname.isEmpty {
            self.view.makeToast(AlertMessage.msgTourname)
        } else {
            let objTourModal : TourModal = TourModal()
            objTourModal.tour_name = txtTourname.text ?? ""
            objTourModal.video_name = lblVideoName.text ?? ""
            objTourModal.video = dataVideo
            objTourModal.lat = objMapTapLocationCoordinate.latitude
            objTourModal.long = objMapTapLocationCoordinate.longitude
            
            let isDataInserted = TourDBManager.getInstance().addTourData(objTourModal: objTourModal)
            if isDataInserted {
                self.view.makeToast(AlertMessage.msgSaveSuccess)
            } else {
                self.view.makeToast(AlertMessage.msgSaveFailed)
            }
            
            hidePopUp()
            
            fetchTour()
        }
    }
    
    //MARK: - Hide Pop Up Method
    func hidePopUp() {
        
        txtTourname.text = ""
        
        lblVideoName.text = ""
        
        lblVideoName.isHidden = true
        
        btnRemoveVideo.isHidden = true
        
        objMapTapLocationCoordinate = CLLocationCoordinate2D()
        
        dataVideo = nil
        
        vPopUp.isHidden = true
    }
}

//MARK: - MKMapViewDelegate Extension
extension CreateTourVC : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "Identifier"
        var annotationView: MKAnnotationView?
        
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            let btnPlayVideo = UIButton(type: .detailDisclosure)
            btnPlayVideo.setImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
            annotationView?.rightCalloutAccessoryView = btnPlayVideo
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            
            if annotation.title == "Your here" {
                let pinImage = UIImage(named: "ic_current_location")
                
                let size = CGSize(width: 35, height: 35)
                UIGraphicsBeginImageContext(size)
                pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                annotationView.image = resizedImage
            } else {
                let pinImage = UIImage(named: "ic_pin")?.tinted(with: UIColor.random())
                
                let size = CGSize(width: 30, height: 30)
                UIGraphicsBeginImageContext(size)
                pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                annotationView.image = resizedImage
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if view.annotation != nil && control == view.rightCalloutAccessoryView {
            
            if arrTourModal.contains(where: {$0.tour_name == view.annotation?.title}) && arrTourModal.contains(where: {$0.lat == view.annotation?.coordinate.latitude}) && arrTourModal.contains(where: {$0.long == view.annotation?.coordinate.longitude}) {
                
                let index = arrTourModal.indices(where: {$0.tour_name == view.annotation?.title})
                
                if arrTourModal[index?[0] ?? 0].video_name.isEmpty {
                    self.view.makeToast(AlertMessage.msgVideoUnavailable)
                } else {
                    let paths = NSSearchPathForDirectoriesInDomains(
                        FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                    let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
                    let strVideoPath = documentsDirectory.appendingPathComponent(arrTourModal[index?[0] ?? 0].video_name ?? "")
                    
                    let player = AVPlayer(url: strVideoPath)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            }
        }
    }
}

//MARK: - GeoFenceManagerDelegate Extension
extension CreateTourVC : GeoFenceManagerDelegate {
  
    func updateMap() {
        
        loadMap()
    }
}

//MARK: - UIGestureRecognizerDelegate Extension
extension CreateTourVC : UIGestureRecognizerDelegate {
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        
        let location = gestureRecognizer.location(in: vMap)
        objMapTapLocationCoordinate = vMap.convert(location, toCoordinateFrom: vMap)
        
        vPopUp.isHidden = false
    }
}

//MARK: - UITextFieldDelegate Extension
extension CreateTourVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == UIReturnKeyType.next {
            textField.superview?.superview?.superview?.viewWithTag(textField.tag + 1)?.becomeFirstResponder()
        } else if textField.returnKeyType == UIReturnKeyType.done {
            textField.resignFirstResponder()
        }
        
        return true
    }
}

//MARK: - UIImagePickerControllerDelegate & ChoosePicture Extension
extension CreateTourVC : ChoosePicture, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let urlVideo : URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
            
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let videoPath = documentsDirectory.appendingPathComponent("Video-\(Date().timeIntervalSince1970).mp4")
            
            do {
                dataVideo = try? Data(contentsOf: urlVideo)
                try! dataVideo?.write(to: videoPath, options: [])
                
                let alert = UIAlertController(title: "Success", message: "Video saved successfully", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                lblVideoName.text = videoPath.lastPathComponent
                
                lblVideoName.isHidden = false
                
                btnRemoveVideo.isHidden = false
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

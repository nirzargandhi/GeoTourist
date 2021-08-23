//
//  UIViewControllerExtension.swift
//  Order_Now_GIT
//
//  Created by Mac on 16/06/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

extension UIViewController: UINavigationControllerDelegate {
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.navigationController?.delegate = self
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if (self is UINavigationController) || (self is UITabBarController) {
            return
        }
        // NotificationCenter.default.addObserver(self, selector: #selector(self.refreshUI), name: NSNotification.Name(rawValue: "refreshUI"), object: nil)
    }
    
    // NaivgationController Delegate
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        navigationController.interactivePopGestureRecognizer?.isEnabled = navigationController.viewControllers.count > 1
    }
    
    func refreshUI() {
    }
    
    // for get app time out notification
    func getNotificationForAppTimeOut(_ callback :@escaping (_ notification: Notification) -> Void) {
        let testBlock: (Notification) -> Void = { notifications in
            callback(notifications)
        }
       // _ = NOTIFICATIONCENTER.addObserver(forName: .appTimeout, object: nil, queue: OperationQueue.main, using: testBlock)
    }
    
    // get touch event over all window
    func getNotificationForTouchOnView(_ callback :@escaping (_ event: UIEvent?) -> Void) {
        let testBlock: (Notification) -> Void = { notification in
            if let event = notification.object as? UIEvent {
                callback(event)
            } else {
                callback(nil)
            }
        }
       // _ = NOTIFICATIONCENTER.addObserver(forName: .touchOnViewEvent, object: nil, queue: OperationQueue.main, using: testBlock)
    }
    
    // for get notification for user change
    func getNotificationForChangeUser(_ callback :@escaping (_ notification: Notification) -> Void) {
        let testBlock: (Notification) -> Void = { notifications in
            callback(notifications)
        }
       // _ = NOTIFICATIONCENTER.addObserver(forName: .changeUser, object: nil, queue: OperationQueue.main, using: testBlock)
    }
    
    func setTabBarVisible(visible: Bool, animated: Bool) {
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        //APPDELEGATE.tabBarController?.menuButton.isHidden = !visible
        
        // bail if the current state matches the desired state
        if (isTabBarVisible == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration: TimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }
        }
    }
    
    var isTabBarVisible: Bool {
        return (self.tabBarController?.tabBar.frame.origin.y ?? 0) < self.view.frame.maxY
    }
}

extension UIViewController {
    func viewSlideInFromTopToBottom(view: UIView) -> Void {
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        view.layer.add(transition, forKey: kCATransition)
    }
    func viewSlideInFromBottomToTop(view: UIView) -> Void {
        
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        view.layer.add(transition, forKey: kCATransition)
    }
   
    func backMenu() {
           if let navController = self.navigationController {
               navController.popViewController(animated: false)
           }
       }
    func showToast(message : String){
        var toastLabel =  UILabel()
       
            
            toastLabel = UILabel(frame: CGRect(x: UIApplication.shared.keyWindow!.frame.size.width/2 - 150, y: (UIApplication.shared.keyWindow?.frame.size.height)!-100, width:300,  height : 50))
            toastLabel.font = UIFont(name: "Lato", size: 18.0)
        
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        let window: UIWindow? = UIApplication.shared.windows.last
        window?.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 1.0
        
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 7, delay: 0.1, options: UIView.AnimationOptions.curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        })
    }
   
    
    func scrollToTop() {
        func scrollToTop(view: UIView?) {
            guard let view = view else { return }
            
            switch view {
            case let scrollView as UIScrollView:
                if scrollView.scrollsToTop == true {
                    scrollView.setContentOffset(CGPoint(x: 0.0, y: -scrollView.contentInset.top), animated: true)
                    return
                }
            default:
                break
            }
            
            for subView in view.subviews {
                scrollToTop(view: subView)
            }
        }
        
        scrollToTop(view: self.view)
    }
    
    @objc func topMostViewController() -> UIViewController {
        // Handling Modal views
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
            // Handling UIViewController's added as subviews to some other views.
        else {
            for view in self.view.subviews {
                // Key property which most of us are unaware of / rarely use.
                if let subViewController = view.next {
                    if subViewController is UIViewController {
                        let viewController = subViewController as? UIViewController
                        return viewController?.topMostViewController() ?? UIViewController()
                    }
                }
            }
            return self
        }
    }
    
//    private var viewOffline: OfflineView? {
//        get {
//            var offlineView = objc_getAssociatedObject(self, &Keys.OfflineViewKey) as? OfflineView
//            if offlineView == nil {
//                offlineView = BUNDLE.loadNibNamed("OfflineView", owner: self, options: nil)?.first as? OfflineView
//                offlineView?.frame = self.view.frame
//                objc_setAssociatedObject(self, &Keys.OfflineViewKey, offlineView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//            return offlineView
//        }
//        set {
//            objc_setAssociatedObject(self, &Keys.OfflineViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
    
  
    
    // This is for show offline view.
//    func showOfflineView() {
//       // viewOffline?.isHidden = true // for fade in
//        //viewOffline?.btnClose.isHidden = !(isShowCloseButton ?? false)
//
//        if (isShowCloseButton ?? false) {
//            // for close actiomn
//
//            viewOffline?.btnClose.callBackTarget(closure: { [weak self](_) in
//                guard let strong = self else { return }
//                if strong.isModal {
//                    strong.dismiss(animated: true, completion: nil)
//                } else {
//                    strong.navigationController?.popViewController(animated: true)
//                }
//            })
//        }
//
//        if let viewOffline = viewOffline {
//            self.view.addSubview(viewOffline)
//        }
//        viewOffline?.fadeIn()
//    }
    
    // This is for hide offline view.
    func hideOfflineView() {
        //viewOffline?.fadeOut()
    }
    
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}

extension UIScrollView {

    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y,width: 1,height: self.frame.height), animated: animated)
        }
    }

    // Bonus: Scroll to top
    func scrollViewToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }

    // Bonus: Scroll to bottom
    func scrollViewToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
}

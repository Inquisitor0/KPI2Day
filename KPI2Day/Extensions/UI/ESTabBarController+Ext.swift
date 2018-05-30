//
//  ESTabBarController+Ext.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 07.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import ESTabBarController_swift

class TabbarItemView: ESTabBarItemContentView {
    
    var duration = 0.3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let transform = CGAffineTransform.identity
        imageView.transform = transform.scaledBy(x: 1.15, y: 1.15)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func highlightAnimation(animated: Bool, completion: (() -> ())?) {
        UIView.beginAnimations("small", context: nil)
        UIView.setAnimationDuration(0.2)
        let transform = imageView.transform.scaledBy(x: 0.8, y: 0.8)
        imageView.transform = transform
        UIView.commitAnimations()
        completion?()
    }
    
    override func dehighlightAnimation(animated: Bool, completion: (() -> ())?) {
        UIView.beginAnimations("big", context: nil)
        UIView.setAnimationDuration(0.2)
        let transform = CGAffineTransform.identity
        imageView.transform = transform.scaledBy(x: 1.15, y: 1.15)
        UIView.commitAnimations()
        completion?()
    }
    
    override func badgeChangedAnimation(animated: Bool, completion: (() -> ())?) {
        super.badgeChangedAnimation(animated: animated, completion: nil)
        notificationAnimation()
    }
    
    func notificationAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        impliesAnimation.values = [0.0 ,-8.0, 4.0, -4.0, 3.0, -2.0, 0.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
    
    override func updateLayout() {
        super.updateLayout()
        let height: CGFloat = 26.0
        let width: CGFloat = 30.0
        /// Frame accordingly to the inner calculation
        imageView.frame = CGRect(x: (bounds.width - width) / 2.0,
                                 y: (bounds.height - height) / 2.0 - 6.0,
                                 width: width, height: height)
    }
}

extension ESTabBarController {

    static func defaultStudentTabBar() -> ESTabBarController {
        
        let tabBarController = ESTabBarController()
        let v1 = UINavigationController(rootViewController: ScheduleVC()) // Schedule
        let v2 = UINavigationController(rootViewController: SettingsVC()) // Settings
        
        let scheduleImage = #imageLiteral(resourceName: "schedule_icon")
        let settingsImage = #imageLiteral(resourceName: "settings_icon")
        
        v1.tabBarItem = ESTabBarItem(TabbarItemView(), title: "Schedule",
                                     image: scheduleImage)
        v2.tabBarItem = ESTabBarItem(TabbarItemView(), title: "Settings",
                                     image: settingsImage)
        
        tabBarController.viewControllers = [v1, v2]
        
        return tabBarController
    }
}

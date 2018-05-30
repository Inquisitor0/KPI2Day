//
//  SelectGroupView.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 13.05.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import SnapKit

class SelectGroupView: UIView {
    
    var textField = UITextField()
    var okButton = UIButton()
    
    private var scrollView = UIScrollView()
    
    private let numberOfWallpapers = 1
    private var isReverseScrolling = false // Let's scroll back when wallpapers ends
    private weak var timer: Timer?
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(moveScrollView),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        setupScrollView()
        
        addSubview(textField)
        textField.placeholder = "Enter your group"
        textField.backgroundColor = .white
        textField.alpha = 0.7
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 12
        textField.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(44)
        }
        
        addSubview(okButton)
        okButton.setTitle("OK", for: .normal)
        okButton.tintColor = .green
        okButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.width.equalTo(40)
            make.height.equalTo(20)
        }
    }
    
    private func setupScrollView() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(tapGR)
        
        scrollView.isScrollEnabled = false
        
        let imageViewSize = CGSize(width: #imageLiteral(resourceName: "wallpaper-0").size.width, height: UIScreen.main.bounds.size.height)
        for i in 0..<numberOfWallpapers {
            let originPoint = CGPoint(x: imageViewSize.width * CGFloat(i), y: 0)
            let imageView = UIImageView(frame: CGRect(origin: originPoint, size: imageViewSize))
            imageView.image = UIImage(named: "wallpaper-\(i)")
            imageView.contentMode = .scaleAspectFill
            scrollView.addSubview(imageView)
        }
        scrollView.contentSize = CGSize(width: imageViewSize.width * CGFloat(numberOfWallpapers),
                                        height: scrollView.bounds.height)
    }
    
    @objc private func moveScrollView() {
        let offset: CGFloat = isReverseScrolling ? -3 : 3
        let newContentOffset = CGPoint(x: scrollView.contentOffset.x + offset,
                                       y: scrollView.contentOffset.y)
        scrollView.setContentOffset(newContentOffset, animated: true)
        
        if (scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.width - offset) ||
            (scrollView.contentOffset.x <= 0 - offset) {
            isReverseScrolling = !isReverseScrolling
        }
    }
    
    @objc private func hideKeyboard() {
        endEditing(true)
    }
    
}

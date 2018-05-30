//
//  LessonTableViewCell.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 09.04.18.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import SnapKit

struct LessonTableCellViewModel {
    let subjectIndex: Int
    let roomNumber: String
    let subjectName: String
    let teacherName: String
}

class LessonTableViewCell: UITableViewCell {
    
    private let indexLabel = UILabel()
    private let roomLabel = UILabel()
    private let titleLabel = UILabel()
    private let teacherLabel = UILabel()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(indexLabel)
        indexLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(indexLabel.snp.right).offset(16)
            make.width.equalToSuperview().multipliedBy(0.65)
            make.height.equalToSuperview().dividedBy(2)
        }
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        addSubview(roomLabel)
        roomLabel.adjustsFontSizeToFitWidth = true
        roomLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(titleLabel.snp.right)
            make.height.equalTo(30)
        }
        
        addSubview(teacherLabel)
        teacherLabel.numberOfLines = 2
        teacherLabel.textColor = .blue
        teacherLabel.snp.makeConstraints { make in
            make.left.equalTo(indexLabel.snp.right).offset(16)
            make.width.equalToSuperview().multipliedBy(0.75)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func update(model: LessonTableCellViewModel) {
        indexLabel.text = "\(model.subjectIndex)"
        roomLabel.text = model.roomNumber
        titleLabel.text = model.subjectName
        teacherLabel.text = model.teacherName
    }
}

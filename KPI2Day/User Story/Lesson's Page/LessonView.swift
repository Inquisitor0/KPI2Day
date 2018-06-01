//
//  LessonView.swift
//  KPI2Day
//
//  Created by Inquisitor on 01.06.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps

protocol LessonViewDelegate: class {
    func didPressTeacherButton()
}

struct LessonViewModel {
    
    private let lesson: Lesson
    
    var disciplineName: String {
        return lesson.discipline?.fullName ?? ""
    }
    
    var roomNumber: String {
        return lesson.rooms.first?.fullName ?? ""
    }
    
    var teacherName: String {
        return lesson.teachers.first?.shortNameWithDegree ?? ""
    }
    
    var coordinates: (long: Double, lat: Double) {
        let longitude: Double = lesson.rooms.first?.building?.longitude ?? 0
        let latitude: Double = lesson.rooms.first?.building?.latitude ?? 0
        return (longitude, latitude)
    }
    
    init(lesson: Lesson) {
        self.lesson = lesson
    }
}

class LessonView: UIView {
    
    private var viewModel: LessonViewModel!
    
    private let disciplineLabel = UILabel()
    private let roomLabel = UILabel()
    private let teacherButton = UIButton()
    private let mapView = GMSMapView(frame: .zero)
    
    weak var delegate: LessonViewDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func update(with model: LessonViewModel) {
        self.viewModel = model
        configureMap()
        setupData()
    }
    
    private func configureUI() {
        backgroundColor = .white
        
        addSubview(disciplineLabel)
        disciplineLabel.font = UIFont.boldSystemFont(ofSize: 18)
        disciplineLabel.numberOfLines = 3
        disciplineLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
        }
        
        addSubview(roomLabel)
        roomLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(disciplineLabel.snp.bottom).offset(10)
        }
        
        addSubview(teacherButton)
        teacherButton.setTitleColor(.blue, for: .normal)
        teacherButton.addTarget(self, action: #selector(teacherButtonAction), for: .touchUpInside)
        teacherButton.snp.makeConstraints { (make) in
            make.top.equalTo(roomLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
        }
    }
    
    private func configureMap() {
        let camera = GMSCameraPosition.camera(withLatitude: viewModel.coordinates.lat,
                                              longitude: viewModel.coordinates.long,
                                              zoom: 16)
        
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        
        addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.top.equalTo(teacherButton.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(8)
            make.right.bottom.equalToSuperview().offset(-8)
        }
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: viewModel.coordinates.lat,
                                                 longitude: viewModel.coordinates.long)
        marker.map = mapView
        
    }
    
    private func setupData() {
        disciplineLabel.text = viewModel.disciplineName
        roomLabel.text = viewModel.roomNumber
        teacherButton.setTitle(viewModel.teacherName, for: .normal)
    }
    
    @objc private func teacherButtonAction() {
        delegate?.didPressTeacherButton()
    }
}

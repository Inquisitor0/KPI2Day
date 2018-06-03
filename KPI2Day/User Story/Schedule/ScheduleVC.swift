//
//  ScheduleVC.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 07.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import PKHUD
import SnapKit

enum ScheduleType {
    case group(id: String)
    case teacher(id: String)
    
    var targetId: String {
        switch self {
        case .group(let groupId):
            return groupId
        case .teacher(let teacherid):
            return teacherid
        }
    }
    
    var shouldUseRealmStorage: Bool {
        switch self {
        case .group:
            return true
        case .teacher:
            return false
        }
    }
}

class ScheduleVC: UIViewController {

    private let viewModel: ScheduleVM
    private let tableView = UITableView()
    private let weekSwitcher = UISegmentedControl()
    
    private var currentWeekIndex = 0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(type: ScheduleType) {
        viewModel = ScheduleVM(type: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavBar()
        viewModel.delegate = self
        loadSchedule()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadSchedule() {
        HUD.show(.progress)
        viewModel.loadFullSchedule()
    }
    
    private func setupNavBar() {
        // TODO: (alex) Localizable
        title = "Schedule"
        setupSegmentedControl()
    }
}

extension ScheduleVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let lessonsForWeekDay = viewModel.lessons(forWeek: currentWeekIndex)[section + 1]
        return lessonsForWeekDay?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Mon"
        case 1:
            return "Tue"
        case 2:
            return "Wen"
        case 3:
            return "Thu"
        case 4:
            return "Fri"
        case 5:
            return "Sat"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let lessonsForSection = viewModel.lessons(forWeek: currentWeekIndex)[section + 1]
        return (lessonsForSection?.count ?? 0) > 0 ? UITableViewAutomaticDimension : 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let lessonsArray = viewModel.lessons(forWeek: currentWeekIndex)[indexPath.section + 1] else { return UITableViewCell() }
        let lesson = lessonsArray[indexPath.row]
        let cell = LessonTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "myIdentifier")
        let model = scheduleCellViewModel(lesson: lesson, index: indexPath.row + 1)
        cell.update(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let lessonsArray = viewModel.lessons(forWeek: currentWeekIndex)[indexPath.section + 1] else { return }
        let lesson = lessonsArray[indexPath.row]
        
        showLessonDetails(lesson: lesson)
    }
    
    private func showLessonDetails(lesson: Lesson) {
        let lessonVC = LessonVC(lesson: lesson)
        navigationController?.pushViewController(lessonVC, animated: true)
    }
    
    private func scheduleCellViewModel(lesson: Lesson, index: Int) -> LessonTableCellViewModel {
        let model = LessonTableCellViewModel(subjectIndex: index,
                                             roomNumber: lesson.rooms.first?.fullName ?? "",
                                             subjectName: lesson.discipline?.name ?? "",
                                             teacherName: lesson.teachers.first?.fullName ?? "")
        return model
    }
}

// MARK: Realm

extension ScheduleVC: ScheduleVMDelegate {
    
    func didUpdateSchedule() {
        HUD.hide()
        tableView.reloadData()
    }
    
    func didRecieveError(error: Error) {
        HUD.hide()
        AlertPresenter.showErrorAlert(title: error.localizedDescription)
    }
}

// MARK: Additional UI setup
extension ScheduleVC {
    
    private func setupSegmentedControl() {
        weekSwitcher.insertSegment(withTitle: "1", at: 0, animated: false)
        weekSwitcher.insertSegment(withTitle: "2", at: 1, animated: false)
        weekSwitcher.tintColor = .darkGray
        weekSwitcher.setWidth(40, forSegmentAt: 0)
        weekSwitcher.setWidth(40, forSegmentAt: 1)
        weekSwitcher.selectedSegmentIndex = 0
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: weekSwitcher)
        
        weekSwitcher.addTarget(self, action: #selector(didChangeWeekIndex), for: .valueChanged)
        
    }
    
    @objc private func didChangeWeekIndex() {
        let currentIndex = weekSwitcher.selectedSegmentIndex
        currentWeekIndex = currentIndex
    }
}

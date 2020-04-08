//
//  ConfigurationTableViewController.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/4/8.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit

class ConfigurationTableViewController: UITableViewController {
    
    var configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum Section: Int, CaseIterable {
        case viewMode = 0
        case display = 1
    }
    
    private static let CellIdentifier = "CellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ConfigurationTableViewController.CellIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else {
            return nil
        }
        
        switch section {
        case .viewMode:
            return "View Mode"
        case .display:
            return "Display"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .viewMode:
            return Configuration.ViewMode.allCases.count
        case .display:
            return displaySettings.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)

        guard let section = Section(rawValue: indexPath.section) else {
            return cell
        }
        
        switch section {
        case .viewMode:
            configure(viewMode: cell, for: indexPath.row)
        case .display:
            configure(display: cell, for: indexPath.row)
        }

        return cell
    }
    
    private func configure(viewMode cell: UITableViewCell, for row: Int) {
        if let mode = Configuration.ViewMode(rawValue: row) {
            cell.accessoryType = configuration.viewMode == mode ? .checkmark : .none
            cell.textLabel?.text = mode.description
        }
    }
    
    private lazy var clipSwitch: UISwitch = {
        let clipSwitch = UISwitch()
        clipSwitch.addTarget(self, action: #selector(clipSwitchChange(_:)), for: .valueChanged)
        clipSwitch.isOn = self.configuration.showClippedContent
        return clipSwitch
    }()
    
    @objc
    private func clipSwitchChange(_ sender: UISwitch) {
        configuration.showClippedContent = sender.isOn
    }
    
    private lazy var labelSwitch: UISwitch = {
        let clipSwitch = UISwitch()
        clipSwitch.addTarget(self, action: #selector(labelSwitchChange(_:)), for: .valueChanged)
        clipSwitch.isOn = self.configuration.showViewLabel
        return clipSwitch
    }()
    
    @objc
    private func labelSwitchChange(_ sender: UISwitch) {
        configuration.showViewLabel = sender.isOn
    }
    
    private var displaySettings = ["Show Clipped Contents", "Show View Labels"]
    private var displaySwitches: [UISwitch] {
        return [clipSwitch, labelSwitch]
    }
    
    private func configure(display cell: UITableViewCell, for row: Int) {
        cell.textLabel?.text = displaySettings[row]
        cell.accessoryView = displaySwitches[row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }

        switch section {
        case .viewMode:
            configuration.viewMode = Configuration.ViewMode(rawValue: indexPath.row)!
        case .display:
            break
        }

        tableView.reloadSections([indexPath.section], with: .none)
    }

}

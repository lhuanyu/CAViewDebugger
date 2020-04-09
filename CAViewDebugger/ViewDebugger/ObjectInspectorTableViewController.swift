//
//  ObjectInspectorTableViewController.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/4/9.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit

class InspectorDetailCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ObjectInspectorTableViewController: UITableViewController {
    
    private weak var snapshot: SnapshotView!
    
    private var originalView: UIView {
        return snapshot.originalView
    }
    
    init(snapshot: SnapshotView) {
        self.snapshot = snapshot
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static let CellIdentifier = "CellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        tableView.register(InspectorDetailCell.self, forCellReuseIdentifier: ObjectInspectorTableViewController.CellIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return ObjectInspectorSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ObjectInspectorSection.allCases[section].description
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ObjectInspectorSection.allCases[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ObjectInspectorTableViewController.CellIdentifier, for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }

    private lazy var bgColorView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 30, height: 30))
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var tintColorView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 30, height: 30))
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let section = ObjectInspectorSection.allCases[indexPath.section]
        cell.imageView?.image = nil
        cell.accessoryView = nil
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = section.rows[indexPath.row].description
        let row = indexPath.row
        switch section {
        case .object:
            if row == 0 {
                cell.detailTextLabel?.text = "\(type(of: originalView))"
                cell.imageView?.image = UIImage.bundleImage(named: "\(type(of: originalView))")
            } else if row == 1 {
                cell.detailTextLabel?.text = "\(Unmanaged.passRetained(originalView).toOpaque())"
            }
        case .view:
            guard let property = ObjectInspectorSection.ViewProperty(rawValue: row) else { fallthrough }
            switch property {
            case .layer:
                cell.detailTextLabel?.text = originalView.layer.description
            case .layerClass:
                cell.detailTextLabel?.text = "\(type(of: originalView.layer))"
            case .contentMode:
                cell.detailTextLabel?.text = originalView.contentMode.description
            case .tag:
                cell.detailTextLabel?.text = "\(originalView.tag)"
            case .userInteraction:
                cell.detailTextLabel?.text = "\(originalView.isUserInteractionEnabled)"
            case .multiTouch:
                cell.detailTextLabel?.text = "\(originalView.isMultipleTouchEnabled)"
            case .alpha:
                cell.detailTextLabel?.text = "\(originalView.alpha)"
            case .backgroundColor:
                bgColorView.backgroundColor = originalView.backgroundColor
                cell.accessoryView = bgColorView
                if let name = originalView.backgroundColor?.name {
                    cell.detailTextLabel?.text = (originalView.backgroundColor?.rgbDesciption ?? "") + " " + name
                } else {
                    cell.detailTextLabel?.text = originalView.backgroundColor?.rgbDesciption
                }
            case .tintColor:
                tintColorView.backgroundColor = originalView.tintColor
                cell.accessoryView = tintColorView
                if let name = originalView.tintColor?.name {
                    cell.detailTextLabel?.text = (originalView.tintColor?.rgbDesciption ?? "") + " " + name
                } else {
                    cell.detailTextLabel?.text = originalView.tintColor?.rgbDesciption
                }
            }
        case .drawing:
            if row == 0 {
                cell.detailTextLabel?.text = "\(originalView.isOpaque)"
            } else if row == 1 {
                cell.detailTextLabel?.text = "\(originalView.isHidden)"
            } else if row == 2 {
                cell.detailTextLabel?.text = "\(originalView.clearsContextBeforeDrawing)"
            } else if row == 3 {
                cell.detailTextLabel?.text = "\(originalView.clipsToBounds)"
            } else if row == 4 {
                cell.detailTextLabel?.text = "\(originalView.autoresizesSubviews)"
            }
        case .description:
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = view.description
        case .hierarchy:
            cell.detailTextLabel?.text = view.superClassHierarchy.reduce("", {$0 + $1 + "\n"})
        }
        
        
    }


}

extension UIColor {
    
    var rgbDesciption: String? {
        var red = CGFloat.zero
        var green = CGFloat.zero
        var blue = CGFloat.zero
        var alpha = CGFloat.zero
        
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return String(format: "R:%.2f G:%.2f B:%.2f A:%.2f", red, green, blue, alpha)
        }
        return nil
    }
    
    var name: String? {
        let desc = "\(self)"
        if let range = desc.range(of: "name =") {
            if let name = desc[range.upperBound..<desc.endIndex].split(whereSeparator: {
                $0 == ";" || $0 == ">"
                }).first {
                return String(name)
            }
        }
        return nil
    }
}

extension UIView {
    
    var superClassHierarchy: [String] {
        var hierachy = [String]()
        var father: AnyClass? = self.superclass
        while father != nil {
            hierachy.append("\(father!)")
            father = father?.superclass()
        }
        return hierachy
        
    }
}

extension UIView.ContentMode: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .bottom:
            return "Bottom"
        case .bottomLeft:
            return "Bottom Left"
        case .bottomRight:
            return "Bottom Left"
        case .left:
            return "Left"
        case .redraw:
            return "Redraw"
        case .right:
            return "Right"
        case .scaleAspectFill:
            return "Scale Aspect Fill"
        case .scaleToFill:
            return "Scale To Fill"
        case .scaleAspectFit:
            return "Scale Aspect Fit"
        case .center:
            return "Center"
        case .top:
            return "Top"
        case .topLeft:
            return "Top Left"
        case .topRight:
            return "Top Right"
        @unknown default:
            return ""
        }
    }
}

//
//  ViewHierarchyTableViewController.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/4/13.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit

class ViewHierarchyCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        indentationWidth = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame.origin.x += indentationWidth * CGFloat(indentationLevel)
    }
}

class ViewHierarchyTableViewController: UITableViewController {
    
    enum Section {
        case windowScene
    }
    
    private weak var sceneView: SceneView!
    private var flattenSnapshots = [SnapshotView]()
    private var visibleSnapshots = [SnapshotView]()
    
    @available(iOS 13.0, *)
    private lazy var datasource: UITableViewDiffableDataSource = {
        return UITableViewDiffableDataSource<Section, SnapshotView>(tableView: self.tableView) { (tableView, indexPath, snapshot) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifer", for: indexPath)
            cell.imageView?.image = snapshot.originalView.payloadIcon
            cell.accessoryType = snapshot.chidren.isEmpty ? .none : .detailButton
            cell.indentationLevel = snapshot.depth
            cell.textLabel?.text = snapshot.originalView.payloadName
            return cell
        }
    }()
    
    @objc
    public init(scene: SceneView) {
        sceneView = scene
        flattenSnapshots = [scene.rootSnapshotView] + scene.rootSnapshotView.recursiveChildren
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ViewHierarchyCell.self, forCellReuseIdentifier: "CellIdentifer")
        if #available(iOS 13.0, *) {
            tableView.dataSource = datasource
        }
        clearsSelectionOnViewWillAppear = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTableView()
    }
    
    private func reloadTableView() {
        if let selectedSnapshot = sceneView.selectedView {
            var parent = selectedSnapshot.parent
            var child = parent
            while parent != nil {
                parent?.isFolding = false
                child = parent
                parent = parent?.parent
            }
            child?.unfold()
            update {
                let indexPath = self.indexPath(for: selectedSnapshot)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            }
        } else {
            update()
        }
    }
    
    private func update(completion: (() -> Void)? = nil) {
        visibleSnapshots = flattenSnapshots.filter { $0.isVisible }
        if #available(iOS 13.0, *) {
            var snapshot = NSDiffableDataSourceSnapshot<Section, SnapshotView>()
            snapshot.appendSections([.windowScene])
            snapshot.appendItems(visibleSnapshots)
            datasource.apply(snapshot, animatingDifferences: true, completion: completion)
        } else {
            let contentOffset = tableView.contentOffset
            tableView.reloadData()
            tableView.contentOffset = contentOffset
            completion?()
        }
    }
    
    private func indexPath(for snapshot: SnapshotView) -> IndexPath? {
        if #available(iOS 13.0, *) {
            return datasource.indexPath(for: snapshot)
        } else {
            if let row = visibleSnapshots.firstIndex(of: snapshot) {
                return IndexPath(row: row, section: 0)
            }
            return nil
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let snapshot = visibleSnapshots[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifer", for: indexPath)
        cell.imageView?.image = snapshot.originalView.payloadIcon
        cell.accessoryType = snapshot.chidren.isEmpty ? .none : .detailButton
        cell.indentationLevel = snapshot.depth
        cell.textLabel?.text = snapshot.originalView.payloadName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleSnapshots.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private func snapshot(for indexPath: IndexPath) -> SnapshotView? {
        if #available(iOS 13.0, *) {
            return datasource.itemIdentifier(for: indexPath)
        } else {
            return visibleSnapshots[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let snapshotView = snapshot(for: indexPath) else {
            return
        }
        if snapshotView.isFolding {
            snapshotView.unfold()
        } else {
            snapshotView.fold()
        }
        update()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let snapshotView = snapshot(for: indexPath) else {
            return
        }
        sceneView.selectedView = snapshotView
    }

}

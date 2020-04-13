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

@available(iOS 13.0, *)
class ViewHierarchyTableViewController: UITableViewController {
    
    enum Section {
        case windowScene
    }
    
    private weak var sceneView: SceneView!
    private var flattenSnapshots = [SnapshotView]()
    
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
        defaultSnapshot = NSDiffableDataSourceSnapshot<Section, SnapshotView>()
        defaultSnapshot.appendSections([.windowScene])
        defaultSnapshot.appendItems(flattenSnapshots)
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ViewHierarchyCell.self, forCellReuseIdentifier: "CellIdentifer")
        tableView.dataSource = datasource
        clearsSelectionOnViewWillAppear = false
    }
    
    private var defaultSnapshot: NSDiffableDataSourceSnapshot<Section, SnapshotView>
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                let indexPath = self.datasource.indexPath(for: selectedSnapshot)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            }
        } else {
            update()
        }

    }
    
    private func update(completion: (() -> Void)? = nil) {
        let visibleSnapshots = flattenSnapshots.filter { $0.isVisible }
        var snapshot = NSDiffableDataSourceSnapshot<Section, SnapshotView>()
        snapshot.appendSections([.windowScene])
        snapshot.appendItems(visibleSnapshots)
        datasource.apply(snapshot, animatingDifferences: true, completion: completion)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let snapshotView = datasource.itemIdentifier(for: indexPath) else {
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
        guard let snapshotView = datasource.itemIdentifier(for: indexPath) else {
            return
        }
        sceneView.selectedView = snapshotView
    }

}

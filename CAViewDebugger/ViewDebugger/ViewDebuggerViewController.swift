//
//  ViewDebuggerViewController.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/3/27.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit

final class ViewDebuggerViewController: UIViewController {
    
    let containerView: SceneView!

    private lazy var rangeSlider: RangeSlider = {
        let slider = RangeSlider(range: 0...Int(self.containerView.maxLevel))
        slider.frame = CGRect(x: 10,
                              y: self.view.bounds.height - 100,
                              width: self.view.bounds.width - 20,
                              height: 62)
        slider.layer.zPosition = 2000
        return slider
    }()
    
    init(window: UIWindow) {
        self.containerView = SceneView(window: window)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.8820094466, green: 0.8900626302, blue: 0.9024230838, alpha: 1)
        self.view.addSubview(containerView)
        containerView.frame = self.view.bounds
        
        view.addSubview(rangeSlider)
        rangeSlider.didChange = { [weak self] in
            self?.containerView.visibleLevelsRange = $0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func present(in window: UIWindow) {
        let debuggerVC = ViewDebuggerViewController(window: window)
        let navigationController = UINavigationController(rootViewController: debuggerVC)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        debuggerVC.title = "Snapshot"

//        let item = UIBarButtonItem(title: "Settings", style: .done, target: debuggerVC, action: #selector(showSettings))
//        debuggerVC.navigationItem.leftBarButtonItem = item
        
        debuggerVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: debuggerVC, action: #selector(done))
        window.rootViewController?.present(navigationController, animated: true, completion: {
            debuggerVC.containerView.setCamera()
        })
    }
    
    @objc
    func showSettings() {

    }
    
    @objc
    func done() {
        containerView.resetCamera { [weak self] finished in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
}

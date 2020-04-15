//
//  ViewDebuggerViewController.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/3/27.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit

@objc
public final class ViewDebuggerViewController: UIViewController, UIAdaptivePresentationControllerDelegate, UINavigationControllerDelegate {
    
    private let containerView: SceneView!
    
    private lazy var basicInfoButton: UIButton = {
        let button = UIButton(type: .custom)
        var top = CGFloat.zero
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.backgroundColor = .white
        button.isHidden = true
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.zPosition = 20000
        button.addTarget(self, action: #selector(showObjectInspector(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var viewHirearchyButton: UIButton = {
        let button = UIButton(type: .system)
        var top = CGFloat.zero
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("View Hireacrchy", for: .normal)
        button.layer.zPosition = 20000
        button.addTarget(self, action: #selector(showViewHierachy(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var rangeSlider: RangeSlider = {
        let slider = RangeSlider(range: 0...Int(self.containerView.maxLevel))
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.layer.zPosition = 20000
        return slider
    }()
    
    private lazy var spacingSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.maximumValue = 200
        slider.minimumValue = 1
        slider.addTarget(self, action: #selector(spacingSliderDidChange(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.layer.zPosition = 20000
        return slider
    }()
    
    @objc
    public init(window: UIWindow) {
        self.containerView = SceneView(window: window)
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.8820094466, green: 0.8900626302, blue: 0.9024230838, alpha: 1)
        self.view.addSubview(containerView)
        containerView.frame = self.view.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.delegate = self
        
        view.addSubview(rangeSlider)
        rangeSlider.didChange = { [weak self] in
            self?.containerView.visibleLevelsRange = $0
        }
        view.addSubview(spacingSlider)
        spacingSlider.value = Float(containerView.layerSpacing)
        view.addSubview(basicInfoButton)
        
        spacingSlider.heightAnchor.constraint(equalToConstant: 40).isActive = true
        rangeSlider.heightAnchor.constraint(equalToConstant: 40).isActive = true

        if #available(iOS 11.0, *) {
            spacingSlider.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5, constant: -15).isActive = true
            spacingSlider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
            spacingSlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
            rangeSlider.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5, constant: -15).isActive = true
            rangeSlider.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            rangeSlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            spacingSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -15).isActive = true
            spacingSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
            spacingSlider.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            rangeSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -15).isActive = true
            rangeSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
            rangeSlider.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        basicInfoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        basicInfoButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        basicInfoButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        if #available(iOS 11.0, *) {
            basicInfoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            basicInfoButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        
        view.addSubview(viewHirearchyButton)
        viewHirearchyButton.bottomAnchor.constraint(equalTo: rangeSlider.topAnchor, constant: -10).isActive = true
        viewHirearchyButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        if #available(iOS 11.0, *) {
            viewHirearchyButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        } else {
            viewHirearchyButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public static func present(in window: UIWindow) {
        let debuggerVC = ViewDebuggerViewController(window: window)
        let navigationController = UINavigationController(rootViewController: debuggerVC)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        debuggerVC.title = "\(type(of: window))"
        
        debuggerVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .done, target: debuggerVC, action: #selector(showSettings))
        debuggerVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: debuggerVC, action: #selector(done))
        
        let resetButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: debuggerVC, action: #selector(restore))
        debuggerVC.navigationItem.rightBarButtonItems?.append(resetButton)
        
        window.rootViewController?.present(navigationController, animated: true, completion: {
            debuggerVC.containerView.setCamera()
        })
    }
    
    private lazy var configurationViewController = ConfigurationTableViewController(configuration: containerView.configuration)
    
    @objc
    private func showSettings() {
        if #available(iOS 13.0, *) {
            configurationViewController.presentationController?.delegate = self
            present(configurationViewController, animated: true, completion: nil)
        } else {
            navigationController?.delegate = self
            navigationController?.pushViewController(configurationViewController, animated: true)
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        updateConfigurationIfNeeded()
    }
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        updateConfigurationIfNeeded()
    }
    
    private func updateConfigurationIfNeeded() {
        if containerView.configuration != configurationViewController.configuration {
            containerView.update(with: configurationViewController.configuration)
            updateBasicInfoButton(with: containerView.selectedView)
        }
    }
    
    @objc
    private func restore() {
        containerView.setCamera()
        spacingSlider.setValue(Float(containerView.layerSpacing), animated: true)
    }
    
    @objc
    private func done() {
        containerView.resetCamera { [weak self] finished in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    private func spacingSliderDidChange(_ sender: UISlider) {
        containerView.layerSpacing = CGFloat(sender.value)
        containerView.update()
    }
    
    @objc
    private func showObjectInspector(_ sender: UIButton) {
        let inspectorVC = ObjectInspectorTableViewController(snapshot: containerView.selectedView!)
        if #available(iOS 13.0, *) {
            present(inspectorVC, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(inspectorVC, animated: true)
        }
    }
    
    private lazy var viewHirearchyTableViewController: ViewHierarchyTableViewController = {
        return ViewHierarchyTableViewController(scene: self.containerView)
    }()
    
    @objc
    private func showViewHierachy(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            present(viewHirearchyTableViewController, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(viewHirearchyTableViewController, animated: true)
        }
    }
    
}


extension ViewDebuggerViewController: SceneViewDelgate {
    
    public func sceneView(_ view: SceneView, didSelect snapshot: SnapshotView?) {
        updateBasicInfoButton(with: snapshot)
    }
    
    public func sceneView(_ view: SceneView, didFocus snapshot: SnapshotView?) {
        if let snapshot = snapshot {
            title = snapshot.originalView.payloadName
        } else {
            title = view.rootSnapshotView.originalView.payloadName
        }
    }
    
    
    private func updateBasicInfoButton(with snapshot: SnapshotView?) {
        if let snapshot = snapshot {
            basicInfoButton.setImage(snapshot.originalView.payloadIcon, for: .normal)
            basicInfoButton.setTitle(snapshot.originalView.payloadName + " " + snapshot.visibleFrame.oneDigitDescription, for: .normal)
            basicInfoButton.isHidden = false
        } else {
            basicInfoButton.isHidden = true
        }
    }
    
}

extension CGRect {
    
    var oneDigitDescription: String {
        return String(format: "(%.1f, %.1f, %.1f, %.1f)", origin.x, origin.y, width, height)
    }
    
}

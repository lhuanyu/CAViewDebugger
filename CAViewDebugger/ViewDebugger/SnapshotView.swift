//
//  SnapshotView.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/3/27.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit

protocol Snapshotable {
    func snapshot() -> CGImage?
}

extension UIView: Snapshotable {
    
    private func draw() -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.cgImage
    }
    
    private func hideViewsOnTopOf(view: UIView, root: UIView, hiddenViews: inout [UIView]) -> Bool {
        if root == view {
            return true
        }
        var foundView = false
        for subview in root.subviews.reversed() {
            if hideViewsOnTopOf(view: view, root: subview, hiddenViews: &hiddenViews) {
                foundView = true
                break
            }
        }
        if !foundView {
            if !root.isHidden {
                hiddenViews.append(root)
            }
            root.isHidden = true
        }
        return foundView
    }
    
    private func snapshotVisualEffectBackdropView(_ view: UIView) -> CGImage? {
        guard let window = view.window else {
            return nil
        }
        var hiddenViews = [UIView]()
        defer {
            hiddenViews.forEach { $0.isHidden = false }
        }
        
        if hideViewsOnTopOf(view: view, root: window, hiddenViews: &hiddenViews) {
            let image = window.draw()
            let cropRect = window.convert(view.bounds, from: view)
            return image?.cropping(to: cropRect)
        }
        return nil
    }
    
    func snapshot() -> CGImage? {
        if let superview = self.superview, let _ = superview as? UIVisualEffectView,
            superview.subviews.first == self {
            return snapshotVisualEffectBackdropView(self)
        }
        
        var hiddens = [Bool]()
        subviews.forEach {
            hiddens.append($0.isHidden)
            $0.isHidden = true
        }
        
        let image = draw()
        for index in subviews.indices {
            subviews[index].isHidden = hiddens[index]
        }
        
        return image
    }
    
}

final class SnapshotView: UIView {
    
    weak var root: UIView!
    var originalView = UIView()
    var chidren = [SnapshotView]()
    var normalFrame = CGRect.zero
    var visibleBounds = CGRect.zero
    var visibleFrame = CGRect.zero
    var level: CGFloat = 0
    
    private lazy var titleView: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10)
        button.isUserInteractionEnabled = false
        
        let frame = CGRect(x: self.visibleFrame.origin.x,
                           y: self.visibleFrame.origin.y - 21,
                           width: self.visibleFrame.width,
                           height: 19)
        button.frame = self.convert(frame, from: self.root)
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(self.originalView.payloadIcon, for: .normal)
        return button
    }()
    
    init(view: UIView, root: UIWindow) {
        super.init(frame: view.bounds)
        self.originalView = view
        self.root = root
        self.layer.contents = view.snapshot()
        
        if let scrollView =  view.superview as? UIScrollView {
            let contentOffset = scrollView.contentOffset
            let frame = view.frame.offsetBy(dx: -contentOffset.x, dy: -contentOffset.y)
            self.normalFrame = root.convert(frame, from: view.superview)
        } else {
            self.normalFrame = root.convert(view.frame, from: view.superview)
        }
        
        self.frame = normalFrame
        
        if let superview = superview, superview.clipsToBounds {
            let frame = superview.bounds.intersection(view.frame)
            self.visibleFrame = root.convert(frame, from: superview)
        } else {
            self.visibleFrame = root.bounds.intersection(self.normalFrame)
        }
        
        let insets = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        if self.visibleFrame != self.normalFrame {
            self.visibleBounds = self.convert(self.visibleFrame, from: root).inset(by: insets)
            let path = UIBezierPath(rect: visibleBounds)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            mask.fillColor = UIColor.black.cgColor
            mask.frame = self.layer.bounds
            self.layer.mask = mask
        } else {
            self.visibleBounds = bounds.inset(by: insets)
        }
        
        self.addBorder()
        
        self.updateTitleView(with: view)
        self.addSubview(titleView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        
        doubleTap.numberOfTapsRequired = 2
        
        self.addGestureRecognizer(doubleTap)
        
        self.chidren = view.subviews.map {
            let snapshot = SnapshotView(view: $0, root: root)
            return snapshot
        }
    }
    
    private let border = CAShapeLayer()
    
    private func addBorder() {
        let path = UIBezierPath(rect: convert(visibleFrame, from: root))
        border.path = path.cgPath
        border.fillColor = UIColor.clear.cgColor
        border.strokeColor = UIColor.lightGray.cgColor
        border.lineWidth = 1.0 * UIScreen.main.scale
        layer.addSublayer(border)
    }
    
    private func updateTitleView(with view: UIView) {
        switch view.payload {
        case .window:
            titleView.isHidden = false
        case .controller(_):
            titleView.isHidden = false
        case .view:
            titleView.isHidden = false
        }
        
        titleView.setTitle(view.payloadName, for: .normal)
        
        if let width = titleView.titleLabel?.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude, height: 12)).width {
            if width + 40 > bounds.width {
                titleView.frame.size.width = width + 40
                titleView.center.x = bounds.width * 0.5
            }
        }
    }
    
    override init(frame: CGRect) {
        fatalError("Do not call this method directly.")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Do not call this method directly.")
    }
    
    var selected: Bool = false {
        didSet {
            if selected {
                border.fillColor = UIColor.cyan.withAlphaComponent(0.6).cgColor
                border.strokeColor = tintColor.cgColor
            } else {
                border.fillColor = UIColor.clear.cgColor
                border.strokeColor = UIColor.lightGray.cgColor
            }
        }
    }
    
    @objc
    func tap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .recognized {
            containerView?.selectedView = self
        }
    }
    
    @objc
    func doubleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .recognized {
            containerView?.focusedView = self
        }
    }
    
    weak var containerView: SceneView? {
        return superview as? SceneView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if visibleBounds.contains(point) || titleView.frame.contains(point) {
            return true
        }
        return false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    var recursiveChildren: [SnapshotView] {
        return chidren + chidren.flatMap { $0.recursiveChildren }
    }
    
}

enum PayloadType {
    case window
    case controller(String)
    case view
}

extension UIView {
    
    var isUIViewController: Bool {
        if let responder = next {
            if responder.isKind(of: UIViewController.self) {
                return true
            }
        }
        return false
    }
    
    /// The  object view presented.
    var payload: PayloadType {
        if isKind(of: UIWindow.self) {
            return .window
        }
        
        if let responder = next {
            if responder.isKind(of: UIViewController.self) {
                return .controller("\(type(of: responder))")
            }
        }
        
        return .view
    }
    
    var payloadName: String {
        switch payload {
        case .window:
            return "\(type(of: self))"
        case .controller(let name):
            return name
        case .view:
            return "\(type(of: self))"
        }
    }
    
    var payloadIcon: UIImage? {
        switch self.payload {
        case .window:
            return nil
        case .controller(_):
            return UIImage.bundleImage(named: "UIViewController")
        case .view:
            return UIImage.bundleImage(named: "\(type(of: self))") ?? UIImage.bundleImage(named: "UIView")
        }
    }
    
}

extension UIImage {
    
    static func bundleImage(named name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle.init(for: SnapshotView.self), compatibleWith: nil)
    }
    
}

//
//  SceneView.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/3/28.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit
import simd

protocol SceneViewDelgate: class {
    func sceneView(_ view: SceneView, didSelect snapshot: SnapshotView?)
    func sceneView(_ view: SceneView, didFocus snapshot: SnapshotView?)
}

final class SceneView: UIView {
    
    override class var layerClass: AnyClass {
        return CATransformLayer.self
    }
    
    weak var delegate: SceneViewDelgate?
    
    var selectedView: SnapshotView? {
        didSet {
            oldValue?.selected = false
            selectedView?.selected = true
            delegate?.sceneView(self, didSelect: selectedView)
        }
    }
    
    var focusedView: SnapshotView? {
        didSet {
            if let view = focusedView {
                focusedViews = Set(view.recursiveChildren)
                focusedViews.insert(view)
            } else {
                focusedViews.removeAll(keepingCapacity: true)
            }
            updateVisibleLayers()
            delegate?.sceneView(self, didFocus: focusedView)
        }
    }

    private var focusedViews = Set<SnapshotView>()
    
    private(set) var rootSnapshotView: SnapshotView!
    
    init(window: UIWindow) {
        super.init(frame:window.bounds)
        addGestures()
        
        let snapshot = SnapshotView(view: window, root: window)
        rootSnapshotView = snapshot

        var maxLevel = CGFloat.zero
        addSnapshot(snapshot, at: &maxLevel)
        self.maxLevel = maxLevel
        zPosition = -self.maxLevel * layerSpacing * 0.4
        visibleLevelsRange = 0...Int(self.maxLevel)
    }
        
    private func addGestures() {
        let singlePan = UIPanGestureRecognizer(target: self, action: #selector(rotate(_:)))
        singlePan.maximumNumberOfTouches = 1
        addGestureRecognizer(singlePan)

        let doublePan = UIPanGestureRecognizer(target: self, action: #selector(move(_:)))
        doublePan.minimumNumberOfTouches = 2
        addGestureRecognizer(doublePan)
        
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoom(_:))))
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deselect(_:))))
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(loseFocus(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:))))
    }
    
    private(set) var maxLevel = CGFloat.zero
    func addSnapshot(_ snapshot: SnapshotView, at level: inout CGFloat) {
        addSubview(snapshot)
        
        var subviewFrames = [CGRect]()
        var maxLevelSofar = level
        snapshot.level = level
        
        if layersMap.count == Int(level) {
            layersMap.append([snapshot])
        } else {
            layersMap[Int(level)].append(snapshot)
        }
        
        for child in snapshot.chidren {
            var childLevel: CGFloat
            
            if subviewFrames.contains(where: {$0.intersects(child.normalFrame)}) {
                childLevel = maxLevelSofar + 1
            } else {
                childLevel = level + 1
            }
            
            addSnapshot(child, at: &childLevel)
            maxLevelSofar = max(maxLevelSofar, childLevel)
            subviewFrames.append(child.normalFrame)
        }
        level = maxLevelSofar
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var layerSpacing = CGFloat(25.0)
    private(set) var xPosition = CGFloat.zero
    private(set) var yPosition = CGFloat.zero
    private(set) var zPosition = CGFloat.zero
    private(set) var yRotation: CGFloat = .pi / 3
    private(set) var xRotation: CGFloat = -.pi * 0.2
    private(set) var scale = CGFloat(0.6)
    
    /// we use nomal vector (x: 0, y: 0, z: 1) to determine the traversing direction of hit test.
    var normalVector: simd_float4 {
        let vector = simd_float4(0, 0, 1, 1)
        return vector * layer.sublayerTransform
    }
    
    @objc
    private func move(_ gesture: UIPanGestureRecognizer)  {
        if gesture.state == .changed {
            let trans = gesture.translation(in: self)
            xPosition += trans.x
            yPosition += trans.y
            transform()
            gesture.setTranslation(.zero, in: self)
        }
    }
    
    @objc
    private func rotate(_ gesture: UIPanGestureRecognizer)  {
        if gesture.state == .changed {
            let trans = gesture.translation(in: self)
            yRotation += trans.x * 0.01 * .pi
            if yRotation > 2 * .pi {
                yRotation -= 2 * .pi
            } else if yRotation < -2 * .pi {
                yRotation += 2 * .pi
            }
            xRotation -= trans.y * 0.01 * .pi
            transform()
            gesture.setTranslation(.zero, in: self)
        }
    }
        
    @objc
    private func zoom(_ gesture: UIPinchGestureRecognizer)  {
        if gesture.state == .began {
            gesture.scale = scale
        } else if gesture.state == .changed {
            scale = gesture.scale
            transform()
        }
    }
    
    @objc
    private func deselect(_ gestures: UITapGestureRecognizer) {
        if gestures.state == .recognized {
            if selectedView != nil {
                selectedView = nil
            }
        }
    }
    
    @objc
    private func loseFocus(_ gestures: UITapGestureRecognizer) {
        if gestures.state == .recognized {
            if focusedView != nil {
                focusedView = nil
            }
        }
    }
    
    @objc
    private func longPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .recognized {
            
        }
    }
    
    private func transform() {
        updateSceneTransform3D()
        layoutSnapshots()
    }
    
    func update() {
        transform()
    }
    
    private func updateSceneTransform3D() {
        var transform = CATransform3DIdentity
        transform.m34 = -1 / 2000 * scale
        transform = CATransform3DRotate(transform, xRotation, 1, 0, 0)
        let rotate = CATransform3DRotate(transform, yRotation, 0, 1, 0)
        layer.anchorPoint = .init(x: 0.5 - xPosition / bounds.width, y: 0.5 - yPosition / bounds.height)
        layer.sublayerTransform = CATransform3DMakeScale(scale, scale, scale) + rotate + CATransform3DMakeTranslation(xPosition, yPosition, 0)
    }
    
    private func layoutSnapshots() {
        subviews.forEach {
            let snapshot = $0 as! SnapshotView
            snapshot.layer.transform = CATransform3DMakeTranslation(0, 0, zPosition + layerSpacing * snapshot.level)
        }
    }
    
    static let DefaultCameraTransform: CATransform3D = {
        let scale: CGFloat = 0.6
        var transform = CATransform3DIdentity
        transform.m34 = -1 / 2000 * scale
        transform = CATransform3DRotate(transform, -.pi * 0.2, 1, 0, 0)
        let rotate = CATransform3DRotate(transform, .pi / 3, 0, 1, 0)
        return CATransform3DMakeScale(scale, scale, scale) + rotate
    }()
    
    
    func setCamera() {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.sublayerTransform))
        animation.toValue = SceneView.DefaultCameraTransform
        animation.duration = 0.3
        animation.delegate = self
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: nil)
        
        UIView.animate(withDuration: 0.5) {
            self.layoutSnapshots()
        }
    }
    
    func resetCamera(compeletion:  ((Bool) -> Void)? = nil) {
        layer.anchorPoint = .init(x: 0.5, y: 0.5)
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.sublayerTransform))
        animation.toValue = CATransform3DIdentity
        animation.duration = 0.3
        animation.delegate = self
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: nil)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.subviews.forEach { $0.layer.transform = CATransform3DIdentity }
        }, completion: compeletion)
    }
    
    private var layersMap = [[SnapshotView]()]
    var visibleLevelsRange = 0...0 {
        didSet {
            updateVisibleLayers()
        }
    }
    
    private func updateVisibleLayers() {
    
        if let _ = focusedView {
            for (level, snapshots) in layersMap.enumerated() {
                let show = visibleLevelsRange.contains(level)
                snapshots.forEach {
                    $0.isHidden = !show || !focusedViews.contains($0)
                }
            }
        } else {
            for (level, snapshots) in layersMap.enumerated() {
                let show = visibleLevelsRange.contains(level)
                snapshots.forEach {
                    $0.isHidden = !show
                }
            }
        }

    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let visibleLayers = Array(self.layersMap[visibleLevelsRange])
        let layers = normalVector.z > 0 ? visibleLayers.reversed() : visibleLayers
        for layer in layers {
            for snapshot in layer where !snapshot.isHidden {
                let pt = snapshot.convert(point, from: self)
                if snapshot.point(inside: pt, with: event) {
                    return snapshot
                }
            }
        }
        return super.hitTest(point, with: event)
    }
    
}

extension SceneView: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else {
            return
        }
        
        if let camera = anim as? CABasicAnimation {
            if camera.keyPath == #keyPath(CALayer.sublayerTransform) {
                layer.sublayerTransform = camera.toValue as! CATransform3D
                layer.removeAllAnimations()
            }
        }
    }
}

extension CATransform3D {
    
    static func +(_ lhs: CATransform3D, rhs: CATransform3D) -> CATransform3D {
        return CATransform3DConcat(lhs, rhs)
    }
    
    static func *(_ lhs: simd_float4, rhs: CATransform3D) -> simd_float4 {
        return lhs * rhs.matrix
    }
    
    var colum1: simd_float4 {
        return simd_float4([m11,m21,m31,m41].map({Float($0)}))
    }
    
    var colum2: simd_float4 {
        return simd_float4([m12,m22,m32,m42].map({Float($0)}))
    }
    
    var colum3: simd_float4 {
        return simd_float4([m13,m23,m33,m43].map({Float($0)}))
    }
    
    var colum4: simd_float4 {
        return simd_float4([m14,m24,m34,m44].map({Float($0)}))
    }
    
    var matrix: float4x4 {
        return float4x4(columns: (colum1, colum2, colum3, colum4))
    }
    
}

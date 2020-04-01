//
//  RangeSlider.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/3/31.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit

class RangeSliderThumbView: UIView {
    
    enum ThumbType {
        case left
        case right
    }
    
    init(type: ThumbType) {
        super.init(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var touchRect: CGRect {
        return frame.insetBy(dx: -30, dy: -30)
    }
    
}

class RangeSlider: UIView {
    
    private let backgroundSlider = UISlider()
    private let trackSlider = UISlider()
    private let leftThumbView = RangeSliderThumbView(type: .left)
    private let rightThumbView = RangeSliderThumbView(type: .right)
    
    private var minValue = CGFloat.zero

    private var maxValue = CGFloat.zero
    
    var didChange:((ClosedRange<Int>) -> Void)?
    
    private var lowerBound = CGFloat.zero
    private var upperBound = CGFloat.zero
    
    init(range: ClosedRange<Int>) {
        super.init(frame: .zero)
        lowerBound = CGFloat(range.lowerBound)
        upperBound = CGFloat(range.upperBound)
        minValue = lowerBound
        maxValue = upperBound
        
        addSubview(backgroundSlider)
        addSubview(trackSlider)
        backgroundSlider.setThumbImage(UIImage(), for: .normal)
        trackSlider.setThumbImage(UIImage(), for: .normal)
        backgroundSlider.isUserInteractionEnabled = false
        trackSlider.isUserInteractionEnabled = false
        
        addSubview(leftThumbView)
        addSubview(rightThumbView)
        trackSlider.value = trackSlider.maximumValue
        leftThumbView.backgroundColor = .white
        rightThumbView.backgroundColor = .white
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(move(_:))))
    }

    override func layoutSubviews() {
        if movingView == nil {
            backgroundSlider.frame = self.bounds
            
            let leftX = minValue * (bounds.width - 2 * leftThumbView.bounds.width)  / (upperBound - lowerBound)
            leftThumbView.frame.origin.x = leftX
            leftThumbView.center.y = self.bounds.height * 0.5
            
            let righX = maxValue * (bounds.width - 2 * rightThumbView.bounds.width)  / (upperBound - lowerBound) + leftThumbView.bounds.width
            rightThumbView.frame.origin.x = righX
            rightThumbView.center.y = self.bounds.height * 0.5
            
            trackSlider.frame = CGRect(x: leftThumbView.center.x, y: 0, width: rightThumbView.center.x - leftThumbView.center.x, height: bounds.height)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var movingView: UIView?
    
    @objc
    private func move(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        if gesture.state == .began {
            if leftThumbView.touchRect.contains(point) {
                movingView = leftThumbView
            } else if rightThumbView.touchRect.contains(point) {
                movingView = rightThumbView
            }
        } else if gesture.state == .changed {
            if movingView == leftThumbView {
                let x = leftThumbView.center.x + gesture.translation(in: self).x
                leftThumbView.center.x = max(min(x, rightThumbView.center.x - leftThumbView.bounds.width), leftThumbView.bounds.width * 0.5)
                trackSlider.frame = CGRect(x: leftThumbView.center.x, y: 0, width: rightThumbView.center.x - leftThumbView.center.x, height: bounds.height)
                didChangeSliders()
            } else if movingView == rightThumbView {
                let x = rightThumbView.center.x + gesture.translation(in: self).x
                rightThumbView.center.x = min(max(x, leftThumbView.center.x + rightThumbView.bounds.width), self.bounds.width - rightThumbView.bounds.width * 0.5)
                trackSlider.frame = CGRect(x: leftThumbView.center.x, y: 0, width: rightThumbView.center.x - leftThumbView.center.x, height: bounds.height)
                didChangeSliders()
            }
            gesture.setTranslation(.zero, in: self)
        } else if gesture.state == .ended {
            movingView = nil
        }
    }
    
    private func didChangeSliders() {
        minValue = leftThumbView.frame.origin.x / (bounds.width - 2 * leftThumbView.bounds.width)  * (upperBound - lowerBound)
        maxValue = (rightThumbView.frame.origin.x - leftThumbView.bounds.width) / (bounds.width - 2 * rightThumbView.bounds.width)  * (upperBound - lowerBound)
        didChange?(Int(minValue)...Int(maxValue))
    }

}


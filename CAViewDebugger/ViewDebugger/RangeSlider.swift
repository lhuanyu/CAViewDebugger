//
//  RangeSlider.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/3/31.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit


class RangeSlider: UIView {
    
    let leftSlider = UISlider()
    let rightSlider = UISlider()
    
    var didChange:((ClosedRange<Int>) -> Void)?
    
    init(range: ClosedRange<Int>) {
        super.init(frame: .zero)
        addSubview(leftSlider)
        addSubview(rightSlider)
        leftSlider.minimumValue = Float(range.lowerBound)
        leftSlider.maximumValue = Float(range.upperBound)
        rightSlider.minimumValue = Float(range.lowerBound)
        rightSlider.maximumValue = Float(range.upperBound)
        leftSlider.value = leftSlider.minimumValue
        rightSlider.value = rightSlider.maximumValue
        leftSlider.addTarget(self, action: #selector(leftDidChange(_:)), for: .valueChanged)
        rightSlider.addTarget(self, action: #selector(rightDidChange(_:)), for: .valueChanged)
    }
    
    override func layoutSubviews() {
        let frame = bounds.divided(atDistance: bounds.height * 0.5, from: .minYEdge)
        rightSlider.frame = frame.slice
        leftSlider.frame = frame.remainder
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc
    func leftDidChange(_ sender: UISlider) {
        sender.setValue(min(sender.value, rightSlider.value), animated: false)
        didChangeSliders()
    }
    
    @objc
    func rightDidChange(_ sender: UISlider) {
        sender.setValue(max(leftSlider.value, sender.value), animated: false)
        didChangeSliders()
    }
    
    private func didChangeSliders() {
        didChange?(Int(leftSlider.value)...Int(rightSlider.value))
    }

}


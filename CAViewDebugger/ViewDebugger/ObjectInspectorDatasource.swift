//
//  ObjectInspectorDatasource.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/4/9.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit

enum ObjectInspectorSection: String, CaseIterable, CustomStringConvertible {
    case object
    case view
    case drawing
//    case stretching
//    case traitCollection = "Trait Collection"
//    case accessibility
    case description
    case hierarchy
    
    var description: String {
        return rawValue.uppercased()
    }
    
    enum ViewProperty: Int, CaseIterable {
        case layer = 0, layerClass, contentMode, tag, userInteraction, multiTouch, alpha, backgroundColor, tintColor
    }
    
    var rows: [String] {
        switch self {
        case .object:
            return ["Class Name", "Address"]
        case .view:
            return ["Layer", "Layer Class", "Content Mode", "Tag", "User Interaction Enabled", "Multiple Touch", "Alpha", "Background", "Tint"]
        case .drawing:
            return ["Opaque", "Hidden", "Clear Graphic Context", "Clip To Bounds", "Autoresizing Subviews"]
//        case .stretching:
//            return []
//        case .traitCollection:
//            return []
//        case .accessibility:
//            return []
        case .description:
            return ["Description"]
        case .hierarchy:
            return ["Class"]
        }
    }
    
}


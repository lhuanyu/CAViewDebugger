//
//  Configuration.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/4/7.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import Foundation

public struct Configuration: Equatable {
    
    enum ViewMode: Int, CaseIterable, CustomStringConvertible {
        case content = 0
        case wireframe
        case all

        var description: String {
            switch self {
            case .content:
                return "Contents Only"
            case .wireframe:
                return "Wireframes Only"
            case .all:
                return "Wireframes and Contents"
            }
        }
    }
    
    var viewMode: ViewMode = .all
    var showClippedContent = false
    var showViewLabel = true

    
}

//
//  PumpRegion.swift
//  RileyLink
//
//  Created by Pete Schwamb on 9/8/16.
//  Copyright © 2016 LoopKit Authors. All rights reserved.
//

import Foundation

public enum PumpRegion: Int, CustomStringConvertible  {
    case northAmerica = 0
    case worldWide
    case canada
    
    public var description: String {
        switch self {
        case .worldWide:
            return LocalizedString("全世界", comment: "Describing the worldwide pump region")
        case .northAmerica:
            return LocalizedString("北美", comment: "Describing the North America pump region")
        case .canada:
            return LocalizedString("加拿大", comment: "Describing the Canada pump region ")
        }
    }
}

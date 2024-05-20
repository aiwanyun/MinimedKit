//
//  PumpErrorMessageBody.swift
//  RileyLink
//
//  Created by Pete Schwamb on 5/10/17.
//  Copyright © 2017 LoopKit Authors. All rights reserved.
//

import Foundation

public enum PumpErrorCode: UInt8, CustomStringConvertible {
    // commandRefused can happen when temp basal type is set incorrectly, during suspended pump, or unfinished prime.
    case commandRefused      = 0x08
    case maxSettingExceeded  = 0x09
    case bolusInProgress     = 0x0c
    case pageDoesNotExist    = 0x0d
    
    public var description: String {
        switch self {
        case .commandRefused:
            return LocalizedString("命令拒绝", comment: "Pump error code returned when command refused")
        case .maxSettingExceeded:
            return LocalizedString("最大设置超出了", comment: "Pump error code describing max setting exceeded")
        case .bolusInProgress:
            return LocalizedString("推注正在进行", comment: "Pump error code when bolus is in progress")
        case .pageDoesNotExist:
            return LocalizedString("历史页面不存在", comment: "Pump error code when invalid history page is requested")
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .commandRefused:
            return LocalizedString("检查泵是否没有悬挂或启动，或具有临时基础率百分比", comment: "Suggestions for diagnosing a command refused pump error")
        default:
            return nil
        }
    }
}

public class PumpErrorMessageBody: DecodableMessageBody {
    public static let length = 1
    
    let rxData: Data
    public let errorCode: PartialDecode<PumpErrorCode, UInt8>
    
    public required init?(rxData: Data) {
        self.rxData = rxData
        let rawErrorCode = rxData[0]
        if let errorCode = PumpErrorCode(rawValue: rawErrorCode) {
            self.errorCode = .known(errorCode)
        } else {
            self.errorCode = .unknown(rawErrorCode)
        }
    }
    
    public var txData: Data {
        return rxData
    }

    public var description: String {
        return "PumpError(\(errorCode))"
    }
}

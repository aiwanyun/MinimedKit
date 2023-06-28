//
//  MinimedPumpManagerError.swift
//  Loop
//
//  Copyright © 2018 LoopKit Authors. All rights reserved.
//

import Foundation

public enum MinimedPumpManagerError: Error {
    case noRileyLink
    case bolusInProgress
    case pumpSuspended
    case insulinTypeNotConfigured
    case noDate  // TODO: This is less of an error and more of a precondition/assertion state
    case tuneFailed(LocalizedError)
    case commsError(LocalizedError)
    case storageFailure
}


extension MinimedPumpManagerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noRileyLink:
            return LocalizedString("无赖赖氏链接连接", comment: "Error description when no rileylink connected")
        case .bolusInProgress:
            return LocalizedString("推注正在进行", comment: "Error description when failure due to bolus in progress")
        case .pumpSuspended:
            return LocalizedString("泵被悬挂", comment: "Error description when failure due to pump suspended")
        case .insulinTypeNotConfigured:
            return LocalizedString("胰岛素类型未配置", comment: "Error description for MinimedPumpManagerError.insulinTypeNotConfigured")
        case .noDate:
            return nil
        case .tuneFailed(let error):
            return [LocalizedString("Rileylink无线电曲失败", comment: "Error description for tune failure"), error.errorDescription].compactMap({ $0 }).joined(separator: ": ")
        case .commsError(let error):
            return error.errorDescription
        case .storageFailure:
            return LocalizedString("无法存储泵数据", comment: "Error description when storage fails")
        }
    }

    public var failureReason: String? {
        switch self {
        case .tuneFailed(let error):
            return error.failureReason
        default:
            return nil
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .noRileyLink:
            return LocalizedString("确保您的Rileylink在附近并加油", comment: "Recovery suggestion")
        case .insulinTypeNotConfigured:
            return LocalizedString("转到泵设置并选择胰岛素类型", comment: "Recovery suggestion for MinimedPumpManagerError.insulinTypeNotConfigured")
        case .tuneFailed(let error):
            return error.recoverySuggestion
        default:
            return nil
        }
    }
}

//
//  RadioSelectionTableViewController.swift
//  Loop
//
//  Created by Nate Racklyeft on 8/26/16.
//  Copyright © 2016 Nathan Racklyeft. All rights reserved.
//

import UIKit
import LoopKitUI
import MinimedKit


extension RadioSelectionTableViewController: IdentifiableClass {
    typealias T = RadioSelectionTableViewController

    static func insulinDataSource(_ value: InsulinDataSource) -> T {
        let vc = T()

        vc.selectedIndex = value.rawValue
        vc.options = (0..<2).compactMap({ InsulinDataSource(rawValue: $0) }).map { String(describing: $0) }
        vc.contextHelp = LocalizedString("可以通过解释事件历史记录或随着时间的推移比较储层体积来确定胰岛素输送。阅读事件历史记录可提供更准确的状态图，并将最新的治疗数据上传到NightScout，以更快的泵电池排水速度，并且与仅阅读储层量相比，无线电错误率更高。如果由于任何原因无法使用所选源，则系统将尝试归还其他选项。", comment: "Instructions on selecting an insulin data source")

        return vc
    }

    static func batteryChemistryType(_ value: MinimedKit.BatteryChemistryType) -> T {
        let vc = T()

        vc.selectedIndex = value.rawValue
        vc.options = (0..<2).compactMap({ BatteryChemistryType(rawValue: $0) }).map { String(describing: $0) }
        vc.contextHelp = LocalizedString("碱性和锂电池以不同的速度衰减。随着时间的推移，碱性电压往往会降低线性电压，而锂电池电池往往会保持电压直到其寿命中途。在非摩sentry兼容的最小化（X22/X15）胰岛素泵运行环的正常使用下，碱性电池持续约4至5天。锂电池持续1-2周。此选择将对每种电池化学类型的各种电池电压衰减率使用不同，并在电池故障大约8至10小时时提醒用户。", comment: "Instructions on selecting battery chemistry type")

        return vc
    }

    static func useMySentry(_ value: Bool) -> T {
        let vc = T()

        vc.selectedIndex = value ? 0 : 1
            
        vc.options = ["Use MySentry", "Do not use MySentry"]
        vc.contextHelp = LocalizedString("Medtronic Pump型号523、723、554和754具有称为“ Mysentry”的功能，该功能会定期广播储层和泵电池水平。聆听这些广播可以使闭环与泵通信的频率较低，从而可以增加泵电池寿命。但是，当使用此功能时，Rileylink会在更多的时间内保持清醒，并使用更多自己的电池。实现此功能可能会延长泵电池的寿命，同时禁用电池可能会延长Rileylink电池寿命。对于其他泵模型，忽略了此设置。", comment: "Instructions on selecting setting for MySentry")

        return vc
    }
}

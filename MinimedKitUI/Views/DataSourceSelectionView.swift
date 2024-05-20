//
//  DataSourceSelectionView.swift
//  MinimedKitUI
//
//  Created by Pete Schwamb on 11/30/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import SwiftUI
import MinimedKit
import LoopKitUI

struct DataSourceSelectionView: View {

    @Binding var batteryType: InsulinDataSource

    var body: some View {
        VStack {
            List {
                Picker("Preferred Data Source", selection: $batteryType) {
                    ForEach(InsulinDataSource.allCases, id: \.self) { dataSource in
                        Text(dataSource.description)
                    }
                }
                .pickerStyle(.inline)
                Section(content: {
                }, footer: {
                    Text(LocalizedString("可以通过解释事件历史记录或随着时间的推移比较储层体积来确定胰岛素输送。阅读事件历史记录可提供更准确的状态图，并将最新的治疗数据上传到NightScout，以更快的泵电池排水速度，并且与仅阅读储层量相比，无线电误差率更高。如果由于任何原因无法使用所选源，则系统将尝试归还其他选项。", comment: "Instructions on selecting an insulin data source"))
                })
            }
        }
        .insetGroupedListStyle()
        .navigationTitle(LocalizedString("首选数据源", comment: "navigation title for pump battery type selection"))
    }
}

//
//  UseMySentrySelectionView.swift
//  MinimedKitUI
//
//  Created by Pete Schwamb on 11/30/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import SwiftUI
import MinimedKit
import LoopKitUI

struct UseMySentrySelectionView: View {

    @Binding var mySentryConfig: MySentryConfig

    var body: some View {
        VStack {
            List {
                Picker("Use MySentry", selection: $mySentryConfig) {
                    ForEach(MySentryConfig.allCases, id: \.self) { config in
                        Text(config.localizedDescription)
                    }
                }
                .pickerStyle(.inline)
                Section(content: {}, footer: {
                    Text(LocalizedString("Medtronic Pump型号523、723、554和754具有名为“ Mysentry”的功能，该功能会定期广播储层和泵电池水平。聆听这些广播可以使闭环与泵通信的频率较低，从而可以增加泵电池寿命。但是，当使用此功能时，Rileylink会在更多的时间内保持清醒，并使用更多自己的电池。实现此功能可能会延长泵电池的寿命，同时禁用电池可能会延长Rileylink电池寿命。对于其他泵模型，忽略了此设置。", comment: "Instructions on selecting setting for MySentry"))
                })
            }
        }
        .insetGroupedListStyle()
        .navigationTitle(LocalizedString("使用Mysentry", comment: "navigation title for pump battery type selection"))
    }
}

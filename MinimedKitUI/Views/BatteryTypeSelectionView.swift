//
//  BatteryTypeSelectionView.swift
//  MinimedKitUI
//
//  Created by Pete Schwamb on 11/30/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import SwiftUI
import MinimedKit
import LoopKitUI

struct BatteryTypeSelectionView: View {

    @Binding var batteryType: BatteryChemistryType

    var body: some View {
        VStack {
            List {
                Section {
                    Text(LocalizedString("选择您在泵中使用的电池类型，以更好地警告低电池状况。", comment: "Instructions on selecting battery chemistry type"))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 10)
                }
                Picker("Battery Chemistry", selection: $batteryType) {
                    ForEach(BatteryChemistryType.allCases, id: \.self) { batteryType in
                        Text(batteryType.description)
                    }
                }
                .pickerStyle(.inline)
            }
        }
        .insetGroupedListStyle()
        .navigationTitle(LocalizedString("泵电池类型", comment: "navigation title for pump battery type selection"))
    }
}

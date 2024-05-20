//
//  MinimedPumpSettingsView.swift
//  MinimedKitUI
//
//  Created by Pete Schwamb on 11/29/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import Foundation
import SwiftUI
import LoopKitUI
import LoopKit
import RileyLinkKit
import RileyLinkBLEKit

struct MinimedPumpSettingsView: View {

    @Environment(\.guidanceColors) private var guidanceColors
    @Environment(\.insulinTintColor) var insulinTintColor

    @ObservedObject var viewModel: MinimedPumpSettingsViewModel
    @ObservedObject var rileyLinkListDataSource: RileyLinkListDataSource

    var supportedInsulinTypes: [InsulinType]

    @State private var showingDeletionSheet = false

    @State private var showSyncTimeOptions = false;

    var handleRileyLinkSelection: (RileyLinkDevice) -> Void

    init(viewModel: MinimedPumpSettingsViewModel, supportedInsulinTypes: [InsulinType], handleRileyLinkSelection: @escaping (RileyLinkDevice) -> Void, rileyLinkListDataSource: RileyLinkListDataSource) {
        self.viewModel = viewModel
        self.supportedInsulinTypes = supportedInsulinTypes
        self.handleRileyLinkSelection = handleRileyLinkSelection
        self.rileyLinkListDataSource = rileyLinkListDataSource
    }

    var body: some View {
        List {
            Section {
                headerImage
                    .padding(.vertical)
                HStack(alignment: .top) {
                    deliveryStatus
                    Spacer()
                    reservoirStatus
                }
                .padding(.bottom, 5)

            }

            if let basalDeliveryState = viewModel.basalDeliveryState {
                Section {
                    HStack {
                        Button(basalDeliveryState.buttonLabelText) {
                            viewModel.suspendResumeButtonPressed(action: basalDeliveryState.shownAction)
                        }.disabled(viewModel.suspendResumeButtonEnabled)
                        if viewModel.suspendResumeButtonEnabled {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }

            Section(header: SectionHeader(label: LocalizedString("配置", comment: "The title of the configuration section in MinimedPumpManager settings")))
            {
                NavigationLink(destination: InsulinTypeSetting(initialValue: viewModel.pumpManager.state.insulinType, supportedInsulinTypes: supportedInsulinTypes, allowUnsetInsulinType: false, didChange: viewModel.didChangeInsulinType)) {
                    HStack {
                        Text(LocalizedString("胰岛素类型", comment: "Text for confidence reminders navigation link")).foregroundColor(Color.primary)
                        if let currentTitle = viewModel.pumpManager.state.insulinType?.brandName {
                            Spacer()
                            Text(currentTitle)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                NavigationLink(destination: BatteryTypeSelectionView(batteryType: $viewModel.batteryChemistryType)) {
                    HStack {
                        Text(LocalizedString("泵电池类型", comment: "Text for medtronic pump battery type")).foregroundColor(Color.primary)
                        Spacer()
                        Text(viewModel.batteryChemistryType.description)
                            .foregroundColor(.secondary)
                    }
                }

                NavigationLink(destination: DataSourceSelectionView(batteryType: $viewModel.preferredDataSource)) {
                    HStack {
                        Text(LocalizedString("首选数据源", comment: "Text for medtronic pump preferred data source")).foregroundColor(Color.primary)
                        Spacer()
                        Text(viewModel.preferredDataSource.description)
                            .foregroundColor(.secondary)
                    }
                }

                if viewModel.pumpManager.state.pumpModel.hasMySentry {
                    NavigationLink(destination: UseMySentrySelectionView(mySentryConfig: $viewModel.mySentryConfig)) {
                        HStack {
                            Text(LocalizedString("使用Mysentry", comment: "Text for medtronic pump to use MySentry")).foregroundColor(Color.primary)
                            Spacer()
                            Text((viewModel.mySentryConfig == .useMySentry ?
                                  LocalizedString("是的", comment: "Value string for MySentry config when MySentry is being used") :
                                    LocalizedString("不", comment: "Value string for MySentry config when MySentry is not being used"))
                            )
                            .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Section(header: HStack {
                Text(LocalizedString("设备", comment: "Header for devices section of RileyLinkSetupView"))
                Spacer()
                ProgressView()
            }) {
                ForEach(rileyLinkListDataSource.devices, id: \.peripheralIdentifier) { device in
                    Toggle(isOn: rileyLinkListDataSource.autoconnectBinding(for: device)) {
                        HStack {
                            Text(device.name ?? "Unknown")
                            Spacer()

                            if rileyLinkListDataSource.autoconnectBinding(for: device).wrappedValue {
                                if device.isConnected {
                                    Text(formatRSSI(rssi:device.rssi)).foregroundColor(.secondary)
                                } else {
                                    Image(systemName: "wifi.exclamationmark")
                                        .imageScale(.large)
                                        .foregroundColor(guidanceColors.warning)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleRileyLinkSelection(device)
                        }
                    }
                }
            }
            .onAppear {
                rileyLinkListDataSource.isScanningEnabled = true
            }
            .onDisappear {
                rileyLinkListDataSource.isScanningEnabled = false
            }


            Section() {
                HStack {
                    Text(LocalizedString("泵电池剩余", comment: "Text for medtronic pump battery percent remaining")).foregroundColor(Color.primary)
                    Spacer()
                    if let chargeRemaining = viewModel.pumpManager.status.pumpBatteryChargeRemaining {
                        Text(String("\(Int(round(chargeRemaining * 100)))%"))
                    } else {
                        Text(String(LocalizedString("未知", comment: "Text to indicate battery percentage is unknown")))
                    }
                }
                HStack {
                    Text(LocalizedString("泵送时间", comment: "The title of the command to change pump time zone"))
                    Spacer()
                    if viewModel.isClockOffset {
                        Image(systemName: "clock.fill")
                            .foregroundColor(guidanceColors.warning)
                    }
                    TimeView(timeZone: viewModel.pumpManager.status.timeZone)
                        .foregroundColor( viewModel.isClockOffset ? guidanceColors.warning : nil)
                }
                if viewModel.synchronizingTime {
                    HStack {
                        Text(LocalizedString("调整泵的时间...", comment: "Text indicating ongoing pump time synchronization"))
                            .foregroundColor(.secondary)
                        Spacer()
                        ActivityIndicator(isAnimating: .constant(true), style: .medium)
                    }
                } else if self.viewModel.pumpManager.status.timeZone != TimeZone.currentFixed {
                    Button(action: {
                        showSyncTimeOptions = true
                    }) {
                        Text(LocalizedString("同步到当前时间", comment: "The title of the command to change pump time zone"))
                    }
                    .actionSheet(isPresented: $showSyncTimeOptions) {
                        syncPumpTimeActionSheet
                    }
                }
            }


            Section {
                LabeledValueView(label: LocalizedString("泵ID", comment: "The title text for the pump ID config value"),
                                 value: viewModel.pumpManager.state.pumpID)
                LabeledValueView(label: LocalizedString("固件版本", comment: "The title of the cell showing the pump firmware version"),
                                 value: String(describing: viewModel.pumpManager.state.pumpFirmwareVersion))
                LabeledValueView(label: LocalizedString("地区", comment: "The title of the cell showing the pump region"),
                                 value: String(describing: viewModel.pumpManager.state.pumpRegion))
            }


            Section() {
                deletePumpButton
            }

        }
        .alert(item: $viewModel.activeAlert, content: { alert in
            switch alert {
            case .suspendError(let error):
                return Alert(title: Text(LocalizedString("暂停错误", comment: "The alert title for a suspend error")),
                             message: Text(errorText(error)))
             case .resumeError(let error):
                return Alert(title: Text(LocalizedString("恢复错误", comment: "The alert title for a resume error")),
                             message: Text(errorText(error)))
            case .syncTimeError(let error):
                return Alert(title: Text(LocalizedString("错误同步时间", comment: "The alert title for an error while synching time")),
                             message: Text(errorText(error)))
            }
        })

        .insetGroupedListStyle()
        .navigationBarItems(trailing: doneButton)
        .navigationBarTitle(String(format: LocalizedString("Medtronic %1$@", comment: "Format string fof navigation bar title for MinimedPumpSettingsView (1: model number)"), viewModel.pumpManager.state.pumpModel.description))
    }

    var deliverySectionTitle: String {
        if self.viewModel.isScheduledBasal {
            return LocalizedString("计划的基础", comment: "Title of insulin delivery section")
        } else {
            return LocalizedString("胰岛素输送", comment: "Title of insulin delivery section")
        }
    }

    var deliveryStatus: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(deliverySectionTitle)
                .foregroundColor(Color(UIColor.secondaryLabel))
            if viewModel.isSuspendedOrResuming {
                HStack(alignment: .center) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 34))
                        .fixedSize()
                        .foregroundColor(viewModel.suspendResumeButtonColor(guidanceColors: guidanceColors))
                    Text(LocalizedString("Insulin\nSuspended", comment: "Text shown in insulin delivery space when insulin suspended"))
                        .fontWeight(.bold)
                        .fixedSize()
                }
            } else if let basalRate = self.viewModel.basalDeliveryRate {
                HStack(alignment: .center) {
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(viewModel.basalRateFormatter.string(from: basalRate) ?? "")
                            .font(.system(size: 28))
                            .fontWeight(.heavy)
                            .fixedSize()
                        Text(LocalizedString("U/hr", comment: "Units for showing temp basal rate"))
                            .foregroundColor(.secondary)
                    }
                }
            } else if viewModel.basalDeliveryState?.isTransitioning == true {
                HStack(alignment: .center) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 34))
                        .fixedSize()
                        .foregroundColor(.secondary)
                    Text(LocalizedString("更改", comment: "Text shown in basal rate space when basal is changing"))
                        .fontWeight(.bold)
                        .fixedSize()
                        .foregroundColor(.secondary)
                }
            } else {
                HStack(alignment: .center) {
                    Image(systemName: "x.circle.fill")
                        .font(.system(size: 34))
                        .fixedSize()
                        .foregroundColor(guidanceColors.warning)
                    Text(LocalizedString("未知", comment: "Text shown in basal rate space when delivery status is unknown"))
                        .fontWeight(.bold)
                        .fixedSize()
                }
            }
        }
    }

    func reservoirColor(for reservoirLevelHighlightState: ReservoirLevelHighlightState) -> Color {
        switch reservoirLevelHighlightState {
        case .normal:
            return insulinTintColor
        case .warning:
            return guidanceColors.warning
        case .critical:
            return guidanceColors.critical
        }
    }

    var reservoirStatus: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(LocalizedString("胰岛素剩余", comment: "Header for insulin remaining on pod settings screen"))
                .foregroundColor(Color(UIColor.secondaryLabel))
            if let reservoirReading = viewModel.reservoirReading,
               let reservoirLevelHighlightState = viewModel.reservoirLevelHighlightState,
               let reservoirPercent = viewModel.reservoirPercentage
            {
                HStack {
                    MinimedReservoirView(filledPercent: reservoirPercent, fillColor: reservoirColor(for: reservoirLevelHighlightState))
                        .frame(width: 23, height: 32)
                    Text(viewModel.reservoirText(for: reservoirReading.units))
                        .font(.system(size: 28))
                        .fontWeight(.heavy)
                        .fixedSize()
                }
            }
        }
    }

    var syncPumpTimeActionSheet: ActionSheet {
        ActionSheet(
            title: Text(LocalizedString("时间变化检测到", comment: "Title for pod sync time action sheet.")),
            message: Text(LocalizedString("泵上的时间与当前时间不同。您想将泵上的时间更新到当前时间吗？", comment: "Message for pod sync time action sheet")),
            buttons: [
                .default(Text(LocalizedString("是的，与当前时间同步", comment: "Button text to confirm pump time sync"))) {
                    self.viewModel.changeTimeZoneTapped()
                },
                .cancel(Text(LocalizedString("不，保持泵原样", comment: "Button text to cancel pump time sync")))
            ]
        )
    }

    private func errorText(_ error: Error) -> String {
        if let error = error as? LocalizedError {
            return [error.localizedDescription, error.recoverySuggestion].compactMap{$0}.joined(separator: ". ")
        } else {
            return error.localizedDescription
        }
    }

    var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()

        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        return formatter
    }()

    private func formatRSSI(rssi: Int?) -> String {
        if let rssi = rssi, let rssiStr = decimalFormatter.decibleString(from: rssi) {
            return rssiStr
        } else {
            return ""
        }
    }

    private var deletePumpButton: some View {
        Button(action: {
            showingDeletionSheet = true
        }, label: {
            Text(LocalizedString("删除泵", comment: "Button label for removing Pump"))
                .foregroundColor(.red)
        }).actionSheet(isPresented: $showingDeletionSheet) {
            ActionSheet(
                title: Text(LocalizedString("您确定要删除此泵吗？", comment: "Text to confirm delete this pump")),
                buttons: [
                    .destructive(Text(LocalizedString("删除泵", comment: "Text to delete pump"))) {
                        viewModel.deletePump()
                    },
                    .cancel(),
                ]
            )
        }
    }

    private var headerImage: some View {
        VStack(alignment: .center) {
            Image(uiImage: viewModel.pumpImage)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(height: 150)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    private var doneButton: some View {
        Button("Done", action: {
            viewModel.doneButtonPressed()
        })
    }

}

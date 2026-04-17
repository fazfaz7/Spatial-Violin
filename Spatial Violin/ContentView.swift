//
//  ContentView.swift
//  Spatial Violin
//
//  Created by Adrian Emmanuel Faz Mercado on 14/04/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(AppModel.self) var appModel
    @State private var isPlaying = false

    var body: some View {
        @Bindable var appModel = appModel

        ScrollView {
            VStack(spacing: 28) {
                Text("Spatial Violin")
                    .font(.extraLargeTitle)
                    .fontWeight(.bold)

                Button(isPlaying ? "Stop" : "Start Playing") {
                    Task {
                        if isPlaying {
                            await dismissImmersiveSpace()
                        } else {
                            await openImmersiveSpace(id: "ViolinSpace")
                        }
                        isPlaying.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Divider()

                // MARK: Violin controls
                VStack(spacing: 16) {
                    sectionHeader("Violin")

                    sliderRow("Scale",      value: $appModel.violinScale, in: 0.001...0.5,  format: "%.4f")
                    sliderRow("Arm offset", value: $appModel.armOffset,   in: 0.01...0.6,   format: "%.2f m")
                    sliderRow("Y offset",   value: $appModel.yOffset,     in: -0.3...0.3,   format: "%.2f m")

                    sectionHeader("Violin rotation (degrees)")

                    sliderRow("Rotate X", value: $appModel.rotationX, in: -180...180, format: "%.0f°")
                    sliderRow("Rotate Y", value: $appModel.rotationY, in: -180...180, format: "%.0f°")
                    sliderRow("Rotate Z", value: $appModel.rotationZ, in: -180...180, format: "%.0f°")
                }
                .padding(.horizontal, 8)

                Divider()

                // MARK: Bow controls
                VStack(spacing: 16) {
                    sectionHeader("Bow")

                    sliderRow("Scale", value: $appModel.bowScale, in: 0.001...0.5, format: "%.4f")
                    sliderRow("Arm offset", value: $appModel.bowArmOffset,  in: 0.01...0.6, format: "%.2f m")
                    sliderRow("Y offset",   value: $appModel.bowYOffset,    in: -0.3...0.3, format: "%.2f m")

                    sectionHeader("Bow rotation (degrees)")

                    sliderRow("Rotate X", value: $appModel.bowRotationX, in: -180...180, format: "%.0f°")
                    sliderRow("Rotate Y", value: $appModel.bowRotationY, in: -180...180, format: "%.0f°")
                    sliderRow("Rotate Z", value: $appModel.bowRotationZ, in: -180...180, format: "%.0f°")

                    sectionHeader("Bow pivot correction (local space)")

                    sliderRow("Pivot X", value: $appModel.bowPivotX, in: -0.5...0.5, format: "%.3f m")
                    sliderRow("Pivot Y", value: $appModel.bowPivotY, in: -0.5...0.5, format: "%.3f m")
                    sliderRow("Pivot Z", value: $appModel.bowPivotZ, in: -0.5...0.5, format: "%.3f m")
                }
                .padding(.horizontal, 8)

                Divider()

                // MARK: Visibility
                HStack(spacing: 12) {
                    Button(action: { appModel.violinVisible.toggle() }) {
                        Label(appModel.violinVisible ? "Hide Violin" : "Show Violin",
                              systemImage: appModel.violinVisible ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.bordered)

                    Button(action: { appModel.bowVisible.toggle() }) {
                        Label(appModel.bowVisible ? "Hide Bow" : "Show Bow",
                              systemImage: appModel.bowVisible ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom, 16)
            }
            .padding(32)
        }
        .frame(minWidth: 360)
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func sliderRow(_ label: String, value: Binding<Float>, in range: ClosedRange<Float>, format: String) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: value, in: range)
        }
    }
}

#Preview {
    ContentView()
}

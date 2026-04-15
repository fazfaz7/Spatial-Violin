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

            VStack(spacing: 16) {
                sliderRow("Scale", value: $appModel.violinScale, in: 0.001...0.5, format: "%.4f")
                sliderRow("Arm offset", value: $appModel.armOffset, in: 0.05...0.6, format: "%.2f m")

                Divider()

                Text("Rotation correction (degrees)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                sliderRow("Rotate X", value: $appModel.rotationX, in: -180...180, format: "%.0f°")
                sliderRow("Rotate Y", value: $appModel.rotationY, in: -180...180, format: "%.0f°")
                sliderRow("Rotate Z", value: $appModel.rotationZ, in: -180...180, format: "%.0f°")
            }
            .padding(.horizontal, 8)
        }
        .padding(32)
        .frame(minWidth: 360)
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

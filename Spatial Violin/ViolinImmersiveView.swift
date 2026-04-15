//
//  ViolinImmersiveView.swift
//  Spatial Violin
//

import SwiftUI
import RealityKit
import ARKit
import simd

struct ViolinImmersiveView: View {
    @Environment(AppModel.self) var appModel
    @State private var violinEntity: Entity?
    @State private var debugStatus: String = "Starting..."

    var body: some View {
        RealityView { content in
            do {
                let violin = try await Entity(named: "violin", in: Bundle.main)
                violin.scale = SIMD3<Float>(repeating: appModel.violinScale)
                violin.isEnabled = false
                content.add(violin)
                violinEntity = violin
            } catch {
                // Fallback to placeholder box if model fails to load
                let violin = makePlaceholderViolin()
                violin.isEnabled = false
                content.add(violin)
                violinEntity = violin
                debugStatus = "Model load failed: \(error.localizedDescription)"
            }
        }
        .task {
            await startHandTracking()
        }
        .overlay(alignment: .top) {
            Text(debugStatus)
                .padding()
                .background(.black.opacity(0.6))
                .foregroundStyle(.white)
                .cornerRadius(10)
                .padding(.top, 40)
        }
    }

    // MARK: - Placeholder model
    // Fallback if USDZ fails to load.
    private func makePlaceholderViolin() -> ModelEntity {
        let mesh = MeshResource.generateBox(width: 0.12, height: 0.03, depth: 0.40, cornerRadius: 0.01)
        var material = SimpleMaterial()
        material.color = .init(tint: .brown)
        material.roughness = .init(floatLiteral: 0.8)
        return ModelEntity(mesh: mesh, materials: [material])
    }

    // MARK: - Hand Tracking

    private func startHandTracking() async {
        guard HandTrackingProvider.isSupported else {
            debugStatus = "Error: Hand tracking not supported"
            return
        }

        let session = ARKitSession()
        let provider = HandTrackingProvider()

        do {
            debugStatus = "Requesting hand tracking..."
            try await session.run([provider])
            debugStatus = "Hand tracking active — raise your left arm"
            for await update in provider.anchorUpdates {
                let anchor = update.anchor
                guard anchor.chirality == .left, anchor.isTracked else { continue }
                debugStatus = "Left hand detected"
                placeViolin(on: anchor)
            }
        } catch {
            debugStatus = "Error: \(error.localizedDescription)"
        }
    }

    // MARK: - Violin Placement

    private func placeViolin(on anchor: HandAnchor) {
        guard let violin = violinEntity,
              let skeleton = anchor.handSkeleton else { return }

        violin.isEnabled = true

        // Get world-space transforms for key joints
        let wristWorld  = anchor.originFromAnchorTransform * skeleton.joint(.wrist).anchorFromJointTransform
        let middleWorld = anchor.originFromAnchorTransform * skeleton.joint(.middleFingerMetacarpal).anchorFromJointTransform

        let wristPos  = simd_float3(wristWorld.columns.3.x,  wristWorld.columns.3.y,  wristWorld.columns.3.z)
        let middlePos = simd_float3(middleWorld.columns.3.x, middleWorld.columns.3.y, middleWorld.columns.3.z)

        // Forearm direction = from fingers toward elbow
        let forearmDir = normalize(wristPos - middlePos)

        // Wrist Y axis approximates the palm-facing direction
        let palmUp = normalize(simd_float3(wristWorld.columns.1.x, wristWorld.columns.1.y, wristWorld.columns.1.z))

        // Place violin center up the arm from the wrist
        let violinCenter = wristPos + forearmDir * appModel.armOffset

        // Build orthogonal basis aligned to the forearm
        let zAxis = forearmDir
        let xAxis = normalize(cross(palmUp, zAxis))
        let yAxis = cross(zAxis, xAxis)

        // Compose rotation from forearm alignment
        let rotMatrix = simd_float3x3(xAxis, yAxis, zAxis)
        let baseRotation = simd_quatf(rotMatrix)

        // Apply per-axis correction from sliders (in degrees)
        let deg: Float = .pi / 180
        let corrX = simd_quatf(angle: appModel.rotationX * deg, axis: SIMD3<Float>(1, 0, 0))
        let corrY = simd_quatf(angle: appModel.rotationY * deg, axis: SIMD3<Float>(0, 1, 0))
        let corrZ = simd_quatf(angle: appModel.rotationZ * deg, axis: SIMD3<Float>(0, 0, 1))
        let finalRotation = baseRotation * corrX * corrY * corrZ

        violin.transform = Transform(
            scale:       SIMD3<Float>(repeating: appModel.violinScale),
            rotation:    finalRotation,
            translation: violinCenter
        )
    }
}

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
    @State private var bowEntity: Entity?
    @State private var debugStatus: String = "Starting..."

    var body: some View {
        RealityView { content in
            // Load violin
            do {
                let violin = try await Entity(named: "violin", in: Bundle.main)
                violin.isEnabled = false
                content.add(violin)
                violinEntity = violin
            } catch {
                let violin = makePlaceholderViolin()
                violin.isEnabled = false
                content.add(violin)
                violinEntity = violin
                debugStatus = "Violin load failed: \(error.localizedDescription)"
            }

            // Load bow
            do {
                let bow = try await Entity(named: "bow", in: Bundle.main)
                bow.isEnabled = false
                content.add(bow)
                bowEntity = bow
            } catch {
                let bow = makePlaceholderBow()
                bow.isEnabled = false
                content.add(bow)
                bowEntity = bow
                debugStatus = "Bow load failed, using placeholder"
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

    // MARK: - Placeholder models (fallbacks)

    private func makePlaceholderViolin() -> ModelEntity {
        let mesh = MeshResource.generateBox(width: 0.12, height: 0.03, depth: 0.40, cornerRadius: 0.01)
        var material = SimpleMaterial()
        material.color = .init(tint: .brown)
        material.roughness = .init(floatLiteral: 0.8)
        return ModelEntity(mesh: mesh, materials: [material])
    }

    private func makePlaceholderBow() -> ModelEntity {
        let mesh = MeshResource.generateCylinder(height: 0.75, radius: 0.008)
        var material = SimpleMaterial()
        material.color = .init(tint: .white)
        material.roughness = .init(floatLiteral: 0.6)
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
            debugStatus = "Hand tracking active"

            for await update in provider.anchorUpdates {
                let anchor = update.anchor

                if anchor.chirality == .left && anchor.isTracked {
                    if appModel.violinVisible { placeViolin(on: anchor) }
                }

                if anchor.chirality == .right && anchor.isTracked {
                    if appModel.bowVisible { placeBow(on: anchor) }
                }
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

        let wristWorld  = anchor.originFromAnchorTransform * skeleton.joint(.wrist).anchorFromJointTransform
        let middleWorld = anchor.originFromAnchorTransform * skeleton.joint(.middleFingerMetacarpal).anchorFromJointTransform

        let wristPos  = simd_float3(wristWorld.columns.3.x, wristWorld.columns.3.y, wristWorld.columns.3.z)
        let middlePos = simd_float3(middleWorld.columns.3.x, middleWorld.columns.3.y, middleWorld.columns.3.z)

        let forearmDir = normalize(wristPos - middlePos)
        let palmUp     = normalize(simd_float3(wristWorld.columns.1.x, wristWorld.columns.1.y, wristWorld.columns.1.z))

        let violinCenter = wristPos + forearmDir * appModel.armOffset + SIMD3<Float>(0, appModel.yOffset, 0)

        let zAxis = forearmDir
        let xAxis = normalize(cross(palmUp, zAxis))
        let yAxis = cross(zAxis, xAxis)

        let baseRotation = simd_quatf(simd_float3x3(xAxis, yAxis, zAxis))

        let deg: Float = .pi / 180
        let corrX = simd_quatf(angle: appModel.rotationX * deg, axis: SIMD3<Float>(1, 0, 0))
        let corrY = simd_quatf(angle: appModel.rotationY * deg, axis: SIMD3<Float>(0, 1, 0))
        let corrZ = simd_quatf(angle: appModel.rotationZ * deg, axis: SIMD3<Float>(0, 0, 1))

        violin.transform = Transform(
            scale:       SIMD3<Float>(repeating: appModel.violinScale),
            rotation:    baseRotation * corrX * corrY * corrZ,
            translation: violinCenter
        )
    }

    // MARK: - Bow Placement

    private func placeBow(on anchor: HandAnchor) {
        guard let bow = bowEntity,
              let skeleton = anchor.handSkeleton else { return }

        bow.isEnabled = true

        // Anchor at palm grip — midpoint between wrist and middle knuckle
        let wristWorld  = anchor.originFromAnchorTransform * skeleton.joint(.wrist).anchorFromJointTransform
        let knuckleWorld = anchor.originFromAnchorTransform * skeleton.joint(.middleFingerKnuckle).anchorFromJointTransform

        let wristPos   = simd_float3(wristWorld.columns.3.x,   wristWorld.columns.3.y,   wristWorld.columns.3.z)
        let knucklePos = simd_float3(knuckleWorld.columns.3.x, knuckleWorld.columns.3.y, knuckleWorld.columns.3.z)

        // Grip point: at the knuckle (where fingers wrap around bow)
        let gripPos = knucklePos

        let handDir = normalize(knucklePos - wristPos)
        let palmUp  = normalize(simd_float3(wristWorld.columns.1.x, wristWorld.columns.1.y, wristWorld.columns.1.z))

        let zAxis = handDir
        let xAxis = normalize(cross(palmUp, zAxis))
        let yAxis = cross(zAxis, xAxis)

        let baseRotation = simd_quatf(simd_float3x3(xAxis, yAxis, zAxis))

        let deg: Float = .pi / 180
        let corrX = simd_quatf(angle: appModel.bowRotationX * deg, axis: SIMD3<Float>(1, 0, 0))
        let corrY = simd_quatf(angle: appModel.bowRotationY * deg, axis: SIMD3<Float>(0, 1, 0))
        let corrZ = simd_quatf(angle: appModel.bowRotationZ * deg, axis: SIMD3<Float>(0, 0, 1))
        let finalRotation = baseRotation * corrX * corrY * corrZ

        let basePos = gripPos + handDir * appModel.bowArmOffset + SIMD3<Float>(0, appModel.bowYOffset, 0)

        // Pivot correction in local bow space to compensate for off-center USDZ origin
        let localPivot = SIMD3<Float>(appModel.bowPivotX, appModel.bowPivotY, appModel.bowPivotZ)
        let worldPivotOffset = finalRotation.act(localPivot)

        bow.transform = Transform(
            scale:       SIMD3<Float>(repeating: appModel.bowScale),
            rotation:    finalRotation,
            translation: basePos + worldPivotOffset
        )
    }
}

//
//  AppModel.swift
//  Spatial Violin
//

import Observation

@Observable
class AppModel {
    // Violin
    var violinScale: Float = 0.3421
    var armOffset: Float   = 0.05
    var yOffset: Float     = 0.1
    var rotationX: Float   = -102
    var rotationY: Float   = 3
    var rotationZ: Float   = 0

    // Bow
    var bowScale: Float     = 0.0001
    var bowArmOffset: Float = 0.0
    var bowYOffset: Float   = 0.0
    var bowRotationX: Float = 0
    var bowRotationY: Float = -95
    var bowRotationZ: Float = 0

    // Bow pivot correction (local space — shifts the model relative to its own pivot)
    var bowPivotX: Float = -0.006
    var bowPivotY: Float = -0.067
    var bowPivotZ: Float = -0.333

    var violinVisible: Bool = false
    var bowVisible: Bool    = false
}

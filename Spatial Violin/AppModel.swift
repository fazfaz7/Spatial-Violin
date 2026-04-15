//
//  AppModel.swift
//  Spatial Violin
//

import Observation

@Observable
class AppModel {
    var violinScale: Float = 0.01
    var armOffset: Float   = 0.25
    // Rotation correction in degrees — tune until violin aligns with your arm
    var rotationX: Float   = 0
    var rotationY: Float   = 0
    var rotationZ: Float   = 0
}

//
//  Spatial_ViolinApp.swift
//  Spatial Violin
//
//  Created by Adrian Emmanuel Faz Mercado on 14/04/26.
//

import SwiftUI

@main
struct Spatial_ViolinApp: App {
    @State private var immersionStyle: ImmersionStyle = .mixed
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: "ViolinSpace") {
            ViolinImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}

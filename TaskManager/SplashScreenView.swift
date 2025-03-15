//
//  SplashScreenView.swift
//  TaskManager
//
//  Created by Stefano on 12.03.25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoOpacity = 1.0
    @State private var animateGear = true
    
    let persistenceController = PersistentController.shared
    
    var body: some View {
        if isActive {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
        } else {
            VStack {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .opacity(logoOpacity)
                    .symbolEffect(.rotate, isActive: animateGear)
                
                Text("Task Manager")
                    .font(.largeTitle)
                    .bold()
                    .opacity(logoOpacity)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

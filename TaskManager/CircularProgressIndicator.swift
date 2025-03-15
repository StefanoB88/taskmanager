//
//  CircularProgressIndicator.swift
//  TaskManager
//
//  Created by Stefano on 15.03.25.
//

import SwiftUI

struct CircularProgressIndicator: View {
    @AppStorage("accentColor") private var accentColorHex: String = "#0000FF" // Default iOS Blue
    var accentColor: Color {
        return Color.fromHex(accentColorHex)
    }
    
    @Binding var completedTasks: Int
    @Binding var totalTasks: Int
    @State private var progress: CGFloat = 0.0

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(LinearGradient(gradient: Gradient(colors: [.blue, .purple, .pink, .red]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 10)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 50, height: 50)
                    .animation(.easeInOut(duration: 1), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .onAppear() {
                updateProgress()
            }
            .onChange(of: completedTasks) {
                updateProgress()
            }
            .onChange(of: totalTasks) {
                updateProgress()
            }
        }
    }
    
    // Update progress based on completed and total tasks
    private func updateProgress() {
        if totalTasks > 0 {
            progress = CGFloat(completedTasks) / CGFloat(totalTasks)
        } else {
            progress = 0
        }
    }
}

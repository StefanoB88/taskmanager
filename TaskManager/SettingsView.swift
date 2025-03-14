//
//  SettingsView.swift
//  TaskManager
//
//  Created by Stefano on 12.03.25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("accentColor") private var selectedColorHex: String = "#0000FF" // Default iOS Blue
    
    let colors: [Color] = [.blue, .green, .orange, .red]
    let colorNames: [String] = ["Blue", "Green", "Orange", "Red"]
    
    var body: some View {
        Form {
            Section(header: Text("Accent Color")) {
                Picker("Accent Color", selection: $selectedColorHex) {
                    ForEach(0..<colors.count, id: \.self) { index in
                        Text(colorNames[index]).tag(colors[index].toHex())
                    }
                }
                .onChange(of: selectedColorHex) {
                    UserDefaults.standard.set(selectedColorHex, forKey: "accentColor")
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            if let storedHex = UserDefaults.standard.string(forKey: "accentColor") {
                selectedColorHex = storedHex
            }
        }
    }
}

// Estensione per la conversione tra Color e HEX
extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    static func fromHex(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        return Color(UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0))
    }
}

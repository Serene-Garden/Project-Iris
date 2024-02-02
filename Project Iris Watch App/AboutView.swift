//
//  AboutView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/2.
//
import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            if #available(watchOS 10.0, *) {
                TabView {
                    AboutApp()
                        .navigationTitle("About")
                    AboutCredits()
                        .navigationTitle("About.credits")
                }
                .tabViewStyle(.verticalPage)
            } else {
                TabView {
                    AboutApp()
                        .navigationTitle("About")
                    AboutCredits()
                        .navigationTitle("About.credits")
                }
            }
        }
    }
}

struct AboutApp: View {
    let AppIconLength: CGFloat = 70
    var body: some View {
        VStack(alignment: .center) {
            Image("AppIconImage")
                .resizable()
                .frame(width: AppIconLength, height: AppIconLength)
                .mask(Circle())
            Text("Project Iris")
                .bold()
                .font(.title3)
            Group {
                Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
            }
            .font(.caption)
            .monospaced()
            .foregroundStyle(.secondary)
        }
    }
}

struct AboutCredits: View {
    @Environment(\.dismiss) var dismiss
    @State var isEasterEgg1Presented = false
    @State var isGenshin = false
    @State var genshinOverlayTextOpacity: CGFloat = 0.0
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("ThreeManager785")
                    Text("WindowsMEMZ")
                    Text("And You")
                }
            }
        }
    }
}

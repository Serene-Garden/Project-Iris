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
    @State var isEasterEggDisplayed = false
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
                Text("ThreeManager785")
                Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
            }
            .font(.caption)
            .monospaced()
            .foregroundStyle(.secondary)
        }
        .onTapGesture(count: 3) {
            isEasterEggDisplayed = true
        }
        .sheet(isPresented: $isEasterEggDisplayed, content: {
            Text("About.easter-egg")
        })
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
                Text("ThreeManager785")
                Text("WindowsMEMZ")
                NavigationLink(destination: {
                    Text("About.dear-user.content")
                        .navigationTitle("About.dear-user")
                }, label: {Text("And You")})
            }
        }
    }
}

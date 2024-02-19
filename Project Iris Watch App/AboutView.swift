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
                    AboutVersions()
                        .navigationTitle("About.logs")
                }
                .tabViewStyle(.verticalPage)
            } else {
                TabView {
                    AboutApp()
                        .navigationTitle("About")
                    AboutCredits()
                        .navigationTitle("About.credits")
                    AboutVersions()
                        .navigationTitle("About.logs")
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
                Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)").monospaced() + Text(" · ") + Text("GPL-3.0").monospaced()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .onTapGesture(count: 3) {
            isEasterEggDisplayed = true
        }
        .sheet(isPresented: $isEasterEggDisplayed, content: {
            VStack {
                Text("About.easter-egg")
                    .multilineTextAlignment(.center)
                Text("About.easter-egg.image-footer")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
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
                    List {
                        Text("About.dear-user.content")
                            .navigationTitle("About.dear-user")
                    }
                }, label: {Text("And You")})
            }
        }
    }
}

struct AboutVersions: View {
    var body: some View {
        NavigationStack {
            List {
                Section(content: {
                    VStack(alignment: .leading) {
                        Text("About.version.1.1.4")
                            .bold()
                        Text("About.version.1.1.4.details")
                    }
                    VStack(alignment: .leading) {
                        Text("About.version.1.1.3")
                            .bold()
                        Text("About.version.1.1.3.details")
                    }
                    VStack(alignment: .leading) {
                        Text("About.version.1.1.2")
                            .bold()
                        Text("About.version.1.1.2.details")
                    }
                    VStack(alignment: .leading) {
                        Text("About.version.1.1.1")
                            .bold()
                        Text("About.version.1.1.1.details")
                    }
                    VStack(alignment: .leading) {
                        Text("About.version.1.1.0")
                            .bold()
                        Text("About.version.1.1.0.details")
                    }
                }, footer: {
                    Text("About.version.footer")
                })
            }
            .multilineTextAlignment(.leading)
        }
    }
}

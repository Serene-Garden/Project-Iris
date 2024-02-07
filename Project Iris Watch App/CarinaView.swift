//
//  OrionView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI

struct CarinaView: View {
    @State var isNewFeedbackDisplaying = false
    @State var latestVer = ""
    var body: some View {
        NavigationStack {                
            if #available(watchOS 10.0, *) {
                List {
                    NavigationLink(destination: {CarinaProgressView(title: "Title", content: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", carinaID: 0, type: 0, place: 0, state: 0, version: "v.1.1.2!")
                    }, label: {
                        Text("1")
                    })
                    Text("Carina.powered-by-radar")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar, content: {
                        HStack {
                            Spacer()
                            Button(action: {
                                isNewFeedbackDisplaying = true
                            }, label: {
                                Image(systemName:  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer ? "plus" : "plus.slash")
                                    .foregroundStyle(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer ? Color.accentColor : Color.secondary)
                            })
                        }
                    })
                }
            } else {
                List {
                    Button(action: {
                        isNewFeedbackDisplaying = true
                    }, label: {
                        Label(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer ? "Carina.new" : "Carina.new.update-required", systemImage: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer ? "plus" : "plus.slash")
                    })
                    Text("Carina.powered-by-radar")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Carina")
        .sheet(isPresented: $isNewFeedbackDisplaying, content: {
            if Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer {
                CarinaNewView()
            } else {
                Text("Carina.update")
            }
        })
        .onAppear {
            fetchWebPageContent(urlString: "https://api.darock.top/iris/newver") { result in
                switch result {
                case .success(let content):
                    latestVer = content.components(separatedBy: "\"")[1]
                case .failure(let error):
                    latestVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                }
            }
        }
    }
}

#Preview {
    CarinaView()
}

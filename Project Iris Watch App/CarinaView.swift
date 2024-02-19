//
//  OrionView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI

struct CarinaView: View {
    @State var personalFeedbacks: [Any] = []
    @State var latestVer = ""
    var body: some View {
        NavigationStack {
            List {
                if #available(watchOS 10.0, *) {} else {
                    NavigationLink(destination: {
                        if Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer {
                            CarinaNewView()
                        } else {
                            VStack {
                                Image(systemName: "chevron.right.2")
                                    .font(.largeTitle)
                                Text("Carina.update")
                                HStack {
                                    Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                                        .monospaced()
                                    Image(systemName: "chevron.forward")
                                    //Image(systemName: "arrow.right")
                                    Text("\(latestVer)")
                                        .monospaced()
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }) {
                        Label(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer ? "Carina.new" : "Carina.new.update-required", systemImage: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer ? "plus" : "chevron.right.2")
                    }
                }
                if personalFeedbacks.isEmpty {
                    Text("Carina.none")
                        .bold()
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(0..<personalFeedbacks.count, id: \.self) { feedback in
                        NavigationLink(destination: {
                            CarinaProgressView(carinaID: personalFeedbacks[feedback] as! Int)
                        }, label: {
                            Text("#\(personalFeedbacks[feedback] as! Int)")
                        })
                    }
                    .onDelete(perform: { feedback in
                        personalFeedbacks.remove(atOffsets: feedback)
                        UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
                    })
                }
                Text("Carina.powered-by-radar")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            
        }
        .toolbar {
            if #available(watchOS 10.0, *) {
                ToolbarItem(placement: .bottomBar, content: {
                    HStack {
                        Spacer()
                        NavigationLink(destination: {
                            if Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer {
                                CarinaNewView()
                            } else {
                                VStack {
                                    Image(systemName: "arrowshape.up.fill")
                                        .font(.largeTitle)
                                        .bold()
                                    Text("Carina.update")
                                    HStack {
                                        Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                                            .monospaced()
                                        Image(systemName: "chevron.forward")
                                        //Image(systemName: "arrow.right")
                                        Text("\(latestVer.isEmpty ? "[ERROR]" : latestVer)")
                                            .monospaced()
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }, label: {
                            Image(systemName:  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer ? "plus" : "arrowshape.up.fill")
                                .foregroundStyle(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String == latestVer ? Color.accentColor : Color.gray)
                        })
                    }
                })
            }
        }
        .navigationTitle("Carina")
        .onAppear {
            personalFeedbacks = UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []
            fetchWebPageContent(urlString: irisVersionAPI) { result in
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

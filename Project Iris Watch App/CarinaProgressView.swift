//
//  CarinaProgressView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI

struct CarinaProgressView: View {
    var carinaID: Int
    @State var package = ""
    @State var packageInfo = [""]
    @State var title = ""
    @State var details = ""
    @State var type: Int = 4
    @State var place: Int = 8
    @State var state: Int = 0
    @State var version: String = ""
    @State var isTitleExpanded = false
    let carinaStates: [LocalizedStringKey] = ["Carina.state.unmarked", "Carina.state.work-as-intended", "Carina.state.unable-to-fix", "Carina.state.combined", "Carina.state.shelved", "Carina.state.fixing", "Carina.state.fixed-in-future-versions", "Carina.state.fixed", "Carina.info.load"]
    let carinaStateDescription: [LocalizedStringKey] = ["Carina.state.unmarked.description", "Carina.state.work-as-intended.description", "Carina.state.unable-to-fix.description", "Carina.state.combined.description", "Carina.state.shelved.description", "Carina.state.fixing.description", "Carina.state.fixed-in-future-versions.description", "Carina.state.fixed.description", "Carina.info.load"]
    let carinaStateColors = [Color.secondary, Color.red, Color.red, Color.red, Color.orange, Color.orange, Color.orange, Color.green]
    let carinaTypes: [LocalizedStringKey] = ["Carina.type.function", "Carina.type.interface", "Carina.type.texts", "Carina.type.suggestion", "Carina.info.load"]
    let carinaPlaces: [LocalizedStringKey] = ["Carina.place.about", "Carina.place.bookmarks", "Carina.place.carina-feedback", "Carina.place.history-and-privacy", "Carina.place.passcode", "Carina.place.search", "Carina.place.tips", "Carina.place.other", "Carina.info.load"]
    let carinaStateIcons: [String] = ["minus", "curlybraces", "xmark", "arrow.triangle.merge", "books.vertical", "hammer", "clock.badge.checkmark", "checkmark"]
    var body: some View {
        NavigationStack {
            List {
                if title.isEmpty {
                    Section(content: {
                        Text("Carina.loading")
                            .bold()
                            .foregroundStyle(.secondary)
                    }, footer: {
                        Text("Carina.loading.footer")
                    })
                } else if package == "Error" {
                    VStack {
                        Image(systemName: "questionmark.bubble")
                            .font(.largeTitle)
                        //.bold()
                        Text("Carina.failed-fetching")
                    }
                } else {
                    Text(title)
                        .bold()
                        .lineLimit(isTitleExpanded ? -1 : 2)
                        .onTapGesture {
                            isTitleExpanded.toggle()
                        }
                    NavigationLink(destination: {
                        List {
                            
                            HStack {
                                Image(systemName: carinaStateIcons[state])
                                Text(carinaStates[state])
                            }
                            .bold()
                            Text(carinaStateDescription[state])
                            //TODO: REMOVE IN 1.1.5
                            Divider()
                            Text("Carina.state.not-ready-yet")
                            Text("Carina.state.still-receiveable")
                        }
                        .navigationTitle("Carina.state")
                    }, label: {
                        HStack {
                            Circle()
                                .frame(width: 10)
                                .foregroundStyle(carinaStateColors[state])
                                .padding(.trailing, 7)
                            Text(carinaStates[state])
                            Spacer()
                        }
                        .padding()
                    })
                    Text(carinaTypes[type]) + Text(" · ") + Text(carinaPlaces[place]) + Text(" · ") + Text(version)
                    if !details.isEmpty && details != "none" {
                        NavigationLink(destination: {
                            List{Text(details)}
                                .navigationTitle("Carina.content")
                        }, label: {
                            Text(details)
                                .font(.caption)
                                .lineLimit(3)
                        })
                    }
                }
            }
            .navigationTitle("#\(carinaID)")
            .onAppear {
                fetchWebPageContent(urlString: "\(carinaPullFeedbackAPI)\(carinaID)") { result in
                    switch result {
                    case .success(let content):
                        package = content.components(separatedBy: "\"")[1]
                        packageInfo = package.components(separatedBy: "\\n")
//                        print(packageInfo)
                        title = packageInfo[0]
                        for i in 1..<packageInfo.count {
                            if packageInfo[i].hasPrefix("Type：") {
                                type = Int(packageInfo[i].components(separatedBy: "Type：")[1]) ?? 0
                            } else if packageInfo[i].hasPrefix("Place：") {
                                place = Int(packageInfo[i].components(separatedBy: "Place：")[1]) ?? 7
                            } else if packageInfo[i].hasPrefix("State：") {
                                state = Int(packageInfo[i].components(separatedBy: "State：")[1]) ?? 0
                            }  else if packageInfo[i].hasPrefix("State：") {
                                state = Int(packageInfo[i].components(separatedBy: "State：")[1]) ?? 0
                            } else if packageInfo[i].hasPrefix("Content：") {
                                details = packageInfo[i].components(separatedBy: "Content：")[1]
                            } else if packageInfo[i].hasPrefix("Version：") {
                                version = packageInfo[i].components(separatedBy: "Version：")[1]
                            }
                        }
                    case .failure(let error):
                        package = "Error"
                    }
                }
            }
        }
    }
}

func decodeBase64(string: String) -> String? {
    guard let data = Data(base64Encoded: string) else {
        return nil
    }
    
    return String(data: data, encoding: .utf8)
}

//
//  CarinaNewView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI

struct CarinaNewView: View {
    @State var personalFeedbacks: [Any] = []
    @State var type = 0
    @State var place = 7
    @State var title = ""
    @State var content = ""
    @State var sent = false
    @State var CarinaID = 0
    @State var is_watchOS10 = false
    @State var sending = false
    @State var package = """
"""
    @State var encodedPackage = ""
    let carinaTypes: [LocalizedStringKey] = ["Carina.type.function", "Carina.type.interface", "Carina.type.texts", "Carina.type.suggestion"]
    let carinaPlaces: [LocalizedStringKey] = ["Carina.place.about", "Carina.place.bookmarks", "Carina.place.carina-feedback", "Carina.place.history-and-privacy", "Carina.place.passcode", "Carina.place.search", "Carina.place.tips", "Carina.place.other"]
    var body: some View {
        if sent {
            if CarinaID == -1 || CarinaID == -2 {
                VStack {
                    Image(systemName: "circle.badge.exclamationmark")
                        .font(.system(size: 50))
                    Text("Carina.failed")
                    Group {
                        Text(carinaTypes[type]) + Text(" · ") + Text(carinaPlaces[place]) + Text(" · ") + Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) + Text(is_watchOS10 ? "" : "!")
                    }
                    .foregroundStyle(.secondary)
                }
            } else if CarinaID == 0 {
                VStack {
                    Image(systemName: "hourglass")
                        .font(.system(size: 50))
                    Text("Carina.sending")
                    Group {
                        Text(carinaTypes[type]) + Text(" · ") + Text(carinaPlaces[place]) + Text(" · ") + Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) + Text(is_watchOS10 ? "" : "!")
                    }
                    .foregroundStyle(.secondary)
                }
            } else {
                VStack {
                    Image(systemName: "paperplane")
                        .font(.system(size: 50))
                    //.bold()
                    Text("Carina.sent") + Text(" · ") + Text("#\(CarinaID)").monospaced()
                    Group {
                        Text(carinaTypes[type]) + Text(" · ") + Text(carinaPlaces[place]) + Text(" · ") + Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) + Text(is_watchOS10 ? "" : "!")
                    }
                    .foregroundStyle(.secondary)
                    //.multilineTextAlignment(.center)
                    NavigationLink(destination: {
                        CarinaProgressView(carinaID: CarinaID)
                    }, label: {
                        Label("Carina.sent.view", systemImage: "doc.text.image")
                    })
                }
                .onAppear {
                    personalFeedbacks.append(CarinaID)
                    UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
                }
            }
        } else {
            List {
                Section("Carina.new.app") {
                    Text("Project Iris")
                }
                Section(content: {
                    Picker("Carina.type", selection: $type) {
                        ForEach(carinaTypes.indices) { typeIndex in
                            Text(carinaTypes[typeIndex]).tag(typeIndex)
                        }
                    }
                    Picker("Carina.place", selection: $place) {
                        ForEach(carinaPlaces.indices) { placeIndex in
                            Text(carinaPlaces[placeIndex]).tag(placeIndex)
                        }
                    }
                }, header: {
                    Text("Carina.new.basic-information")
                }, footer: {
                    if type == 0 {
                        Text("Carina.type.function.description")
                    } else if type == 1 {
                        Text("Carina.type.interface.description")
                    } else if type == 2 {
                        Text("Carina.type.texts.description")
                    } else if type == 3 {
                        Text("Carina.type.suggestions.description")
                    }
                })
                Section("Carina.new.details") {
                    TextField("Carina.new.title", text: $title)
                    TextField("Carina.new.content", text: $content)
                }
                Button(action: {
                    sending = true
                    package = """
\(title)
Type：\(type)
Place：\(place)
State：0
Content：\(content.isEmpty ? "none" : content)
Version：\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)\(is_watchOS10 ? "" : "!")
"""
                    encodedPackage = package.data(using: .utf8)?.base64EncodedString() ?? ""
                    fetchWebPageContent(urlString: "\(carinaPushFeedbackAPI)\(encodedPackage)") { result in
                        switch result {
                        case .success(let content):
                            CarinaID = Int(content) ?? -1
                        case .failure(let error):
                            CarinaID = -2
                        }
                    }
                    sent = true
                }, label: {
                    if sending {
                        HStack {
                            ProgressView()
                            Text("Carina.new.sending")
                            Spacer()
                        }
                    } else {
                        Label("Carina.new.send", systemImage: "paperplane")
                    }
                })
                .disabled(title.isEmpty && !sending)
                .foregroundStyle(title.isEmpty && !sending ? Color.secondary : Color.primary)
            }
            .navigationTitle("Carina.new")
            .onAppear {
                if #available(watchOS 10.0, *) {
                    is_watchOS10 = true
                }
                personalFeedbacks = UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []
            }
        }
    }
}

#Preview {
    CarinaNewView()
}

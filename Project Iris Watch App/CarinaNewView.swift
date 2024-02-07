//
//  CarinaNewView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI

struct CarinaNewView: View {
    @State var type = 0
    @State var place = 7
    @State var title = ""
    @State var content = ""
    @State var sent = false
    @State var CarinaID = 0
    @State var is_watchOS10 = false
    let carinaTypes: [LocalizedStringKey] = ["Carina.type.function", "Carina.type.interface", "Carina.type.texts", "Carina.type.suggestion"]
    let carinaPlaces: [LocalizedStringKey] = ["Carina.place.about", "Carina.place.bookmarks", "Carina.place.carina-feedback", "Carina.place.history-and-privacy", "Carina.place.passcode", "Carina.place.search", "Carina.place.tips", "Carina.place.other"]
    var body: some View {
        if sent {
            VStack {
                Text("#\(CarinaID)")
                    .font(.largeTitle)
                    .monospaced()
                Text("Carina.sent")
                Text(carinaTypes[type]) + Text(" · ") + Text(carinaPlaces[place]) + Text(" · ") + Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) + Text(is_watchOS10 ? "" : "!")
//                    .multilineTextAlignment(.center)
                NavigationLink(destination: {}, label: {
                    Label("Carina.sent.view", systemImage: "doc.text.image")
                })
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
                    Text("Carina.new.no-repeat-tip")
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
                    sent = true
                }, label: {
                    Label("Carina.new.send", systemImage: "paperplane")
                })
                .disabled(title.isEmpty || content.isEmpty)
            }
            .navigationTitle("Carina.new")
            .onAppear {
                if #available(watchOS 10.0, *) {
                    is_watchOS10 = true
                }
            }
        }
    }
}

#Preview {
    CarinaNewView()
}

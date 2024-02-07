//
//  CarinaProgressView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI

struct CarinaProgressView: View {
    var title: String
    var content: String
    var carinaID: Int
    var type: Int
    var place: Int
    var state: Int
    var version: String
    let carinaStates: [LocalizedStringKey] = ["Carina.state.unmarked", "Carina.state.work-as-intended", "Carina.state.unable-to-fix", "Carina.state.combined", "Carina.state.shelved", "Carina.state.fixing", "Carina.state.fixed-in-future-versions", "Carina.state.fixed"]
    let carinaStateDescription: [LocalizedStringKey] = ["Carina.state.unmarked.description", "Carina.state.work-as-intended.description", "Carina.state.unable-to-fix.description", "Carina.state.combined.description", "Carina.state.shelved.description", "Carina.state.fixing.description", "Carina.state.fixed-in-future-versions.description", "Carina.state.fixed.description"]
    let carinaStateColors = [Color.secondary, Color.red, Color.red, Color.red, Color.orange, Color.orange, Color.orange, Color.green]
    let carinaTypes: [LocalizedStringKey] = ["Carina.type.function", "Carina.type.interface", "Carina.type.texts", "Carina.type.suggestion"]
    let carinaPlaces: [LocalizedStringKey] = ["Carina.place.about", "Carina.place.bookmarks", "Carina.place.carina-feedback", "Carina.place.history-and-privacy", "Carina.place.passcode", "Carina.place.search", "Carina.place.tips", "Carina.place.other"]
    let carinaStateIcons: [String] = ["minus", "curlybraces", "xmark", "arrow.triangle.merge", "books.vertical", "hammer", "clock.badge.checkmark", "checkmark"]
    var body: some View {
        NavigationStack {
            List {
                Text(title)
                    .bold()
                NavigationLink(destination: {
                    List {
                        HStack {
                            Image(systemName: carinaStateIcons[state])
                            Text(carinaStates[state])
                        }
                        .bold()
                        Text(carinaStateDescription[state])
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
                NavigationLink(destination: {
                    List{Text(content)}
                        .navigationTitle("Carina.content")
                }, label: {
                    Text(content)
                        .font(.caption)
                        .lineLimit(3)
                })
            }
            .navigationTitle("#\(carinaID)")
        }
    }
}

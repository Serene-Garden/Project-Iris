//
//  OrionView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI

//struct CarinaConsensusIssuesView: View {
//  @Binding var bulletinDecoded: [String]
//  @Binding var title: [String]
//  @Binding var packageInfo: [String]
//  @Binding var state: [Int]
//  var body: some View {
//    List {
//      ForEach(0..<bulletinDecoded.count, id: \.self) { bulletin in
//        NavigationLink(destination: {
//          CarinaProgressView(carinaID: 0, source: bulletinDecoded[bulletin])
//        }, label: {
//          HStack {
//            Circle()
//              .frame(width: 10)
//              .foregroundStyle(carinaStateColors[state[bulletin]] ?? Color.secondary)
//              .padding(.trailing, 7)
//            Text(title[bulletin])
//              .lineLimit(3)
//            Spacer()
//          }
//          .padding()
//        })
//      }
//      .onAppear {
//        for bulletins in 0..<bulletinDecoded.count {
//          packageInfo = bulletinDecoded[bulletins].components(separatedBy: "\\\\n")
//          title[bulletins] = packageInfo[0].contains("<lang>") ? (languageCode! == "zh" ? packageInfo[0].components(separatedBy: "<lang>")[0] : packageInfo[0].components(separatedBy: "<lang>")[1]) : packageInfo[0]
//          for i in 1..<packageInfo.count {
//            if packageInfo[i].hasPrefix("State：") {
//              state[bulletins] = Int(packageInfo[i].components(separatedBy: "State：")[1]) ?? 8
//            }
//          }
//        }
//      }
//    }
//    .navigationTitle("Carina.bulletin")
//  }
//}

struct CarinaView: View {
  @State var personalFeedbacks: [Any] = []
  @State var latestVer = ""
  @State var isBulletinReady = false
  @State var bulletinPackage = ""
  @State var packageInfo = [""]
  @State var title = ["", "", "", "", "", "", "", ""]
  @State var state = [8, 8, 8, 8, 8, 8, 8, 8, 8]
  let carinaStateColors = [Color.secondary, Color.red, Color.red, Color.red, Color.orange, Color.orange, Color.orange, Color.green, Color.secondary, Color.red, Color.secondary, Color.orange]
  var body: some View {
    NavigationStack {
      List {
        if personalFeedbacks.isEmpty {
          Text("Carina.none")
            .bold()
            .foregroundStyle(.secondary)
        } else {
          ForEach(0..<personalFeedbacks.count, id: \.self) { feedback in
            NavigationLink(destination: {
              CarinaDetailView(carinaID: personalFeedbacks[feedback] as! Int)
            }, label: {
              Text("#\(personalFeedbacks[feedback])")
            })
          }
          .onDelete(perform: { feedback in
            personalFeedbacks.remove(atOffsets: feedback)
            UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
          })
          .onMove(perform: { oldIndex, newIndex in
            personalFeedbacks.move(fromOffsets: oldIndex, toOffset: newIndex)
            UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
          })
        }
        Text(verbatim: "Powered by Darock Radar")
          .foregroundStyle(.secondary)
          .font(.caption)
      }
      
    }
    .toolbar {
      if #available(watchOS 10.0, *) {
        ToolbarItemGroup(placement: .bottomBar, content: {
            if !bulletinPackage.isEmpty {
              NavigationLink(destination: {
                List {
                  Text(bulletinPackage)
                }
                .navigationTitle("Carina.bulletin")
              }, label: {
                Label("Carina.bulletin", systemImage: "pin")
              })
            }
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
        })
      }
    }
    .navigationTitle("Carina.title")
    .onAppear {
      personalFeedbacks = UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []
      fetchWebPageContent(urlString: "https://fapi.darock.top:65535/iris/newver") { result in
        switch result {
          case .success(let content):
            latestVer = content.components(separatedBy: "\"")[1]
            if latestVer.contains("!") {
              latestVer = latestVer.components(separatedBy: "!")[0]
            }
          case .failure(let error):
            latestVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        }
      }
      fetchWebPageContent(urlString: "https://fapi.darock.top:65535/iris/notice") { result in
        switch result {
          case .success(let content):
            bulletinPackage = content
            bulletinPackage.removeFirst()
            bulletinPackage.removeLast()
          case .failure(let error):
            bulletinPackage = ""
        }
      }
    }
  }
}

#Preview {
  CarinaView()
}

@MainActor public let carinaStates: [Int: LocalizedStringKey] = [0: "Carina.state.unmarked", 1: "Carina.state.work-as-intended", 2: "Carina.state.unable-to-fix", 3: "Carina.state.combined", 4: "Carina.state.shelved", 5: "Carina.state.fixing", 6: "Carina.state.fixed-in-future-versions", 7: "Carina.state.fixed", 8: "Carina.info.load", 9: "Carina.state.cannot-reappear", 10: "Carina.state.unrelated", 11: "Carina.state.require-more-details"]
@MainActor public let carinaStateDescription: [Int: LocalizedStringKey] = [0: "Carina.state.unmarked.description", 1: "Carina.state.work-as-intended.description", 2: "Carina.state.unable-to-fix.description", 3: "Carina.state.combined.description", 4: "Carina.state.shelved.description", 5: "Carina.state.fixing.description", 6: "Carina.state.fixed-in-future-versions.description", 7: "Carina.state.fixed.description", 8: "Carina.info.load", 9: "Carina.state.cannot-reappear.description", 10: "Carina.state.unrelated.description", 11: "Carina.state.require-more-details.description"]
@MainActor public let carinaStateColors: [Int: Color] = [0: Color.secondary, 1: Color.red, 2: Color.red, 3: Color.red, 4: Color.orange, 5: Color.orange, 6: Color.orange, 7: Color.green, 8: Color.secondary, 9: Color.red, 10: Color.red, 11: Color.orange]
@MainActor public let carinaStateIcons: [Int: String] = [0: "minus", 1: "curlybraces", 2: "xmark", 3: "arrow.triangle.merge", 4: "books.vertical", 5: "hammer", 6: "clock.badge.checkmark", 7: "checkmark", 8: "ellipsis", 9: "questionmark", 10: "bolt.horizontal", 11: "arrowshape.turn.up.backward.badge.clock"]
@MainActor public let carinaTypes: [Int: LocalizedStringKey] = [0: "Carina.type.function", 1: "Carina.type.interface", 2: "Carina.type.texts", 3: "Carina.type.suggestion"]
@MainActor public let carinaPlaces: [Int: LocalizedStringKey] = [0: "Carina.place.about", 1: "Carina.place.bookmarks", 2: "Carina.place.carina", 3: "Carina.place.history", 4: "Carina.place.passcode", 5: "Carina.place.search", 6: "Carina.place.tips", 8: "Carina.place.home", 10: "Carina.place.privacy", 11: "Carina.place.credits", 3000: "Carina.place.other"]

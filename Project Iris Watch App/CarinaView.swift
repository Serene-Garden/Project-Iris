//
//  OrionView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI

struct CarinaConsensusIssuesView: View {
  @Binding var bulletinDecoded: [String]
  @Binding var title: [String]
  @Binding var packageInfo: [String]
  @Binding var state: [Int]
  var body: some View {
    List {
      ForEach(0..<bulletinDecoded.count, id: \.self) { bulletin in
        NavigationLink(destination: {
          CarinaProgressView(carinaID: 0, source: bulletinDecoded[bulletin])
        }, label: {
          HStack {
            Circle()
              .frame(width: 10)
              .foregroundStyle(carinaStateColors[state[bulletin]])
              .padding(.trailing, 7)
            Text(title[bulletin])
              .lineLimit(3)
            Spacer()
          }
          .padding()
        })
      }
      .onAppear {
        for bulletins in 0..<bulletinDecoded.count {
          packageInfo = bulletinDecoded[bulletins].components(separatedBy: "\\\\n")
          title[bulletins] = packageInfo[0].contains("<lang>") ? (languageCode! == "zh" ? packageInfo[0].components(separatedBy: "<lang>")[0] : packageInfo[0].components(separatedBy: "<lang>")[1]) : packageInfo[0]
          for i in 1..<packageInfo.count {
            if packageInfo[i].hasPrefix("State：") {
              state[bulletins] = Int(packageInfo[i].components(separatedBy: "State：")[1]) ?? 8
            }
          }
        }
      }
    }
    .navigationTitle("Carina.bulletin")
  }
}

struct CarinaView: View {
  @State var personalFeedbacks: [Any] = []
  @State var latestVer = ""
  @State var isBulletinReady = false
  @State var bulletinPackage = ""
  @State var bulletinDecoded = [""]
  @State var packageInfo = [""]
  @State var title = ["", "", "", "", "", "", "", ""]
  @State var state = [8, 8, 8, 8, 8, 8, 8, 8, 8]
  let carinaStateColors = [Color.secondary, Color.red, Color.red, Color.red, Color.orange, Color.orange, Color.orange, Color.green, Color.secondary, Color.red, Color.secondary, Color.orange]
  var body: some View {
    NavigationStack {
      List {
        if #available(watchOS 10.0, *) {} else {
          if isBulletinReady && !bulletinPackage.isEmpty {
            NavigationLink(destination: {
              CarinaConsensusIssuesView(bulletinDecoded: $bulletinDecoded, title: $title, packageInfo: $packageInfo, state: $state)
            }, label: {
              Label("Carina.bulletin.\(bulletinDecoded.count)", systemImage: "pin")
            })
          } else if !isBulletinReady {
            Label("Carina.bulletin.unready", systemImage: "pin")
              .disabled(true)
          } else if bulletinPackage.isEmpty {
            Label("Carina.bulletin.none", systemImage: "pin")
              .disabled(true)
          }
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
        ToolbarItemGroup(placement: .bottomBar, content: {
            if isBulletinReady && !bulletinPackage.isEmpty {
              NavigationLink(destination: {
                CarinaConsensusIssuesView(bulletinDecoded: $bulletinDecoded, title: $title, packageInfo: $packageInfo, state: $state)
              }, label: {
                Label("Carina.bulletin.\(bulletinDecoded.count)", systemImage: "pin")
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
        fetchWebPageContent(urlString: irisVersionAPI) { result in
          switch result {
          case .success(let content):
            latestVer = content.components(separatedBy: "\"")[1]
          case .failure(let error):
            latestVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
          }
        }
        fetchWebPageContent(urlString: irisBulletinAPI) { result in
          switch result {
          case .success(let content):
            isBulletinReady = true
            bulletinPackage = content.components(separatedBy: "\"")[1]
            if !bulletinPackage.isEmpty {
              bulletinDecoded = bulletinPackage.components(separatedBy: "---\\\\n")
            }
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

@MainActor public let carinaStates: [LocalizedStringKey] = ["Carina.state.unmarked", "Carina.state.work-as-intended", "Carina.state.unable-to-fix", "Carina.state.combined", "Carina.state.shelved", "Carina.state.fixing", "Carina.state.fixed-in-future-versions", "Carina.state.fixed", "Carina.info.load", "Carina.state.cannot-reappear", "Carina.state.unrelated", "Carina.state.require-more-details"]
@MainActor public let carinaStateDescription: [LocalizedStringKey] = ["Carina.state.unmarked.description", "Carina.state.work-as-intended.description", "Carina.state.unable-to-fix.description", "Carina.state.combined.description", "Carina.state.shelved.description", "Carina.state.fixing.description", "Carina.state.fixed-in-future-versions.description", "Carina.state.fixed.description", "Carina.info.load", "Carina.state.cannot-reappear.description", "Carina.state.unrelated.description", "Carina.state.require-more-details.description"]
@MainActor public let carinaStateColors = [Color.secondary, Color.red, Color.red, Color.red, Color.orange, Color.orange, Color.orange, Color.green, Color.secondary, Color.red, Color.red, Color.orange]
@MainActor public let carinaStateIcons: [String] = ["minus", "curlybraces", "xmark", "arrow.triangle.merge", "books.vertical", "hammer", "clock.badge.checkmark", "checkmark", "ellipsis", "questionmark", "bolt.horizontal", "arrowshape.turn.up.backward.badge.clock"]
@MainActor public let carinaTypes: [LocalizedStringKey] = ["Carina.type.function", "Carina.type.interface", "Carina.type.texts", "Carina.type.suggestion", ]
@MainActor public let carinaPlaces: [LocalizedStringKey] = ["About", "Home.bookmarks", "Settings.carina", "Carina.place.history-and-privacy", "Settings.passcode", "Settings.search", "Settings.tip", "Carina.place.other"]

//
//  OrionView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import RadarKitCore
import SwiftUI

struct CarinaView: View {
  @State var personalFeedbacks: [Int] = []
  @State var personalFeedbackTitles: [Int: String] = [:]
  @State var personalFeedbackStates: [Int: Int] = [:]
  @State var latestVer: String = ""
  var projectManager: RKCFeedbackManager = RKCFeedbackManager(projectName: "Project Iris")
  var body: some View {
    NavigationStack {
      if !personalFeedbacks.isEmpty {
        List {
          if #unavailable(watchOS 10) {
            NavigationLink(destination: {
              CarinaNewNavigationView()
            }, label: {
              Label("Carina.new", systemImage: "plus")
            })
          }
          ForEach(0..<personalFeedbacks.count, id: \.self) { feedbackIndex in
            NavigationLink(destination: {
              CarinaDetailView(id: String(personalFeedbacks[feedbackIndex]))
            }, label: {
              HStack {
                Circle()
                  .foregroundStyle(carinaStateColors[personalFeedbackStates[personalFeedbacks[feedbackIndex]] ?? 8] ?? Color.secondary)
                  .frame(width: 10)
                  .padding(.trailing, 7)
                Text(personalFeedbackTitles[personalFeedbacks[feedbackIndex]] ?? "#\(String(personalFeedbacks[feedbackIndex]))")
                  .lineLimit(2)
                Spacer()
              }
            })
          }
          .onMove(perform: { oldIndex, newIndex in
            personalFeedbacks.move(fromOffsets: oldIndex, toOffset: newIndex)
            UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
          })
          .onDelete(perform: { index in
            //            personalFeedbackTitles.removeValue(forKey: personalFeedbacks[Int(index)])
//            personalFeedbackTitles.removeValue(forKey: personalFeedbacks[index.first!])
            personalFeedbacks.remove(atOffsets: index)
//            UserDefaults.standard.set(personalFeedbackTitles, forKey: "personalFeedbackTitles")
            UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
          })
        }
      } else {
        if #available(watchOS 10, *) {
          ContentUnavailableView {
            Label("Carina.none", systemImage: "bubble.left.and.bubble.right")
          } description: {
            Text("Carina.none.description")
          }
        } else {
          List {
            Text("Carina.none")
              .bold()
              .foregroundStyle(.secondary)
            NavigationLink(destination: {
              CarinaNewNavigationView()
            }, label: {
              Label("Carina.new", systemImage: "plus")
            })
          }
        }
      }
    }
    .navigationTitle("Carina")
    .toolbar {
      if #available(watchOS 10, *) {
        ToolbarItem(placement: .bottomBar, content: {
          HStack {
            Spacer()
            NavigationLink(destination: {
              CarinaNewNavigationView()
            }, label: {
              Image(systemName: !currentVersionIsOutOfDate(latestVer) ? "plus" : "arrowshape.up.fill")
                .foregroundStyle(!currentVersionIsOutOfDate(latestVer) ? .primary : .secondary)
            })
          }
        })
      }
    }
    .onAppear {
      personalFeedbacks = (UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []) as! [Int]
      personalFeedbackTitles = (UserDefaults.standard.dictionary(forKey: "personalFeedbackTitles") ?? [:]) as! [Int: String]
      fetchWebPageContent(urlString: "https://fapi.darock.top:65535/iris/newver") { result in
        switch result {
          case .success(let content):
            latestVer = content.components(separatedBy: "\"")[1]
            if latestVer.contains("!") {
              latestVer = latestVer.components(separatedBy: "!")[0]
            }
          case .failure(let error):
            latestVer = currentIrisVersion
        }
      }
      var feedbackBasicData: RKCFeedback?
      for value in personalFeedbacks {
        Task {
          feedbackBasicData = await projectManager.getFeedback(byId: String(value))
          if feedbackBasicData != nil {
            personalFeedbackTitles.updateValue(feedbackBasicData!.title, forKey: value)
          }
          personalFeedbackStates.updateValue(feedbackBasicData?.state.rawValue ?? 8, forKey: value)
        }
      }
      UserDefaults.standard.set(personalFeedbackTitles, forKey: "personalFeedbackTitles")
    }
  }
}

struct CarinaNewNavigationView: View {
  @State var latestVer = ""
  var body: some View {
    Group {
      if !currentVersionIsOutOfDate(latestVer) {
        CarinaNewView()
      } else {
        VStack {
          if #available(watchOS 10, *) {
            Image(systemName: "arrowshape.up.fill")
              .font(.largeTitle)
              .bold()
          } else {
            Image(systemName: "clock.arrow.circlepath")
              .font(.largeTitle)
              .bold()
          }
          Text("Carina.update")
          HStack {
            Text(currentIrisVersion)
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
    }
    .onAppear {
      fetchWebPageContent(urlString: "https://fapi.darock.top:65535/iris/newver") { result in
        switch result {
          case .success(let content):
            latestVer = content.components(separatedBy: "\"")[1]
            if latestVer.contains("!") {
              latestVer = latestVer.components(separatedBy: "!")[0]
            }
          case .failure(let error):
            latestVer = currentIrisVersion
        }
      }
    }
  }
}
//  }

@MainActor public let carinaStates: [Int: LocalizedStringKey] = [0: "Carina.state.unmarked", 1: "Carina.state.work-as-intended", 2: "Carina.state.unable-to-fix", 3: "Carina.state.combined", 4: "Carina.state.shelved", 5: "Carina.state.fixing", 6: "Carina.state.fixed-in-future-versions", 7: "Carina.state.fixed", 8: "Carina.info.load", 9: "Carina.state.cannot-reappear", 10: "Carina.state.unrelated", 11: "Carina.state.require-more-details"]
@MainActor public let carinaStateDescription: [Int: LocalizedStringKey] = [0: "Carina.state.unmarked.description", 1: "Carina.state.work-as-intended.description", 2: "Carina.state.unable-to-fix.description", 3: "Carina.state.combined.description", 4: "Carina.state.shelved.description", 5: "Carina.state.fixing.description", 6: "Carina.state.fixed-in-future-versions.description", 7: "Carina.state.fixed.description", 8: "Carina.info.load", 9: "Carina.state.cannot-reappear.description", 10: "Carina.state.unrelated.description", 11: "Carina.state.require-more-details.description"]
@MainActor public let carinaStateColors: [Int: Color] = [0: Color.secondary, 1: Color.red, 2: Color.red, 3: Color.red, 4: Color.orange, 5: Color.orange, 6: Color.orange, 7: Color.green, 8: Color.secondary, 9: Color.red, 10: Color.red, 11: Color.orange]
@MainActor public let carinaStateIcons: [Int: String] = [0: "minus", 1: "curlybraces", 2: "xmark", 3: "arrow.triangle.merge", 4: "books.vertical", 5: "hammer", 6: "clock.badge.checkmark", 7: "checkmark", 8: "ellipsis", 9: "questionmark", 10: "bolt.horizontal", 11: "arrowshape.turn.up.backward.badge.clock"]
@MainActor public let carinaTypes: [Int: LocalizedStringKey] = [0: "Carina.type.function", 1: "Carina.type.interface", 2: "Carina.type.texts", 3: "Carina.type.suggestion"]
@MainActor public let carinaPlaces: [Int: LocalizedStringKey] = [0: "Carina.place.about", 1: "Carina.place.bookmarks", 2: "Carina.place.carina", 3: "Carina.place.history", 4: "Carina.place.passcode", 5: "Carina.place.search", 6: "Carina.place.tips", 8: "Carina.place.home", 10: "Carina.place.privacy", 11: "Carina.place.credits", 12: "Carina.place.webpage", 3000: "Carina.place.other"]

func currentVersionIsOutOfDate(_ latestVersion: String) -> Bool {
  var latestVersionSections = latestVersion.split(separator: ".")
  var currentVersionSections = currentIrisVersion.split(separator: ".")
  if latestVersion.isEmpty {
    return false
  }
  return latestVersionSections[0] > currentVersionSections[0] || latestVersionSections[1] > currentVersionSections[1] || latestVersionSections[2] > currentVersionSections[2]
}

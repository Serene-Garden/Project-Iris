//
//  OrionView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import Foundation
import RadarKitCore
import SwiftUI

struct CarinaView: View {
  @State var personalFeedbacks: [Int] = []
  @State var personalFeedbackTitles: [Int: String] = [:]
  @State var personalFeedbackStates: [Int: String] = [:]
  @State var carinaBusyState = 0
  @State var latestVer: String = ""
  var projectManager: RKCFeedbackManager = RKCFeedbackManager(projectName: "Project Iris")
  var body: some View {
//    EmptyView()
    NavigationStack {
      if !personalFeedbacks.isEmpty {
        List {
          if carinaBusyState != 0 {
            VStack(alignment: .leading) {
              HStack {
                Circle()
                  .foregroundStyle(carinaBusyStateColor[carinaBusyState] ?? Color.secondary)
                  .frame(width: 10)
                  .padding(.trailing, 7)
                Text(carinaBusyStateTitle[carinaBusyState]!)
                  .lineLimit(2)
                  .bold()
                Spacer()
              }
              Text(carinaBusyDescription[carinaBusyState]!)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
          }
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
                  .foregroundStyle(newCarinaStateColors[personalFeedbackStates[personalFeedbacks[feedbackIndex]] ?? "UNMARKED"] ?? Color.secondary)
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
      if ((UserDefaults.standard.array(forKey: "personalFeedbacksStorage") ?? []) as! [Int]).isEmpty && !personalFeedbacks.isEmpty {
        UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacksStorage")
      }
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
          personalFeedbackStates.updateValue(feedbackBasicData?.state.rawValue ?? "UNMARKED", forKey: value)
        }
      }
      UserDefaults.standard.set(personalFeedbackTitles, forKey: "personalFeedbackTitles")
      
      
      fetchWebPageContent(urlString: "https://fapi.darock.top:65535/carina/reply-status/get") { result in
        switch result {
          case .success(let content):
            carinaBusyState = Int(content) ?? 0
          case .failure(let error):
            carinaBusyState = 0
        }
      }
    }
  }
}

//  }

func currentVersionIsOutOfDate(_ latestVersion: String) -> Bool {
  var latestVersionSections = latestVersion.split(separator: ".")
  var currentVersionSections = currentIrisVersion.split(separator: ".")
  if latestVersion.isEmpty {
    return false
  }
  return latestVersionSections[0] > currentVersionSections[0] || latestVersionSections[1] > currentVersionSections[1] || latestVersionSections[2] > currentVersionSections[2]
}

func getCurrentTimezone() -> String {
  var currentTimezone = TimeZone.current
  var result = currentTimezone.identifier
//  var gmtOffsetHours = currentTimezone.secondsFromGMT()/3600
//  if gmtOffsetHours > 0 {
//    result += "(+\(gmtOffsetHours))"
//  } else if gmtOffsetHours < 0 {
//    result += "(-\(abs(gmtOffsetHours)))"
//  } else {
//    result += "(GMT)"
//  }
  return result
}


let newCarinaStateColors: [String: Color] = ["UNMARKED": .secondary, "UNDER_INVESTIGATION": .orange, "WORK_AS_EXPECTED": .red, "UNABLE_TO_FIX": .red, "DUPLICATE": .red, "FUTURE_CONSIDERATION": .orange, "LONG_TERM_PLAN": .orange, "FIXING": .orange, "FIX_PENDING_RELEASE": .orange, "FIX_COMPLETED": .green, "CANNOT_REPRODUCE": .red, "DETAILS_REQUIRED": .orange, "UNRELATED": .red, "UNDEFINED": .gray]
let newCarinaStateLocalizedKeys: [String: LocalizedStringKey] = ["UNMARKED": "Carina.new-states.unmarked", "UNDER_INVESTIGATION": "Carina.new-states.under-investigation", "WORK_AS_EXPECTED": "Carina.new-states.work-as-expected", "UNABLE_TO_FIX": "Carina.new-states.unable-to-fix", "DUPLICATE": "Carina.new-states.duplicate", "FUTURE_CONSIDERATION": "Carina.new-states.future-consideration", "LONG_TERM_PLAN": "Carina.new-states.long-term-plan", "FIXING": "Carina.new-states.fixing", "FIX_PENDING_RELEASE": "Carina.new-states.fix-pending-release", "FIX_COMPLETED": "Carina.new-states.fix-completed", "CANNOT_REPRODUCE": "Carina.new-states.cannot-reproduce", "DETAILS_REQUIRED": "Carina.new-states.details-required", "UNRELATED": "Carina.new-states.unrelated", "UNDEFINED": "Carina.new-states.undefined"]
let newCarinaStateLocalizedDescriptions: [String: LocalizedStringKey] = ["UNMARKED": "Carina.new-states.unmarked.description", "UNDER_INVESTIGATION": "Carina.new-states.under-investigation.description", "WORK_AS_EXPECTED": "Carina.new-states.work-as-expected.description.description", "UNABLE_TO_FIX": "Carina.new-states.unable-to-fix.description", "DUPLICATE": "Carina.new-states.duplicate.description", "FUTURE_CONSIDERATION": "Carina.new-states.future-consideration.description", "LONG_TERM_PLAN": "Carina.new-states.long-term-plan.description", "FIXING": "Carina.new-states.fixing.description", "FIX_PENDING_RELEASE": "Carina.new-states.fix-pending-release.description", "FIX_COMPLETED": "Carina.new-states.fix-completed.description", "CANNOT_REPRODUCE": "Carina.new-states.cannot-reproduce.description", "DETAILS_REQUIRED": "Carina.new-states.details-required.description", "UNRELATED": "Carina.new-states.unrelated.description", "UNDEFINED": "Carina.new-states.undefined.description"]
let newCarinaStateIcons: [String: String] = ["UNMARKED": "minus", "UNDER_INVESTIGATION": "magnifyingglass", "WORK_AS_EXPECTED": "curlybraces", "UNABLE_TO_FIX": "xmark", "DUPLICATE": "arrow.triangle.pull", "FUTURE_CONSIDERATION": "bolt.badge.clock", "LONG_TERM_PLAN": "books.vertical", "FIXING": "hammer", "FIX_PENDING_RELEASE": "clock.badge.checkmark", "FIX_COMPLETED": "checkmark", "CANNOT_REPRODUCE": "questionmark", "DETAILS_REQUIRED": "arrowshape.turn.up.backward.badge.clock", "UNRELATED": "bolt.horizontal", "UNDEFINED": "ellipsis.curlybraces"]

let carinaBusyStateTitle: [Int: LocalizedStringKey] = [0: "Carina.busy-state.efficient", 1: "Carina.busy-state.delayed", 2: "Carina.busy-state.busy", 3: "Carina.busy-state.standstill", 4: "Carina.busy-state.service-interruption"]
let carinaBusyDescription: [Int: LocalizedStringKey] = [0: "Carina.busy-state.efficient.description", 1: "Carina.busy-state.delayed.description", 2: "Carina.busy-state.busy.description", 3: "Carina.busy-state.standstill.description", 4: "Carina.busy-state.service-interruption.description"]
let carinaBusyStateColor: [Int: Color] = [0: .green, 1: .orange, 2: .orange, 3: .red, 4: .orange]



extension Array<RKCFormattedFile> {
  func filtered() -> Array<RKCFormattedFile> {
    var output: [RKCFormattedFile] = []
    if !self.isEmpty {
      for i in 0..<self.count {
        if self[i].isInternalHidden {
          continue
        } else if !((self[i].State != nil) || (self[i].Content != nil) || (self[i].AttachedLinks != nil) || (self[i].AttachedLinks != nil)) {
          continue
        } else {
          output.append(self[i])
        }
      }
    }
    return output
  }
}

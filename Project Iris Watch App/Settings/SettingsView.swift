//
//  SettingsView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/21.
//

import SwiftUI
import Cepheus
import Vela
import Foundation

let screenWidth = WKInterfaceDevice.current().screenBounds.size.width
let screenHeight = WKInterfaceDevice.current().screenBounds.size.height


let dateComponentsFrom = DateComponents(hour: 21)
let calendarFrom = Calendar(identifier: .gregorian)
let dateComponentsTo = DateComponents(hour: 6)
let calendarTo = Calendar(identifier: .gregorian)


struct SettingsView: View {
  @AppStorage("correctPasscode") var correctPasscode = ""
  @AppStorage("debug") var debug = false
  @AppStorage("lastBulletin") var lastBulletin: String = ""
  @AppStorage("bulletinIsNew") var bulletinIsNew = false
  @State var is_watchOS10 = false
  @State var bulletinContent = ""
  var body: some View {
    NavigationStack {
      Form {
        if todaysHoliday() == "NewYear" {
          HStack {
            Text(verbatim: "🎉")
              .font(.title3)
            Text("Settings.holiday.new-year.\(String(getCurrentYear()))")
            Spacer()
          }
        } else if todaysHoliday() == "Christmas" {
          HStack {
            Text(verbatim: "🎄")
              .font(.title3)
            Text("Settings.holiday.christmas")
            Spacer()
          }
        } else if todaysHoliday() == "AprilFools" {
          HStack {
            Text(verbatim: "🗿")
              .font(.title3)
            Text("Settings.holiday.april-fools")
            Spacer()
          }
        } else if todaysHoliday() == "ChineseNewYear" {
          HStack {
            Text(verbatim: "🎆")
              .font(.title3)
            Text("Settings.holiday.spring-festival")
            Spacer()
          }
        }
        
        NavigationLink(destination: {
          SettingsBrowseView()
        }, label: {
          HStack {
            Label("Settings.browse", systemImage: "network")
            Spacer()
            Image(systemName: "chevron.forward")
              .foregroundStyle(.secondary)
          }
        })
        NavigationLink(destination: {
          SettingsSearchView()
        }, label: {
          HStack {
            Label("Settings.search", systemImage: "magnifyingglass")
            Spacer()
            Image(systemName: "chevron.forward")
              .foregroundStyle(.secondary)
          }
        })
        NavigationLink(destination: {
          SettingsInterfaceView()
        }, label: {
          HStack {
            Label("Settings.interface", systemImage: "rectangle.on.rectangle")
            Spacer()
            Image(systemName: "chevron.forward")
              .foregroundStyle(.secondary)
          }
        })
        NavigationLink(destination: {
          SettingsAppearanceView()
        }, label: {
          HStack {
            Label(title: {
              Text("Settings.appearance")
            }, icon: {
              Image(_internalSystemName: "nightshift")
            })
            Spacer()
            Image(systemName: "chevron.forward")
              .foregroundStyle(.secondary)
          }
        })
        if #available(watchOS 10, *) {
          NavigationLink(destination: {
            PasscodeView(destination: {
              PasscodeSettingsView()
            })
          }, label: {
            HStack {
              Label("Settings.passcode", systemImage: "lock")
              Spacer()
              Image(systemName: !correctPasscode.isEmpty ? "lock": "chevron.forward")
                .foregroundStyle(.secondary)
            }
          })
        }
        NavigationLink(destination: {
          SettingsPrivacyView()
        }, label: {
          HStack {
            Label("Settings.privacy", systemImage: "hand.raised")
            Spacer()
            Image(systemName: "chevron.forward")
              .foregroundStyle(.secondary)
          }
        })
        Section {
          NavigationLink(destination: AboutView(), label: {
            HStack {
              Label("Settings.about", systemImage: "info.circle")
              Spacer()
              Image(systemName: "chevron.forward")
                .foregroundStyle(.secondary)
            }
          })
          if !bulletinContent.isEmpty {
            NavigationLink(destination: BulletinView(bulletinContent: bulletinContent), label: {
              HStack {
                Label("Settings.bulletin", systemImage: "megaphone")
                Spacer()
                if bulletinIsNew {
                  Text("Settings.bulletin.new")
                    .foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.forward")
                  .foregroundStyle(.secondary)
              }
            })
          }
//          if #available(watchOS 10, *) {
//            NavigationLink(destination: VoteView(), label: {
//              HStack {
//                Label("Settings.vote", systemImage: "chevron.up.chevron.down")
//                Spacer()
//                Image(systemName: "chevron.forward")
//                  .foregroundStyle(.secondary)
//              }
//            })
//            .hidden()
//          }
          if debug {
            NavigationLink(destination: DebugView(), label: {
              HStack {
                Label("Settings.debug", systemImage: "hammer")
                Spacer()
                Image(systemName: "chevron.forward")
                  .foregroundStyle(.secondary)
              }
            })
          }
          //          Label("Setting.language-tip", systemImage: "globe")
          //          Label(String("https://discord.gg/Qx5PXXEeW9"), systemImage: "bubble.left.and.bubble.right")
          //            .monospaced()
          //          if #available(watchOS 10.0, *) {} else {
          //            Text("Settings.watchOS9")
          //          }
        }
      }
      .navigationTitle("Home.settings")
      .onAppear {
        if #available(watchOS 10.0, *) {
          is_watchOS10 = true
        } else {
          is_watchOS10 = false
        }
        fetchWebPageContent(urlString: "https://fapi.darock.top:65535/iris/notice") { result in
          switch result {
            case .success(let content):
              bulletinContent = String(content.dropFirst().dropLast())
//              print(content)
            case .failure(let error):
//              print(error)
              bulletinContent = ""
          }
          if !bulletinIsNew && lastBulletin != bulletinContent {
            bulletinIsNew = true
          }
        }
      }
    }
  }
}

func getCurrentYear() -> Int {
  let today = Date()
  let gregorianCalendar = Calendar(identifier: .gregorian)
  let gregorianYear = gregorianCalendar.component(.year, from: today)
  return gregorianYear
}


func todaysHoliday() -> String {
  let today = Date()
  let calendar = Calendar.current
  let todaysComponents = calendar.dateComponents([.month, .day], from: today)
  let chineseCalendar = Calendar(identifier: .chinese)
  let chineseComponents = chineseCalendar.dateComponents([.month, .day], from: today)
  
  if todaysComponents.month == 1 && todaysComponents.day == 1 {
    return "NewYear"
  } else if todaysComponents.month == 12 && todaysComponents.day == 25 {
    return "Christmas"
  } else if todaysComponents.month == 4 && todaysComponents.day == 1 {
    return "AprilFools"
  } else if chineseComponents.month == 1 && chineseComponents.day == 1 && "\(languageCode)".contains("zh") {
    return "ChineseNewYear"
  } else {
    return "nil"
  }
}

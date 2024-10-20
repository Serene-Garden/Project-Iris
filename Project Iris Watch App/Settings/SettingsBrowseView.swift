//
//  SettingsBrowseView.swift
//  Project Iris
//
//  Created by ThreeManager785 on 10/3/24.
//

import SwiftUI

//MARK: --- Browse ---
struct SettingsBrowseView: View {
  @AppStorage("HideDigitalTime") var hideDigitalTime = true
  @AppStorage("ToolbarTintColor") var toolbarTintColor = 1
  @AppStorage("UseNavigationGestures") var useNavigationGestures = true
  @AppStorage("DelayedHistoryRecording") var delayedHistoryRecording = true
  @AppStorage("RequestDesktopWebsite") var requestDesktopWebsiteAsDefault = true
  @State var useLegacyBrowsingEngine: Bool = false
  var body: some View {
    List {
      Section {
        if #available(watchOS 10, *) {
          Toggle("Settings.browse.use-legacy-engine", systemImage: "macwindow.and.cursorarrow", isOn: $useLegacyBrowsingEngine)
        } else {
          Toggle("Settings.browse.use-legacy-engine", systemImage: "macwindow.badge.plus", isOn: $useLegacyBrowsingEngine)
        }
      }
      .onChange(of: useLegacyBrowsingEngine, perform: { value in
        UserDefaults.standard.set(useLegacyBrowsingEngine, forKey: "UseLegacyBrowsingEngine")
      })
      if !useLegacyBrowsingEngine {
        Section(content: {
          Picker(selection: $toolbarTintColor, content: {
            Text("Settings.browse.tint.blue").tag(1)
            Text("Settings.browse.tint.tint").tag(0)
            //            Text("Settings.browse.tint.webpage").tag(2)
          }, label: {
            Text("Settings.browse.tint")
          })
          Toggle("Settings.browse.request-desktop-website", systemImage: "desktopcomputer", isOn: $requestDesktopWebsiteAsDefault)
          Toggle("Settings.browse.hide-clock", systemImage: "clock.badge.xmark", isOn: $hideDigitalTime)
          Toggle("Settings.browse.use-navigation-gestures", systemImage: "hand.draw", isOn: $useNavigationGestures)
          Toggle("Settings.browse.delayed-historyed-recording", systemImage: "calendar.badge.clock", isOn: $delayedHistoryRecording)
        }, footer: {
          Text("Settings.browse.delayed-historyed-recording.footer")
        })
      }
    }
    .onAppear {
      useLegacyBrowsingEngine = UserDefaults.standard.bool(forKey: "UseLegacyBrowsingEngine")
    }
    .navigationTitle("Settings.browse")
  }
}

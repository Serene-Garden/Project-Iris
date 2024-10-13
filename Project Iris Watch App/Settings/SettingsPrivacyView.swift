//
//  SettingsPrivacyView.swift
//  Project Iris
//
//  Created by ThreeManager785 on 10/3/24.
//

import SwiftUI

//MARK: --- Privacy ---

struct SettingsPrivacyView: View {
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("statsCollectionIsAllowed") var statsCollectionIsAllowed = true
  @State var isClearHistoryAlertPresenting = false
  var body: some View {
    NavigationStack {
      List {
        Section("Settings.privacy.history") {
          Toggle(isOn: $isPrivateModeOn, label: {
            Label("Settings.privacy.history.privacy-mode", systemImage: "hand.raised")
          })
          Button(action: {
            isClearHistoryAlertPresenting = true
          }, label: {
            Label("Settings.privacy.history.clear-history", systemImage: "trash")
              .foregroundStyle(.red)
          })
          .alert("Settings.privacy.history.clear", isPresented: $isClearHistoryAlertPresenting, actions: {
            Button(role: .destructive, action: {
              updateHistory([])
            }, label: {
              HStack {
                Text("Settings.privacy.history.confirm")
                Spacer()
              }
            })
            Button(role: .cancel, action: {}, label: {
              Text("Settings.privacy.history.cancel")
            })
          }, message: {
            Text("Settings.privacy.history.message")
          })
        }
        Section("Settings.privacy.data") {
          Toggle(isOn: $statsCollectionIsAllowed, label: {
            Label("Settings.privacy.data.allow-collections", systemImage: "chart.bar.xaxis")
          })
          Toggle(isOn: $isCookiesAllowed, label: {
            Label("Settings.privacy.data.allow-cookies", systemImage: "server.rack")
          })
          Button(action: {
            searchButtonAction(isPrivateModeOn: false, searchField: "https://github.com/Serene-Garden/Project-Iris/blob/main/Privacy-\(languageCode!.identifier == "zh" ? "zh-cn" : "en").md", isCookiesAllowed: false, searchEngine: "")
          }, label: {
            HStack {
              Text("Settings.privacy.privacy-policy")
              Spacer()
              Image(systemName: "arrow.up.right.circle")
                .foregroundStyle(.secondary)
            }
          })
          Text("Settings.privacy.responsibility-for-internet")
        }
        Section("Settings.privacy.erase") {
          SettingsEraseElement()
        }
      }
      .navigationTitle("Settings.privacy")
    }
  }
}


struct SettingsEraseElement: View {
  @State var resettingAlertIsPresenting = false
  
  @AppStorage("currentEngine") var currentEngine = 0
  
  @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
  @AppStorage("tipAnimationSpeed") var tipAnimationSpeed = 1
  @AppStorage("appFont") var appFont = 0
  @AppStorage("appLanguage") var appLanguage = ""
  
  @AppStorage("homeToolbar1") var homeToolbar1: String = "nil"
  @AppStorage("homeToolbar2") var homeToolbar2: String = "nil"
  @AppStorage("homeToolbar3") var homeToolbar3: String = "nil"
  @AppStorage("homeToolbar4") var homeToolbar4: String = "nil"
  
  @AppStorage("homeToolbarMonogram") var homeToolbarMonogram: String = ""
  @AppStorage("homeToolbarMonogramFontIsUsingTitle3") var homeToolbarMonogramFontIsUsingTitle3 = false
  @AppStorage("homeToolbarMonogramFontIsCapitalized") var homeToolbarMonogramFontIsCapitalized = true
  @AppStorage("homeToolbarMonogramFontDesign") var homeToolbarMonogramFontDesign = 1
  @AppStorage("homeToolbarBottomBlur") var homeToolbarBottomBlur = 0
  
  @AppStorage("correctPasscode") var correctPasscode = ""
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("lockBookmarks") var lockBookmarks = false
  @AppStorage("lockHistory") var lockHistory = true
  @AppStorage("lockArchives") var lockArchives = true
  
  @AppStorage("dimmingCoefficientIndex") var dimmingCoefficientIndex = 100
  @AppStorage("globalDimming") var globalDimming = false
  @AppStorage("dimmingAtSpecificPeriod") var dimmingAtSpecificPeriod = false
  @AppStorage("AppearanceSchedule") var appearanceSchedule = 0
  
  @AppStorage("tintVoteViolet") var tintVoteViolet = false
  @AppStorage("tintVoteGreen") var tintVoteGreen = false
  
  @AppStorage("HideDigitalTime") var hideDigitalTime = true
  @AppStorage("ToolbarTintColor") var toolbarTintColor = 1
  @AppStorage("UseNavigationGestures") var useNavigationGestures = true
  @AppStorage("DelayedHistoryRecording") var delayedHistoryRecording = true
  @AppStorage("DismissAfterAction") var dismissAfterAction = true
  @AppStorage("RequestDesktopWebsite") var requestDesktopWebsiteAsDefault = false
  
  @AppStorage("LastArchiveID") var lastArchiveID = -1
  @AppStorage("SubtitleType") var subtitleType = 0
  @AppStorage("LastExtensionIID") var lastExtensionIID = -1
  
  @AppStorage("bulletinIsNew") var bulletinIsNew = false
  @Environment(\.presentationMode) var presentationMode
  var body: some View {
    //    NavigationLink(destination: {
    //      PasscodeView(destination: {
    //        ScrollView {
    //          VStack {
    //            Text("Settings.privacy.reset.settings.title")
    //              .bold()
    //            Text("Settings.privacy.reset.settings.message")
    //              .multilineTextAlignment(.center)
    //            Button(role: .destructive, action: {
    //              //Search Engines
    //              UserDefaults.standard.set(defaultSearchEngineNames, forKey: "engineNames")
    //              UserDefaults.standard.set(defaultSearchEngineLinks, forKey: "engineLinks")
    //              UserDefaults.standard.set(defaultSearchEngineEditable, forKey: "engineNameIsEditable")
    //              currentEngine = 0
    //
    //              //Home
    //              UserDefaults.standard.set([275, 40, 100], forKey: "tintColor")
    //              UserDefaults.standard.set(defaultHomeList, forKey: "homeList")
    //              homeToolbar1 = "nil"
    //              homeToolbar2 = "nil"
    //              homeToolbar3 = "nil"
    //              homeToolbar4 = "nil"
    //              homeToolbarMonogram = ""
    //              homeToolbarMonogramFontIsUsingTitle3 = false
    //              homeToolbarMonogramFontIsCapitalized = true
    //              homeToolbarMonogramFontDesign = 1
    //              homeToolbarBottomBlur = 0
    //
    //              //Interface
    //              tipConfirmRequired = false
    //              tipAnimationSpeed = 1
    //
    //              //Privacy
    //              correctPasscode = ""
    //              isPrivateModeOn = false
    //              isCookiesAllowed = false
    //              presentationMode.wrappedValue.dismiss()
    //            }, label: {
    //              Text("Settings.privacy.reset.confirm")
    //            })
    //          }
    //        }
    //      }, title: "Settings.privacy.reset.settings")
    //    }, label: {
    //      HStack {
    //        Label("Settings.privacy.reset.settings", systemImage: "gear.badge.xmark")
    //        Spacer()
    //        LockIndicator()
    //      }
    //    })
    //    .foregroundStyle(.red)
    Button(role: .destructive, action: {
      resettingAlertIsPresenting = true
    }, label: {
      Label("Settings.privacy.reset.all", systemImage: "externaldrive.badge.xmark")
        .foregroundStyle(.red)
    })
    .alert("Settings.privacy.reset.all.title", isPresented: $resettingAlertIsPresenting, actions: {
      Button(role: .destructive, action: {
        //Search Engines
        UserDefaults.standard.set(defaultSearchEngineNames, forKey: "engineNames")
        UserDefaults.standard.set(defaultSearchEngineLinks, forKey: "engineLinks")
        UserDefaults.standard.set(defaultSearchEngineEditable, forKey: "engineNameIsEditable")
        currentEngine = 0
        
        //Home
        UserDefaults.standard.set(defaultColor, forKey: "tintColor")
        UserDefaults.standard.set(defaultHomeList, forKey: "homeList")
        UserDefaults.standard.set(defaultHomeListValues, forKey: "homeListValues")
        homeToolbar1 = "nil"
        homeToolbar2 = "nil"
        homeToolbar3 = "nil"
        homeToolbar4 = "nil"
        homeToolbarMonogram = ""
        homeToolbarMonogramFontIsUsingTitle3 = false
        homeToolbarMonogramFontIsCapitalized = true
        homeToolbarMonogramFontDesign = 1
        homeToolbarBottomBlur = 0
        appFont = 0
        appLanguage = ""
        
        //Dimming
        dimmingCoefficientIndex = 100
        globalDimming = false
        dimmingAtSpecificPeriod = false
        writePlainTextFile("21:00,6:00", to: "DimTime.txt")
        appearanceSchedule = 0
        
        //Interface
        tipConfirmRequired = false
        tipAnimationSpeed = 1
        
        //Privacy
        correctPasscode = ""
        isPrivateModeOn = false
        isCookiesAllowed = false
        
        //History & Bookmarks
        UserDefaults.standard.set(0, forKey: "lastHistoryID")
        updateHistory([])
        updateBookmarkLibrary([])
        
        //Feedback
        UserDefaults.standard.set([], forKey: "personalFeedbacks")
        showTip("Settings.privacy.reset.all.done", symbol: "externaldrive.badge.xmark")
        
        //Vote
        tintVoteViolet = false
        tintVoteGreen = false
        fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/add/garden_iris_vote_tint_violet_negatives/\(Date.now.timeIntervalSince1970)") {result in}
        fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/add/garden_iris_vote_tint_green_negatives/\(Date.now.timeIntervalSince1970)") {result in}
        
        //Webpage
        hideDigitalTime = true
        toolbarTintColor = 1
        useNavigationGestures = true
        delayedHistoryRecording = true
        dismissAfterAction = true
        requestDesktopWebsiteAsDefault = false
        
        //Archive
//        lastArchiveID = -1
        subtitleType = 0
        UserDefaults.standard.set([], forKey: "ArchiveIDs")
        UserDefaults.standard.set([:], forKey: "ArchiveTitles")
        UserDefaults.standard.set([:], forKey: "ArchiveURLs")
        UserDefaults.standard.set([:], forKey: "ArchiveDates")
        
        //Extensions
        UserDefaults.standard.set([], forKey: "ExtensionIIDs")
        UserDefaults.standard.set([:], forKey: "ExtensionTitles")
        UserDefaults.standard.set([:], forKey: "ExtensionGIDs")
        
        //Bulletin
        bulletinIsNew = false
      }, label: {
        Text("Settings.privacy.reset.confirm")
      })
      Button(role: .cancel, action: {}, label: {
        Text("Settings.privacy.reset.cancel")
      })
    }, message: {
      Text("Settings.privacy.reset.all.message")
    })
  }
}

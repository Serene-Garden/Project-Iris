//
//  SettingsView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/21.
//

import SwiftUI
import Cepheus
import Vela

let screenWidth = WKInterfaceDevice.current().screenBounds.size.width
let screenHeight = WKInterfaceDevice.current().screenBounds.size.height


let dateComponentsFrom = DateComponents(hour: 21)
let calendarFrom = Calendar(identifier: .gregorian)
let dateComponentsTo = DateComponents(hour: 6)
let calendarTo = Calendar(identifier: .gregorian)
let dimmingPresetDates = (calendarFrom.date(from: dateComponentsFrom) ?? Date(), calendarTo.date(from: dateComponentsTo) ?? Date())


struct SettingsView: View {
  @AppStorage("correctPasscode") var correctPasscode = ""
  @AppStorage("debug") var debug = false
  @State var is_watchOS10 = false
  var body: some View {
    NavigationStack {
      Form {
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
          NavigationLink(destination: CreditView(), label: {
            HStack {
              Label("Settings.credits", systemImage: "fleuron")
              Spacer()
              Image(systemName: "chevron.forward")
                .foregroundStyle(.secondary)
            }
          })
          if #available(watchOS 10, *) {
            NavigationLink(destination: VoteView(), label: {
              HStack {
                Label("Settings.vote", systemImage: "chevron.up.chevron.down")
                Spacer()
                Text(verbatim: "\(1)")
                  .foregroundStyle(.secondary)
                Image(systemName: "chevron.forward")
                  .foregroundStyle(.secondary)
              }
            })
          }
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
      }
    }
  }
}

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
        Toggle("Settings.browse.use-legacy-engine", systemImage: "macwindow.and.cursorarrow", isOn: $useLegacyBrowsingEngine)
          .onChange(of: useLegacyBrowsingEngine, perform: { value in
            UserDefaults.standard.set(useLegacyBrowsingEngine, forKey: "UseLegacyBrowsingEngine")
          })
      }
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

//MARK: --- Search ---

struct SettingsSearchView: View {
  @State var engineNames: [String] = defaultSearchEngineNames as! [String]
  @State var engineLinks: [String] = defaultSearchEngineLinks as! [String]
  @State var engineNameIsEditable: [Bool] = defaultSearchEngineEditable as! [Bool]
  @AppStorage("currentEngine") var currentEngine = 0
  
  @State var showEditTips = true
  @State var displayingURL: AttributedString = ""
  @State var highlightRange: Range<AttributedString.Index>? = nil
  @State var editingEngineLink = ""
  @State var isIrisKeyIncludedInLink = true
  @State var isLinkValid = true
  @State var editingEngineName = ""
  @State var isAddingSearchEngine = false
  var body: some View {
    List {
      ForEach(0..<engineNames.count, id: \.self) { index in
        NavigationLink(destination: {
          List {
            NavigationLink(destination: {
              List {
                CepheusKeyboard(input: engineNameIsEditable[index] ? $engineNames[index] : .constant(String(localized: LocalizedStringResource(stringLiteral: engineNames[index]))), prompt: "Settings.search.edit.name")
                  .disabled(!engineNameIsEditable[index])
                  .foregroundStyle(engineNameIsEditable[index] ? .primary : .secondary)
                CepheusKeyboard(input: $editingEngineLink, prompt: "Settings.search.edit.link", autoCorrectionIsEnabled: false)
                if !isLinkValid {
                  Label("Settings.search.edit.error.invalid-link", systemImage: "exclamationmark.circle")
                    .foregroundStyle(.red)
                }
                if editingEngineLink.isEmpty {
                  Label("Settings.search.edit.tips.iris-required", systemImage: "character.magnify")
                } else if !isIrisKeyIncludedInLink {
                  Label("Settings.search.edit.warning.iris-missing", systemImage: "questionmark.circle")
                    .foregroundStyle(.yellow)
                }
                if engineNames[index].isEmpty {
                  Label("Settings.search.edit.tips.empty-name", systemImage: "questionmark.circle")
                    .foregroundStyle(.yellow)
                }
                if !engineNames[index].isEmpty && isLinkValid && isIrisKeyIncludedInLink {
                  Label("Settings.search.edit.tips.perfect", systemImage: "checkmark.circle")
                    .foregroundStyle(.green)
                }
              }
              .onAppear {
                editingEngineLink = engineLinks[index]
              }
              .onDisappear {
                if isLinkValid {
                  engineLinks[index] = editingEngineLink
                  UserDefaults.standard.set(engineNames, forKey: "engineNames")
                  UserDefaults.standard.set(engineLinks, forKey: "engineLinks")
                  UserDefaults.standard.set(engineNameIsEditable, forKey: "engineNameIsEditable")
                } else {
                  showTip("Settings.interface.home.list.failed-saving", symbol: "exclamationmark.circle")
                }
              }
              .onChange(of: editingEngineLink, perform: { value in
                isIrisKeyIncludedInLink = editingEngineLink.lowercased().contains("\\iris")
                isLinkValid = editingEngineLink.isURL()
              })
              .navigationTitle("Settings.search.edit.title")
            }, label: {
              HStack {
                VStack(alignment: .leading) {
                  Text(engineNameIsEditable[index] ? engineNames[index] : String(localized: LocalizedStringResource(stringLiteral: engineNames[index])))
                    .bold()
                  Text(displayingURL)
                    .font(.caption2)
                    .fontDesign(.monospaced)
                    .onAppear {
                      displayingURL = AttributedString(engineLinks[index].lowercased())
                      highlightRange = displayingURL.range(of: "\\iris")
                      if highlightRange != nil {
                        displayingURL[highlightRange!].inlinePresentationIntent = .stronglyEmphasized
                        displayingURL[highlightRange!].foregroundColor = .blue
                      }
                    }
                }
                Spacer()
                Image(systemName: "pencil")
                  .foregroundStyle(.secondary)
              }
            })
            Button(action: {
              currentEngine = index
            }, label: {
              Label(currentEngine == index ? "Settings.search.edit.default.true" : "Settings.search.edit.default.false", systemImage: currentEngine == index ? "star.fill" : "star")
            })
            if !engineLinks[index].lowercased().contains("\\iris") {
              Label("Settings.search.edit.warning.iris-missing", systemImage: "questionmark.circle")
                .foregroundStyle(.yellow)
            }
          }
          .navigationTitle(engineNameIsEditable[index] ? engineNames[index] : String(localized: LocalizedStringResource(stringLiteral: engineNames[index])))
        }, label: {
          HStack {
            Text(engineNameIsEditable[index] ? engineNames[index] : String(localized: LocalizedStringResource(stringLiteral: engineNames[index])))
            Spacer()
            if currentEngine == index {
              Image(systemName: "checkmark")
            }
          }
        })
      }
      .onDelete(perform: { index in
        engineNames.remove(atOffsets: index)
        engineLinks.remove(atOffsets: index)
        engineNameIsEditable.remove(atOffsets: index)
        if currentEngine == (index.first)! {
          currentEngine = 0
        } else if currentEngine > (index.first)! {
          currentEngine -= 1
        }
      })
      .onMove(perform: { oldIndex, newIndex in
        engineNames.move(fromOffsets: oldIndex, toOffset: newIndex)
        engineLinks.move(fromOffsets: oldIndex, toOffset: newIndex)
        engineNameIsEditable.move(fromOffsets: oldIndex, toOffset: newIndex)
      })
    }
    .navigationTitle("Settings.search")
    .toolbar {
      if #available(watchOS 10.0, *) {
        ToolbarItem(placement: .bottomBar) {
          HStack {
            VStack(alignment: .leading) {
              Text("Settings.search.edit-tip.title")
              Text("Settings.search.edit-tip.subtitle")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .opacity(!showEditTips ? 0 : 1)
            .animation(.easeInOut(duration: 0.3))
            .background {
              Color.clear.background(Material.ultraThin)
                .opacity(!showEditTips ? 0 : 0.8)
                .animation(.easeInOut(duration: 0.3))
                .brightness(0.1)
                .saturation(2.5)
                .frame(width: screenWidth+100, height: 100)
                .blur(radius: 10)
                .offset(y: 20)
            }
            Spacer()
            Button(action: {
              isAddingSearchEngine = true
            }, label: {
              Image(systemName: "plus")
            })
          }
        }
      }
    }
    .onAppear {
      //      homeList = UserDefaults.standard.array(forKey: "homeList")!
      engineNames = (UserDefaults.standard.array(forKey: "engineNames") ?? defaultSearchEngineNames) as! [String]
      engineLinks = (UserDefaults.standard.array(forKey: "engineLinks") ?? defaultSearchEngineLinks) as! [String]
      engineNameIsEditable = (UserDefaults.standard.array(forKey: "engineNameIsEditable") ?? defaultSearchEngineEditable) as! [Bool]
      Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
        showEditTips = false
      }
    }
    .onDisappear {
      UserDefaults.standard.set(engineNames, forKey: "engineNames")
      UserDefaults.standard.set(engineLinks, forKey: "engineLinks")
      UserDefaults.standard.set(engineNameIsEditable, forKey: "engineNameIsEditable")
    }
    .sheet(isPresented: $isAddingSearchEngine, content: {
      SettingsSearchNewPresetsView(engineNames: $engineNames, engineLinks: $engineLinks, engineNameIsEditable: $engineNameIsEditable)
    })
  }
}

struct SettingsSearchNewPresetsView: View {
  @Binding var engineNames: [String]
  @Binding var engineLinks: [String]
  @Binding var engineNameIsEditable: [Bool]
  @State var presetAvailable: Bool = false
  @State var foundPreset: Int = 0
  @Environment(\.presentationMode) var presentationMode
  var body: some View {
    NavigationStack {
      if presetAvailable {
        List {
          NavigationLink(destination: {
            List {
              ForEach(0..<defaultSearchEngineLinks.count, id: \.self) { index in
                DismissButton(action: {
                  engineNames.append(defaultSearchEngineNames[index] as! String)
                  engineLinks.append(defaultSearchEngineLinks[index] as! String)
                  engineNameIsEditable.append(false)
                  UserDefaults.standard.set(engineNames, forKey: "engineNames")
                  UserDefaults.standard.set(engineLinks, forKey: "engineLinks")
                  UserDefaults.standard.set(engineNameIsEditable, forKey: "engineNameIsEditable")
                  showTip("Settings.search.new.succeed", symbol: "checkmark")
                  presentationMode.wrappedValue.dismiss()
                }, label: {
                  Text(String(localized: LocalizedStringResource(stringLiteral: defaultSearchEngineNames[index] as! String)))
                })
                .disabled(engineLinks.contains(defaultSearchEngineLinks[index] as! String))
              }
            }
            .navigationTitle("Settings.search.new.presets")
          }, label: {
            Label("Settings.search.new.presets", systemImage: "list.star")
          })
          NavigationLink(destination: {
            SettingsSearchNewCustomizeView(engineNames: $engineNames, engineLinks: $engineLinks, engineNameIsEditable: $engineNameIsEditable)
              .onDisappear {
                presentationMode.wrappedValue.dismiss()
              }
          }, label: {
            Label("Settings.search.new.customize", systemImage: "rectangle.and.pencil.and.ellipsis")
          })
        }
      } else {
        SettingsSearchNewCustomizeView(engineNames: $engineNames, engineLinks: $engineLinks, engineNameIsEditable: $engineNameIsEditable)
      }
    }
    .onAppear {
      for presetLink in defaultSearchEngineLinks {
        for engineLink in engineLinks {
          if engineLink.contains(presetLink as! String) {
            foundPreset += 1
            break
          }
        }
      }
      presetAvailable = (foundPreset < defaultSearchEngineLinks.count)
    }
  }
}

struct SettingsSearchNewCustomizeView: View {
  @Binding var engineNames: [String]
  @Binding var engineLinks: [String]
  @Binding var engineNameIsEditable: [Bool]
  @State var editingEngineName: String = ""
  @State var editingEngineLink: String = ""
  @State var isLinkValid = true
  @State var isIrisKeyIncludedInLink = false
  var body: some View {
    List {
      CepheusKeyboard(input: $editingEngineName, prompt: "Settings.search.edit.name")
      CepheusKeyboard(input: $editingEngineLink, prompt: "Settings.search.edit.link", autoCorrectionIsEnabled: false)
      if editingEngineLink.isEmpty {
        Label("Settings.search.edit.tips.iris-required", systemImage: "character.magnify")
      } else if !isIrisKeyIncludedInLink {
        Label("Settings.search.edit.warning.iris-missing", systemImage: "questionmark.circle")
          .foregroundStyle(.yellow)
      }
      if !isLinkValid {
        Label("Settings.search.edit.error.invalid-link", systemImage: "exclamationmark.circle")
          .foregroundStyle(.red)
      }
      if editingEngineName.isEmpty {
        Label("Settings.search.edit.tips.empty-name", systemImage: "questionmark.circle")
          .foregroundStyle(.yellow)
      }
      if !editingEngineName.isEmpty && isLinkValid && isIrisKeyIncludedInLink {
        Label("Settings.search.edit.tips.perfect", systemImage: "checkmark.circle")
          .foregroundStyle(.green)
      }
    }
    .onAppear {
      editingEngineName = ""
      editingEngineLink = ""
      isLinkValid = false
    }
    .onChange(of: editingEngineLink, perform: { value in
      isIrisKeyIncludedInLink = editingEngineLink.lowercased().contains("\\iris")
      isLinkValid = editingEngineLink.isURL()
    })
    .toolbar {
      if #available(watchOS 10, *) {
        ToolbarItemGroup(placement: .topBarTrailing, content: {
          DismissButton(action: {
            engineNames.append(editingEngineName)
            engineLinks.append(editingEngineLink)
            engineNameIsEditable.append(true)
            UserDefaults.standard.set(engineNames, forKey: "engineNames")
            UserDefaults.standard.set(engineLinks, forKey: "engineLinks")
            UserDefaults.standard.set(engineNameIsEditable, forKey: "engineNameIsEditable")
            showTip("Settings.search.new.succeed", symbol: "checkmark")
          }, label: {
            Label("Settings.interface.home.toolbar.done", systemImage: "checkmark")
            //        Spacer()
            //        Image(systemName: "chevron.backward")
            //          .foregroundStyle(.secondary)
          })
          .disabled(!isLinkValid)
        })
      }
    }
    .navigationTitle("Settings.search.new.title")
  }
}


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

//MARK: --- Advanced ---

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
  
  @AppStorage("dimmingCoefficientIndex") var dimmingCoefficientIndex = 100
  @AppStorage("globalDimming") var globalDimming = false
  @AppStorage("dimmingAtSpecificPeriod") var dimmingAtSpecificPeriod = false
  
  @AppStorage("tintVoteViolet") var tintVoteViolet = false
  @AppStorage("tintVoteGreen") var tintVoteGreen = false
  
  @AppStorage("HideDigitalTime") var hideDigitalTime = true
  @AppStorage("ToolbarTintColor") var toolbarTintColor = 1
  @AppStorage("UseNavigationGestures") var useNavigationGestures = true
  @AppStorage("DelayedHistoryRecording") var delayedHistoryRecording = true
  @AppStorage("DismissAfterAction") var dismissAfterAction = true
  @AppStorage("RequestDesktopWebsite") var requestDesktopWebsiteAsDefault = false
  
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
        writeDimTime(from: dimmingPresetDates.0, to: dimmingPresetDates.1)
        
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

struct DebugView: View {
  @AppStorage("debug") var debug = false
  @AppStorage("poemIsDiscovered") var poemIsDiscovered = false
  @AppStorage("userLatestVersion") var userLatestVersion = "0.0.0"
  @AppStorage("DismissAfterAction") var dismissAfterAction = true
  @State var newCarinaId: String = ""
  var body: some View {
    List {
      NavigationLink(destination: {
        List {
          Text(getSettingsForAppdiagnose() ?? "Failed")
            .fontDesign(.monospaced)
        }
      }, label: {
        Label("Debug.get-all-values", systemImage: "list.bullet")
      })
      Toggle(isOn: $poemIsDiscovered, label: {
        Label("Debug.poem-is-discovered", systemImage: "sparkles")
      })
      Toggle(isOn: $debug, label: {
        Label("Debug.debug", systemImage: "hammer")
      })
      Toggle(isOn: $dismissAfterAction, label: {
        Label("Debug.dismissAfterAction", systemImage: "hammer")
      })
      CepheusKeyboard(input: $userLatestVersion, prompt: "userLatestVersion")
      NavigationLink(destination: {
        PasscodeInputView(destination: {Text(verbatim: "1")})
      }, label: {
        Text(verbatim: "PasscodeInputView")
      })
      CepheusKeyboard(input: $newCarinaId)
      Button(action: {
        var carinaFeedbacks = (UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []) as! [Int]
        carinaFeedbacks.append(Int(newCarinaId) ?? 0)
        UserDefaults.standard.set(carinaFeedbacks, forKey: "personalFeedbacks")
        newCarinaId = ""
      }, label: {
        Label("Debug.carina.add", systemImage: "plus")
      })
      NavigationLink(destination: {
        CarinaDetailView(carinaID: Int(newCarinaId) ?? 0)
      }, label: {
        Label("Debug.carina.view", systemImage: "exclamationmark.bubble")
      })
      Button(action: {
        showTip("Debug.debug")
      }, label: {
        Label(String("tip"), systemImage: "sparkles")
      })
    }
    .navigationTitle("Debug")
  }
}

func getSettingsForAppdiagnose(dataProcessor: (inout [String: Any]) -> Void = { _ in }) -> String? {
  let prefPath = NSHomeDirectory() + "/Library/Preferences/\(Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String).plist"
  if let plistData = FileManager.default.contents(atPath: prefPath) {
    do {
      if var plistObject = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
        dataProcessor(&plistObject)
        let jsonData = try JSONSerialization.data(withJSONObject: plistObject)
        return String(decoding: jsonData, as: UTF8.self)
      }
    } catch {
      print(error)
    }
  }
  return nil
}


extension Color {
  func HSB_values() -> (Int, Int, Int, CGFloat) {
    let color = UIColor(self)
    var hue: CGFloat = -1
    var saturation: CGFloat = -1
    var brightness: CGFloat = -1
    var opacity: CGFloat = -1
    _ = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &opacity)
    return (Int(hue*359), Int(saturation*100), Int(brightness*100), opacity)
  }
}

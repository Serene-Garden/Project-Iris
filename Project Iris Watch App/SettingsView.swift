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

struct SettingsView: View {
  @AppStorage("correctPasscode") var correctPasscode = ""
  @AppStorage("debug") var debug = false
  @State var is_watchOS10 = false
  var body: some View {
    NavigationStack {
      Form {
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
        ToolbarItemGroup(placement: .bottomBar, content: {
          HStack {
            Spacer()
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
          }
        })
      }
    }
    .navigationTitle("Settings.search.new.title")
  }
}

//MARK: --- Interface ---

struct SettingsInterfaceView: View {
  @AppStorage("tipConfirmRequired") var tipConfirmRequired = false
  @AppStorage("tipAnimationSpeed") var tipAnimationSpeed = 1
  @AppStorage("homeToolbar1") var homeToolbar1: String = "nil"
  @AppStorage("homeToolbar2") var homeToolbar2: String = "nil"
  @AppStorage("homeToolbar3") var homeToolbar3: String = "nil"
  @AppStorage("homeToolbar4") var homeToolbar4: String = "nil"
  @AppStorage("homeToolbarMonogram") var homeToolbarMonogram: String = ""
  @AppStorage("homeToolbarMonogramFontIsUsingTitle3") var homeToolbarMonogramFontIsUsingTitle3 = false
  @AppStorage("homeToolbarMonogramFontIsCapitalized") var homeToolbarMonogramFontIsCapitalized = true
  @AppStorage("homeToolbarMonogramFontDesign") var homeToolbarMonogramFontDesign = 1
  @AppStorage("homeToolbarBottomBlur") var homeToolbarBottomBlur = 0
  @AppStorage("leftSwipeSearchButton") var leftSwipeSearchButton = 0
  @AppStorage("rightSwipeSearchButton") var rightSwipeSearchButton = 3
  @AppStorage("appFont") var appFont = 0
  @State var tintColorValues: [Any] = [275, 40, 100]
  @State var tintColor = Color(hue: 275/359, saturation: 40/100, brightness: 100/100)
  @State var isToolbarOnSelect = false
  //  @State var editingToolbar = 0
  //  @Environment(\.dismiss) var dismiss
  let fontDesign: [Int: Font.Design] = [0: .default, 1: .rounded, 2: .monospaced, 3: .serif]
  var body: some View {
    NavigationStack {
      List {
        if #available(watchOS 10.0, *) {
          Section("Settings.interface.home") {
            VelaPicker(color: $tintColor, defaultColor: Color(hue: 275/359, saturation: 40/100, brightness: 100/100), allowOpacity: false, HSB_primary: true, label: {
              Text("Settings.interface.home.color")
            }, onSubmit: {
              UserDefaults.standard.set([tintColor.HSB_values().0, tintColor.HSB_values().1, tintColor.HSB_values().2], forKey: "tintColor")
            })
            NavigationLink(destination: {
              SettingsInterfaceHomeListEditView()
                .navigationTitle("Settings.interface.home.list.title")
            }, label: {
              Text("Settings.interface.home.list")
            })
            //          if #available(watchOS 10.0, *) {
            NavigationLink(/*isActive: $showToolbarEditingSheet, */destination: {
              SettingsInterfaceHomeToolbarEditView()
            }, label: {
              Text("Settings.interface.home.toolbar")
            })
          }
          .onAppear {
            if (UserDefaults.standard.array(forKey: "tintColor") ?? []).isEmpty {
              UserDefaults.standard.set([275, 40, 100], forKey: "tintColor")
            }
            tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? [275, 40, 100]
            tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
            if !homeToolbarMonogram.isEmpty {
              homeToolbarBottomBlur = 1
            } else {
              homeToolbarBottomBlur = 0
            }
          }
          .onChange(of: homeToolbarMonogram, perform: { value in
            if !homeToolbarMonogram.isEmpty {
              homeToolbarBottomBlur = 1
            } else {
              homeToolbarBottomBlur = 0
            }
          })
        }
        Section(content: {
          CepheusEnablingToggle(showSymbol: true)
          if #available(watchOS 10.0, *) {
            NavigationLink(destination: {
              CepheusSettingsView()
            }, label: {
              Label("Settings.keyboard.learn-more", systemImage: "keyboard.badge.ellipsis")
            })
          }
        }, header: {
          Text("Settings.keyboard")
        }, footer: {
          if #available(watchOS 10.0, *) {
            Text("Powered by Garden Cepheus")
          } else {
            Text("Settings.keyboard.unavailable")
          }
        })
        
        Section("Settings.interface.search-button") {
          Picker("Settings.interface.search-button.swipe.left", selection: $leftSwipeSearchButton) {
            Text("Settings.interface.search-button.swipe.none")
              .tag(0)
            Text("Settings.interface.search-button.swipe.privacy-mode")
              .tag(1)
            Text("Settings.interface.search-button.swipe.search")
              .tag(2)
            Text("Settings.interface.search-button.swipe.customize")
              .tag(3)
          }
          Picker("Settings.interface.search-button.swipe.right", selection: $rightSwipeSearchButton) {
            Text("Settings.interface.search-button.swipe.none")
              .tag(0)
            Text("Settings.interface.search-button.swipe.privacy-mode")
              .tag(1)
            Text("Settings.interface.search-button.swipe.search")
              .tag(2)
            Text("Settings.interface.search-button.swipe.customize")
              .tag(3)
          }
        }
        
        Section("Settings.interface.tip") {
          Toggle("Settings.interface.tip.confirm", isOn: $tipConfirmRequired)
          Picker("Settings.interface.tip.speed", selection: $tipAnimationSpeed) {
            Text("Settings.interface.tip.speed.fast")
              .tag(0)
            Text("Settings.interface.tip.speed.default")
              .tag(1)
            Text("Settings.interface.tip.speed.slow")
              .tag(2)
            Text("Settings.interface.tip.speed.very-slow")
              .tag(3)
          }
        }
        
        if #available(watchOS 10.0, *) {
          Section("Settings.interface.others") {
            NavigationLink(destination: {
              List {
                Section(content: {
                  Picker("Settings.interface.home.blur", selection: $homeToolbarBottomBlur) {
                    Text("Settings.interface.home.blur.none").tag(0)
                    Text("Settings.interface.home.blur.thin").tag(1)
                    Text("Settings.interface.home.blur.thick").tag(2)
                  }
                  Picker("Settings.interface.advanced.font", selection: $appFont) {
                    Text("Settings.interface.advanced.font.default").tag(0).fontDesign(.default)
                    Text("Settings.interface.advanced.font.rounded").tag(1).fontDesign(.rounded)
                    Text("Settings.interface.advanced.font.serif").tag(2).fontDesign(.serif)
                  }
                }, footer: {
                  Text("Settings.interface.advanced.footer")
                })
              }
              .navigationTitle("Settings.interface.advanced")
            }, label: {
              HStack {
                Label("Settings.interface.advanced", systemImage: "hammer")
                Spacer()
                Image(systemName: "chevron.forward")
                  .foregroundStyle(.secondary)
              }
            })
          }
        }
      }
      .navigationTitle("Settings.interface")
    }
  }
}

struct SettingsInterfaceHomeToolbarEditView: View {
  @AppStorage("homeToolbar1") var homeToolbar1: String = "nil"
  @AppStorage("homeToolbar2") var homeToolbar2: String = "nil"
  @AppStorage("homeToolbar3") var homeToolbar3: String = "nil"
  @AppStorage("homeToolbar4") var homeToolbar4: String = "nil"
  @AppStorage("homeToolbarMonogram") var homeToolbarMonogram: String = ""
  @AppStorage("homeToolbarMonogramFontIsUsingTitle3") var homeToolbarMonogramFontIsUsingTitle3 = false
  @AppStorage("homeToolbarMonogramFontIsCapitalized") var homeToolbarMonogramFontIsCapitalized = true
  @AppStorage("homeToolbarMonogramFontDesign") var homeToolbarMonogramFontDesign = 1
  @State var homeList: [String] = (UserDefaults.standard.array(forKey: "homeList") ?? defaultHomeList) as! [String]
  @State var disabledEdits: Int = 0
  let fontDesign: [Int: Font.Design] = [0: .default, 1: .rounded, 2: .monospaced, 3: .serif]
  var body: some View {
    if #available(watchOS 10.0, *) {
      List {
        Label("Settings.interface.home.toolbar.description", systemImage: "pencil")
        NavigationLink(destination: {
          List {
            Toggle(isOn: $homeToolbarMonogramFontIsUsingTitle3, label: {
              Text("Settings.interface.home.toolbar.monogram.config.size")
            })
            Toggle(isOn: $homeToolbarMonogramFontIsCapitalized, label: {
              Text("Settings.interface.home.toolbar.monogram.config.capitalization")
            })
            Picker("Settings.interface.home.toolbar.monogram.config.design", selection: $homeToolbarMonogramFontDesign) {
              /*Text(verbatim: "Aa ") + */Text("Settings.interface.home.toolbar.monogram.config.design.default")
                .tag(0)
                .fontDesign(.default)
              /*Text(verbatim: "Aa ") + */Text("Settings.interface.home.toolbar.monogram.config.design.rounded")
                .tag(1)
                .fontDesign(.rounded)
              /*Text(verbatim: "Aa ") + */Text("Settings.interface.home.toolbar.monogram.config.design.mono")
                .tag(2)
                .fontDesign(.monospaced)
              /*Text(verbatim: "Aa ") + */Text("Settings.interface.home.toolbar.monogram.config.design.serif")
                .tag(3)
                .fontDesign(.serif)
            }
            
          }
          .navigationTitle("Settings.interface.home.toolbar.monogram.config")
        }, label: {
          HStack {
            Label("Settings.interface.home.toolbar.monogram.button", systemImage: "signature")
            Spacer()
            Image(systemName: "chevron.forward")
              .foregroundStyle(.secondary)
          }
        })
        DismissButton(action: {
        }, label: {
          HStack {
            Label("Settings.interface.home.toolbar.done", systemImage: "checkmark")
            Spacer()
            Image(systemName: "chevron.backward")
              .foregroundStyle(.secondary)
          }
        })
        Button(role: .destructive, action: {
          homeToolbarMonogram = ""
        }, label: {
          Label("Settings.interface.home.toolbar.monogram.config.clear", systemImage: "trash")
            .foregroundColor(.red)
        })
      }
      .navigationTitle("Settings.interface.home.toolbar.title")
      .navigationBarBackButtonHidden()
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          SettingsInterfaceHomeToolbarPicker(toolbar: $homeToolbar1)
            .disabled(disabledEdits == 1)
        }
        ToolbarItem(placement: .topBarTrailing) {
          SettingsInterfaceHomeToolbarPicker(toolbar: $homeToolbar2)
            .disabled(disabledEdits == 2)
        }
        ToolbarItemGroup(placement: .bottomBar) {
          HStack {
            SettingsInterfaceHomeToolbarPicker(toolbar: $homeToolbar3)
              .disabled(disabledEdits == 3)
            Spacer()
            CepheusKeyboard(input: $homeToolbarMonogram, prompt: "Settings.interface.home.toolbar.monogram.prompt", style: "link", label: {
              Text(homeToolbarMonogram.isEmpty ? "MONOGRAM" : homeToolbarMonogram)
                .font(homeToolbarMonogramFontIsUsingTitle3 ? .title3 : .body)
                .fontDesign(fontDesign[homeToolbarMonogramFontDesign])
                .textCase(homeToolbarMonogramFontIsCapitalized ? .uppercase : nil)
                .foregroundColor(homeToolbarMonogram.isEmpty ? .secondary : .accentColor)
                .lineLimit(1)
            })
            .buttonStyle(.borderless)
            Spacer()
            SettingsInterfaceHomeToolbarPicker(toolbar: $homeToolbar4)
              .disabled(disabledEdits == 4)
          }
          .background {
            Color.clear.background(Material.ultraThin)
              .opacity(0.8)
              .brightness(0.1)
              .saturation(2.5)
              .frame(width: screenWidth+100, height: 100)
              .blur(radius: 10)
              .offset(y: 20)
          }
        }
      }
      .onAppear {
        disabledEdits = whichButtonShouldBeDisabled(homeList, homeToolbar1: homeToolbar1, homeToolbar2: homeToolbar2, homeToolbar3: homeToolbar3, homeToolbar4: homeToolbar4)
      }
      .onChange(of: homeToolbar1, perform: { value in
        disabledEdits = whichButtonShouldBeDisabled(homeList, homeToolbar1: homeToolbar1, homeToolbar2: homeToolbar2, homeToolbar3: homeToolbar3, homeToolbar4: homeToolbar4)
      })
      .onChange(of: homeToolbar2, perform: { value in
        disabledEdits = whichButtonShouldBeDisabled(homeList, homeToolbar1: homeToolbar1, homeToolbar2: homeToolbar2, homeToolbar3: homeToolbar3, homeToolbar4: homeToolbar4)
      })
      .onChange(of: homeToolbar3, perform: { value in
        disabledEdits = whichButtonShouldBeDisabled(homeList, homeToolbar1: homeToolbar1, homeToolbar2: homeToolbar2, homeToolbar3: homeToolbar3, homeToolbar4: homeToolbar4)
      })
      .onChange(of: homeToolbar4, perform: { value in
        disabledEdits = whichButtonShouldBeDisabled(homeList, homeToolbar1: homeToolbar1, homeToolbar2: homeToolbar2, homeToolbar3: homeToolbar3, homeToolbar4: homeToolbar4)
      })
    }
  }
}

func whichButtonShouldBeDisabled(_ homeList: [String], homeToolbar1: String, homeToolbar2: String, homeToolbar3: String, homeToolbar4: String) -> Int {
  if !homeList.contains("settings") {
    if homeToolbar1 == "settings" && homeToolbar2 != "settings" && homeToolbar3 != "settings" && homeToolbar4 != "settings" {
      return 1
    } else if homeToolbar1 != "settings" && homeToolbar2 == "settings" && homeToolbar3 != "settings" && homeToolbar4 != "settings" {
      return 2
    } else if homeToolbar1 != "settings" && homeToolbar2 != "settings" && homeToolbar3 == "settings" && homeToolbar4 != "settings" {
      return 3
    } else if homeToolbar1 != "settings" && homeToolbar2 != "settings" && homeToolbar3 != "settings" && homeToolbar4 == "settings" {
      return 4
    } else {
      return 0
    }
  } else {
    return 0
  }
}

struct SettingsInterfaceHomeListEditView: View {
  @State var homeList: [Any] = ["settings"]
  @State var homeListEditing: [String] = ["settings"]
  @State var homeListValues: [Any] = ["nil"]
  @State var homeListValuesEditing: [String] = ["nil"]
  
  @State var homeCurrentlyEditingListElement = 0
  @State var homeListElementIsEditing = false
  @State var homeListElementIsAdding = false
  @State var homeListError: [String] = []
  @State var homeListErrorLines: [Int] = []
  @State var settingsIsFound = true
  @State var settingsIsInList = true
  @State var showErrorList = false
  @State var showEditTips = true
  @State var showBookmarkEditSheet = false
  @State var onFocusEditingItem = 0
  
  @State var bookmarks: [(Bool, String, String, [(Bool, String, String, String)])] = []

  @AppStorage("homeToolbar1") var homeToolbar1: String = "nil"
  @AppStorage("homeToolbar2") var homeToolbar2: String = "nil"
  @AppStorage("homeToolbar3") var homeToolbar3: String = "nil"
  @AppStorage("homeToolbar4") var homeToolbar4: String = "nil"
  @AppStorage("homeListSettingsIsInList") var homeListSettingsIsInList = true
  
  let listPickerValue = ["|", "search-field", "search-button", "bookmarks", "history", "privacy", "settings", "carina", "update-indicator", "bookmark-link"]
  let listPickerName: [LocalizedStringKey] = ["Settings.interface.home.list.selection.space", "Settings.interface.home.list.selection.search-field", "Settings.interface.home.list.selection.search-button", "Settings.interface.home.list.selection.bookmarks", "Settings.interface.home.list.selection.history", "Settings.interface.home.list.selection.privacy", "Settings.interface.home.list.selection.settings", "Settings.interface.home.list.selection.carina", "Settings.interface.home.list.selection.update-indicator", "Settings.interface.home.list.selection.bookmark-link"]
  let listPickerSymbol = ["arrow.up.and.line.horizontal.and.arrow.down", "character.cursor.ibeam", "magnifyingglass", "bookmark", "clock", "hand.raised", "gear", "exclamationmark.bubble", "clock.badge", "books.vertical"]
  let listElementName: [String: LocalizedStringKey] = ["|": "Settings.interface.home.list.selection.space", "search-field": "Settings.interface.home.list.selection.search-field", "search-button": "Settings.interface.home.list.selection.search-button", "bookmarks": "Settings.interface.home.list.selection.bookmarks", "history": "Settings.interface.home.list.selection.history", "privacy": "Settings.interface.home.list.selection.privacy", "settings": "Settings.interface.home.list.selection.settings", "carina": "Settings.interface.home.list.selection.carina", "update-indicator": "Settings.interface.home.list.selection.update-indicator", "bookmark-link": "Settings.interface.home.list.selection.bookmark-link"]
  let listElementSymbol = ["|": "arrow.up.and.line.horizontal.and.arrow.down", "search-field": "character.cursor.ibeam", "search-button": "magnifyingglass", "bookmarks": "bookmark", "history": "clock", "privacy": "hand.raised", "settings": "gear", "carina": "exclamationmark.bubble", "update-indicator": "clock.badge", "bookmark-link": "books.vertical"]
  

  var body: some View {
    if #available(watchOS 10, *) {
      List {
        ForEach(0..<homeListEditing.count, id: \.self) { index in
          //        Button(action: {
          //          homeCurrentlyEditingListElement = index
          //          homeListElementIsEditing = true
          //        }, label: {
          HStack {
            Image(systemName: listElementSymbol[homeListEditing[index]] ?? "questionmark")
            VStack(alignment: .leading) {
              Text(listElementName[homeListEditing[index]] ?? "Settings.interface.home.list.selection.unknown")
              if homeListEditing[index] == "bookmark-link" {
                Text(getBookmarkLinkDisplayNames(arraySafeAccess(homeListValuesEditing, element: index) ?? "nil"))
                  .font(.caption)
                  .foregroundStyle(.secondary)
                //              Text("\(arraySafeAccess(homeListValuesEditing[index].components(separatedBy: "/"), element: 0) ?? String(localized: "Settings.interface.home.list.value.unknown"))")
                //              Text("\(arraySafeAccess(homeListValuesEditing[index].components(separatedBy: "/"), element: 0) ?? "Settings.interface.home.list.value.unknown") - \()")
              }
            }
            Spacer()
          }
          .onTapGesture {
            onFocusEditingItem = index
            showBookmarkEditSheet = true
          }
          //        })
        }
        .onDelete(perform: { index in
          homeListEditing.remove(atOffsets: index)
          homeListValuesEditing.remove(atOffsets: index)
        })
        .onMove(perform: { oldIndex, newIndex in
          homeListEditing.move(fromOffsets: oldIndex, toOffset: newIndex)
          homeListValuesEditing.move(fromOffsets: oldIndex, toOffset: newIndex)
        })
      }
      .sheet(isPresented: $showBookmarkEditSheet, content: {
        NavigationStack {
          if !bookmarks.isEmpty {
            List {
              ForEach(0..<bookmarks.count, id: \.self) { groupIndex in
                NavigationLink(destination: {
                  Group {
                    if !bookmarks[groupIndex].3.isEmpty {
                      List {
                        ForEach(0..<bookmarks[groupIndex].3.count, id: \.self) { bookmarkIndex in
                          Button(action: {
                            homeListValuesEditing[onFocusEditingItem] = "\(groupIndex)/\(bookmarkIndex)"
                            showBookmarkEditSheet = false
                          }, label: {
                            HStack {
                              if bookmarks[groupIndex].3[bookmarkIndex].0 { //isEmoji
                                Text(bookmarks[groupIndex].3[bookmarkIndex].1)
                                  .font(.title3)
                              } else {
                                Image(systemName: bookmarks[groupIndex].3[bookmarkIndex].1)
                              }
                              Text(bookmarks[groupIndex].3[bookmarkIndex].2)
                              Spacer()
                              if String(groupIndex) == homeListValuesEditing[onFocusEditingItem].components(separatedBy: "/").first && String(bookmarkIndex) == homeListValuesEditing[onFocusEditingItem].components(separatedBy: "/").last {
                                Image(systemName: "checkmark")
                              }
                            }
                          })
                        }
                      }
                    } else {
                      ContentUnavailableView {
                        Label("Bookmark.item.empty", systemImage: "bookmark")
                      } description: {
                        Text("Bookmark.item.empty.description")
                      }
                    }
                  }
                  .navigationTitle(bookmarks[groupIndex].2)
                }, label: {
                  HStack {
                    if bookmarks[groupIndex].0 { //isEmoji
                      Text(bookmarks[groupIndex].1)
                        .font(.title3)
                    } else {
                      Image(systemName: bookmarks[groupIndex].1)
                    }
                    Text(bookmarks[groupIndex].2)
                    Spacer()
                  }
                })
              }
            }
          } else {
            ContentUnavailableView {
              Label("Bookmark.group.empty", systemImage: "books.vertical")
            } description: {
              Text("Bookmark.group.empty.description")
            }
          }
        }
        .navigationTitle("Settings.interface.home.list.bookmark-link.select")
      })
//      .sheet(isPresented: $homeListElementIsEditing, content: {
//        List {
//          ForEach(0..<listPickerValue.count, id: \.self) { index in
//            DismissButton(action: {
//              homeListEditing[index] = listPickerValue[index]
//            }, label: {
//              Label(listPickerName[index], systemImage: listPickerSymbol[index])
//            })
//          }
//        }
//      })
      .sheet(isPresented: $showErrorList, content: {
        List {
          Section(content: {
            ForEach(0..<homeListError.count, id: \.self) { error in
              Group {
                VStack(alignment: .leading) {
                  HStack {
                    Text(HomeListTipTitle([homeListError[error]]))
                      .bold()
                    Spacer()
                    if homeListErrorLines[error] >= 0 {
                      Text("#\(homeListErrorLines[error] + 1)")
                        .foregroundStyle(.secondary)
                        .fontDesign(.monospaced)
                    }
                  }
                  Text(HomeListTipDescription(homeListError[error]))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                }
              }
            }
          }, footer: {
            Text("Settings.interface.home.list.error.footer")
          })
          Button(action: {
            homeListEditing = defaultHomeList as! [String]
            homeListValuesEditing = defaultHomeListValues as! [String]
          }, label: {
            Text("Settings.interface.home.list.error.reset")
              .foregroundStyle(.red)
          })
        }
        .navigationTitle("Settings.interface.home.list.error")
      })
      .toolbar {
        if #available(watchOS 10.0, *) {
          ToolbarItem(placement: .bottomBar) {
            HStack {
              VStack(alignment: .leading) {
                Text(showEditTips ? "Settings.interface.home.list.edit-tip.title" : HomeListTipTitle(homeListError))
                Text(showEditTips ? "Settings.interface.home.list.edit-tip.subtitle" : HomeListTipSubtitle(homeListError))
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
              .opacity((!showEditTips && homeListError.isEmpty) ? 0 : 1)
              .animation(.easeInOut(duration: 0.3))
              .background {
                Color.clear.background(Material.ultraThin)
                  .opacity((!showEditTips && homeListError.isEmpty) ? 0 : 0.8)
                  .animation(.easeInOut(duration: 0.3))
                  .brightness(0.1)
                  .saturation(2.5)
                  .frame(width: screenWidth+100, height: 100)
                  .blur(radius: 10)
                  .offset(y: 20)
              }
              .onTapGesture(perform: {
                if !showEditTips {
                  showErrorList = true
                }
              })
              Spacer()
              Button(action: {
                homeListElementIsAdding = true
              }, label: {
                Image(systemName: "plus")
              })
              .sheet(isPresented: $homeListElementIsAdding, content: {
                List {
                  ForEach(0..<listPickerValue.count, id: \.self) { index in
                    DismissButton(action: {
                      homeListEditing.append(listPickerValue[index])
                      homeListValuesEditing.append("nil")
                    }, label: {
                      Label(listPickerName[index], systemImage: listPickerSymbol[index])
                    })
                  }
                }
              })
            }
          }
        }
      }
      .onChange(of: homeListEditing, perform: { value in
        //      print(homeListEditing)
        settingsIsFound = false
        settingsIsInList = false
        homeListError = []
        homeListErrorLines = []
        for i in 0..<homeListEditing.count {
          if homeListEditing[i] == "|" {
            if i == 0 {
              homeListError.append("top")
              homeListErrorLines.append(0)
            } else if i == homeListEditing.count-1 {
              homeListError.append("bottom")
              homeListErrorLines.append(i)
            }
            if i < homeListEditing.count-1 {
              if homeListEditing[i+1] == "|" {
                homeListError.append("close")
                homeListErrorLines.append(i)
              }
            }
          }
          if homeListEditing[i] == "settings" {
            settingsIsFound = true
            //          print(homeListEditing)
            settingsIsInList = true
          }
        }
        if !settingsIsFound {
          settingsIsInList = false
        }
        if homeToolbar1 == "settings" || homeToolbar2 == "settings" || homeToolbar3 == "settings" || homeToolbar4 == "settings" {
          settingsIsFound = true
        }
        if !settingsIsFound {
          homeListError.append("settings-missing")
          homeListErrorLines.append(-1)
        }
        if homeListEditing.count > 100 {
          homeListError.append("too-long")
          homeListErrorLines.append(100)
        }
      })
      .onAppear {
        //      homeList = UserDefaults.standard.array(forKey: "homeList")!
        homeList = UserDefaults.standard.array(forKey: "homeList") ?? defaultHomeList
        homeListValues = UserDefaults.standard.array(forKey: "homeListValues") ?? [Any](repeating: "nil", count: homeList.count)
        homeListEditing = homeList as! [String]
        homeListValuesEditing = homeListValues as! [String]
        bookmarks = getBookmarkLibrary()
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
          showEditTips = false
        }
      }
      .onDisappear {
        if homeListError.isEmpty {
          homeList = homeListEditing as [Any]
          homeListValues = homeListValuesEditing as [Any]
          print(homeListValuesEditing)
          print(homeListValues)
          UserDefaults.standard.set(homeList, forKey: "homeList")
          UserDefaults.standard.set(homeListValues, forKey: "homeListValues")
        } else {
          showTip("Settings.interface.home.list.failed-saving", symbol: "exclamationmark.circle")
        }
      }
    }
  }
}

@MainActor func getBookmarkLinkDisplayNames(_ itemValue: String) -> String {
  var itemValueSeperated = itemValue.components(separatedBy: "/")
  var bookmarkGroupName = ""
  var bookmarkItemName = ""
  let bookmarks = getBookmarkLibrary()
  if (arraySafeAccess(itemValueSeperated, element: 0) ?? "nil") == "nil" {
//    print(itemValue)
//    print(1)
    return String(localized: "Settings.interface.home.list.value.unknown")
  } else if Int(itemValueSeperated[0]) != nil  {
    bookmarkGroupName = bookmarks[Int(itemValueSeperated[0])!].2
    if arraySafeAccess(itemValueSeperated, element: 1) != nil {
      bookmarkItemName = bookmarks[Int(itemValueSeperated[0])!].3[Int(itemValueSeperated[1])!].2
      return "\(bookmarkGroupName) - \(bookmarkItemName)"
    } else {
//      print(itemValue)
//      print(2)
      return String(localized: "Settings.interface.home.list.value.unknown")
    }
  } else {
//    print(itemValue)
//    print(3)
    return String(localized: "Settings.interface.home.list.value.unknown")
  }
//  Text("\(arraySafeAccess(homeListValuesEditing[index].components(separatedBy: "/"), element: 0) ?? String(localized: "Settings.interface.home.list.value.unknown"))")
}


func HomeListTipTitle(_ errorList: [String]) -> LocalizedStringKey {
  if errorList.count > 1 {
    return "Settings.interface.home.list.error.\(errorList.count)"
  } else if !errorList.isEmpty {
    if errorList[0] == "top" {
      return "Settings.interface.home.list.error.top"
    } else if errorList[0] == "bottom" {
      return "Settings.interface.home.list.error.bottom"
    } else if errorList[0] == "close" {
      return "Settings.interface.home.list.error.close"
    } else if errorList[0] == "settings-missing" {
      return "Settings.interface.home.list.error.settings-missing"
    } else if errorList[0] == "too-long" {
      return "Settings.interface.home.list.error.too-long"
    } else {
      return ""
    }
  } else {
    return ""
  }
}

func HomeListTipSubtitle(_ errorList: [String]) -> LocalizedStringKey {
  if errorList.count > 1 {
    return "Settings.interface.home.list.error.subtitle.multiple"
  } else if !errorList.isEmpty {
    if errorList[0] == "top" {
      return "Settings.interface.home.list.error.subtitle.top"
    } else if errorList[0] == "bottom" {
      return "Settings.interface.home.list.error.subtitle.bottom"
    } else if errorList[0] == "close" {
      return "Settings.interface.home.list.error.subtitle.close"
    } else if errorList[0] == "settings-missing" {
      return "Settings.interface.home.list.error.subtitle.settings-missing"
    } else if errorList[0] == "too-long" {
      return "Settings.interface.home.list.error.subtitle.too-long"
    } else {
      return ""
    }
  } else {
    return ""
  }
}

func HomeListTipDescription(_ error: String) -> LocalizedStringKey {
  if error == "top" {
    return "Settings.interface.home.list.error.description.top"
  } else if error == "bottom" {
    return "Settings.interface.home.list.error.description.bottom"
  } else if error == "close" {
    return "Settings.interface.home.list.error.description.close"
  } else if error == "settings-missing" {
    return "Settings.interface.home.list.error.description.settings-missing"
  } else if error == "too-long" {
    return "Settings.interface.home.list.error.description.too-long"
  } else {
    return ""
  }
}



struct SettingsInterfaceHomeToolbarPicker: View {
  @Binding var toolbar: String
  var body: some View {
    Picker(selection: $toolbar, content: {
      Label("Settings.interface.home.toolbar.selection.nil", systemImage: "circle.slash")
        .tag("nil")
      Label("Settings.interface.home.toolbar.selection.search-button", systemImage: "magnifyingglass")
        .tag("search-button")
      Label("Settings.interface.home.toolbar.selection.bookmarks", systemImage: "bookmark")
        .tag("bookmarks")
      Label("Settings.interface.home.toolbar.selection.history", systemImage: "clock")
        .tag("history")
      Label("Settings.interface.home.toolbar.selection.privacy", systemImage: "hand.raised")
        .tag("privacy")
      Label("Settings.interface.home.toolbar.selection.settings", systemImage: "gear")
        .tag("settings")
      Label("Settings.interface.home.toolbar.selection.carina", systemImage: "exclamationmark.bubble")
        .tag("carina")
      Label("Settings.interface.home.toolbar.selection.update-indicator", systemImage: "clock.badge")
        .tag("update-indicator")
    }, label: {
      //      HomeElementRenderder(isPrivateModeOn: .constant(false), isPrivateModePinned: .constant(false), isCookiesAllowed: .constant(true), searchEngineSelection: .constant(""), searchEngineBackup: .constant(""), customizedSearchEngine: .constant(""), longPressButtonAction: .constant(0), tintSaturation: .constant(0), tintBrightness: .constant(0), searchField: .constant(""), isURL: .constant(false), historyLinks: .constant([]), usingSearchEngine: .constant(""), isSelectionSheetDisplaying: .constant(false), latestVer: .constant("1.0.0"), wasPrivateModeOn: .constant(false), pinnedButton: .constant(0), isCepheusEnabled: .constant(false), element: toolbar, isInList: false, isEditing: true)
    })
    .pickerStyle(.navigationLink)
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
        UserDefaults.standard.set([275, 40, 100], forKey: "tintColor")
        UserDefaults.standard.set(defaultHomeList, forKey: "homeList")
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


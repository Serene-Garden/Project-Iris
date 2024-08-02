//
//  SettingsInterfaceView.swift
//  Project Iris Watch App
//
//  Created by ThreeManager785 on 2024/8/2.
//


import SwiftUI
import Cepheus
import Vela

//MARK: --- Interface ---

struct SettingsInterfaceView: View {
  let languageCode = Locale.current.language.languageCode
  let languageScript = Locale.current.language.script
  @Environment(\.layoutDirection) var layoutDirection
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
  @AppStorage("appLanguage") var appLanguage = ""
  @State var tintColorValues: [Any] = [275, 40, 100]
  @State var tintColor = Color(hue: 275/359, saturation: 40/100, brightness: 100/100)
  @State var isToolbarOnSelect = false
  @State var currentTextDirection = 0
  @State var selectedTextDirection = 0
  //  @State var editingToolbar = 0
  //  @Environment(\.dismiss) var dismiss
  let fontDesign: [Int: Font.Design] = [0: .default, 1: .rounded, 2: .monospaced, 3: .serif]
  let availableLanguages = ["", "ar", "zh-Hans", "zh-Hant", "nl", "en", "fr", "de", "hi", "id", "it", "ja", "ko", "pl", "pt", "ru", "es", "th", "tr", "uk", "vi"]
  let presentationText = ["∗", "عر", "简", "繁", "Nl", "En", "Fr", "De", "हि", "Id", "It", "日", "한", "Pl", "Pt", "Ру", "Es", "ทย", "Tr", "Ук", "Vi"]
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
                  Text("Settings.interface.advanced.footer")
                    .foregroundStyle(.yellow)
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
                  NavigationLink(destination: {
                    List {
                      Section {
                        Button(action: {
                          appLanguage = ""
                        }, label: {
                          HStack {
                            Text(verbatim: "*")
                              .font(.title3)
                              .fontDesign(.monospaced)
                            Text("Settings.interface.advanced.languange.follow-system-language")
                            Spacer()
                            if appLanguage == "" {
                              Image(systemName: "checkmark")
                            }
                          }
                        })
                        if selectedTextDirection != currentTextDirection {
                          HStack {
                            Image(systemName: "text.alignright")
                              .font(.title3)
                            VStack(alignment: .leading) {
                              Text("Settings.interface.advanced.languange.incorrect-direction")
                                .environment(\.locale, .init(identifier: "\(languageCode!)-\(languageScript!)"))
                              Text("Settings.interface.advanced.languange.incorrect-direction")
                                .opacity(0.6)
                                .font(.footnote)
                                .lineLimit(2)
                            }
                            Spacer()
                          }
                          .foregroundStyle(.yellow)
                        }
                      }
                      Section(content: {
                        ForEach(1..<availableLanguages.count, id: \.self) { languageIndex in
                          Button(action: {
                            appLanguage = availableLanguages[languageIndex]
                          }, label: {
                            HStack {
                              Text(presentationText[languageIndex])
                                .font(.title3)
                                .fontDesign(.rounded)
                              VStack(alignment: .leading) {
                                Text(Locale(identifier: availableLanguages[languageIndex]).localizedString(forIdentifier: availableLanguages[languageIndex])!)
                                Text(Locale(identifier: appLanguage.isEmpty ? "\(languageCode!)-\(languageScript!)" : appLanguage).localizedString(forIdentifier: availableLanguages[languageIndex])!)
                                  .font(.footnote)
                                  .foregroundStyle(.secondary)
                              }
                              Spacer()
                              if appLanguage == availableLanguages[languageIndex] {
                                Image(systemName: "checkmark")
                              }
                            }
                          })
                        }
                      }, footer: {
                        Text("Settings.interface.advanced.languange.footer")
                      })
                    }
                    .navigationTitle("Settings.interface.advanced.languange")
                    .onAppear {
                      currentTextDirection = convertLayoutDirectionIntoInt(layoutDirection)
                      selectedTextDirection = convertCharacterDirectionIntoInt(Locale.Language(identifier: appLanguage).characterDirection)
                    }
                    .onChange(of: appLanguage, perform: { value in
                      currentTextDirection = convertLayoutDirectionIntoInt(layoutDirection)
                      selectedTextDirection = convertCharacterDirectionIntoInt(Locale.Language(identifier: appLanguage).characterDirection)
                    })
                  }, label: {
                    VStack(alignment: .leading) {
                      Text("Settings.interface.advanced.languange")
                      Text(appLanguage.isEmpty ? String(localized: "Settings.interface.advanced.languange.follow-system-language") : Locale(identifier: appLanguage).localizedString(forIdentifier: appLanguage)!)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                  })
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

func convertCharacterDirectionIntoInt(_ direction: Locale.LanguageDirection) -> Int {
  if direction == .leftToRight {
    return 0
  } else if direction == .rightToLeft {
    return 1
  } else if direction == .topToBottom {
    return 2
  } else if direction == .bottomToTop {
    return 3
  } else if direction == .unknown {
    return 4
  } else {
    return 4
  }
}

func convertLayoutDirectionIntoInt(_ direction: LayoutDirection) -> Int {
  if direction == .leftToRight {
    return 0
  } else if direction == .rightToLeft {
    return 1
  } else {
    return 4
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
  
  @State var selectedGroup = 0
  @State var selectedBookmark = 0
  
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
          BookmarkPickerView(editorSheetIsDisaplying: $showBookmarkEditSheet, seletedGroup: $selectedGroup, selectedBookmark: $selectedBookmark, groupIndexEqualingGoal: Int(homeListValuesEditing[onFocusEditingItem].components(separatedBy: "/").first ?? "") ?? -1, bookmarkIndexEqualingGoal: Int(homeListValuesEditing[onFocusEditingItem].components(separatedBy: "/").last ?? "") ?? -1, action: {
            homeListValuesEditing[onFocusEditingItem] = "\(selectedGroup)/\(selectedBookmark)"
          })
        }
        //String(groupIndex) == homeListValuesEditing[onFocusEditingItem].components(separatedBy: "/").first && String(bookmarkIndex) == homeListValuesEditing[onFocusEditingItem].components(separatedBy: "/").last
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


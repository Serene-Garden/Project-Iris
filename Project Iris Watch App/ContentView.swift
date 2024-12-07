//
//  ContentView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/19.
//

import SwiftUI
import AuthenticationServices
import Cepheus

//@MainActor public var webpageIsDisplaying = false

public let defaultHomeList: [Any] = ["search-field", "search-button", "|", "bookmarks", "history", "privacy", "|", "archives", "scripts", "settings", "carina", "update-indicator"]
public let defaultHomeListValues: [Any] = ["nil", "nil", "nil", "nil", "nil", "nil", "nil", "nil", "nil", "nil", "nil", "nil"]
public let defaultSearchEngineNames: [Any] = ["Iris.search.bing", "Iris.search.google", "Iris.search.baidu", "Iris.search.sogou", "Iris.search.duckduckgo", "Iris.search.yahoo", "Iris.search.yandex", "Iris.search.360", "Iris.search.ecosia"]
public let defaultSearchEngineLinks: [Any] = ["https://www.bing.com/search?q=\\iris", "https://www.google.com/search?q=\\iris",  "https://www.baidu.com/s?wd=\\iris",  "https://www.sogou.com/web?query=\\iris", "https://duckduckgo.com/?q=\\Iris", "https://search.yahoo.com/search?p=\\Iris", "https://yandex.eu/search?text=\\Iris", "https://www.so.com/s?q=\\Iris", "https://www.ecosia.org/search?q=\\iris"]
public let defaultSearchEngineEditable: [Any] = [false, false, false, false, false, false, false, false, false]

struct HomeView: View {
  @Binding var isPrivateModeOn: Bool
  @Binding var searchField: String
  @State var homeList: [Any] = defaultHomeList
  @AppStorage("irisStartedUpSuccessfully") var irisStartedUpSuccessfully = true
  @State var homeListValues: [Any] = ["nil"]
  @State var homeListParsed: [[String]] = [/*["search-field", "search-button"], ["bookmarks"], ["history", "settings", "carina"]*/]
  @State var homeListValuesParsed: [[String]] = []
  @State var homeListBox: [String] = []
  @State var homeListValuesBox: [String] = []
  var body: some View {
    List {
      ForEach(0..<homeListParsed.count, id: \.self) { homeListSection in
        Section {
          ForEach(0..<homeListParsed[homeListSection].count, id: \.self) { homeListElement in
            HomeElementRenderder(isPrivateModeOn: $isPrivateModeOn, searchField: $searchField, element: homeListParsed[homeListSection][homeListElement], isInList: true, values: homeListValuesParsed[homeListSection][homeListElement])
          }
        }
      }
    }
    .onAppear {
      irisStartedUpSuccessfully = true
      if (UserDefaults.standard.array(forKey: "homeList") ?? []).isEmpty {
        UserDefaults.standard.set(defaultHomeList, forKey: "homeList")
        UserDefaults.standard.set(defaultHomeListValues, forKey: "homeListValues")
      }
      homeListBox = []
      homeListValuesBox = []
      homeListParsed = []
      homeListValuesParsed = []
      homeList = UserDefaults.standard.array(forKey: "homeList") ?? defaultHomeList
      homeListValues = UserDefaults.standard.array(forKey: "homeListValues") ?? defaultHomeListValues
      
      //Legacy Home List Handling Project
      if homeList as! [String] == ["search-field", "search-button", "|", "bookmarks", "privacy", "|", "history", "settings", "carina", "update-indicator"] {
        homeList = defaultHomeList
        homeListValues = defaultHomeListValues
        UserDefaults.standard.set(defaultHomeList, forKey: "homeList")
        UserDefaults.standard.set(defaultHomeListValues, forKey: "homeListValues")
      }
      for index in 0..<homeList.count {
        if ((homeList[index] as! String) != "|") {
          homeListBox.append(homeList[index] as! String)
          homeListValuesBox.append(homeListValues[index] as! String)
        } else {
          homeListParsed.append(homeListBox)
          homeListValuesParsed.append(homeListValuesBox)
          homeListBox = []
          homeListValuesBox = []
        }
      }
      homeListParsed.append(homeListBox)
      homeListValuesParsed.append(homeListValuesBox)
      
      if (UserDefaults.standard.array(forKey: "engineNames") ?? []).isEmpty {
        UserDefaults.standard.set(defaultSearchEngineNames, forKey: "engineNames")
      }
      if (UserDefaults.standard.array(forKey: "engineLinks") ?? []).isEmpty {
        UserDefaults.standard.set(defaultSearchEngineLinks, forKey: "engineLinks")
      }
      if (UserDefaults.standard.array(forKey: "engineNameIsEditable") ?? []).isEmpty {
        UserDefaults.standard.set(defaultSearchEngineEditable, forKey: "engineNameIsEditable")
      }
    }
  }
}

struct ContentView: View {
  @AppStorage("userLatestVersion") var userLatestVersion = "0.0.0"
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @State var searchField = ""
  @State var isUpdateSheetDisplayed = false
  
  @State var tintColorValues: [Any] = defaultColor as [Any]
  @State var tintColor = Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100)
  
  public var BingAbility = 4
  var lightColors: [Color] = [.secondary, .orange, .green, .green, .secondary]
  
  @AppStorage("homeToolbar1") var homeToolbar1: String = "nil"
  @AppStorage("homeToolbar2") var homeToolbar2: String = "nil"
  @AppStorage("homeToolbar3") var homeToolbar3: String = "nil"
  @AppStorage("homeToolbar4") var homeToolbar4: String = "nil"
  @AppStorage("homeToolbarBottomBlur") var homeToolbarBottomBlur = 0
  @AppStorage("homeToolbarMonogram") var homeToolbarMonogram: String = ""
  @AppStorage("homeToolbarMonogramFontIsUsingTitle3") var homeToolbarMonogramFontIsUsingTitle3 = false
  @AppStorage("homeToolbarMonogramFontIsCapitalized") var homeToolbarMonogramFontIsCapitalized = true
  @AppStorage("homeToolbarMonogramFontDesign") var homeToolbarMonogramFontDesign = 1
  let fontDesign: [Int: Font.Design] = [0: .default, 1: .rounded, 2: .monospaced, 3: .serif]
  @AppStorage("correctPasscode") var correctPasscode = ""
  
  //LEGACY
  @AppStorage("isPasscodeRequired") var isPasscodeRequired = false
  @AppStorage("passcode1") var passcode1 = 0
  @AppStorage("passcode2") var passcode2 = 0
  @AppStorage("passcode3") var passcode3 = 0
  @AppStorage("passcode4") var passcode4 = 0
  var body: some View {
    NavigationStack {
      if #available(watchOS 10.0, *) {
        HomeView(isPrivateModeOn: $isPrivateModeOn, searchField: $searchField)
          .navigationTitle("Home.Iris")
          .onAppear {
            if (UserDefaults.standard.array(forKey: "tintColor") ?? []).isEmpty {
              UserDefaults.standard.set(defaultColor, forKey: "tintColor")
            }
            tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? (defaultColor as [Any])
            tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
          }
          .containerBackground(tintColor.gradient, for: .navigation)
          .navigationBarTitleDisplayMode(.large)
          .toolbar {
            ToolbarItem(placement: .topBarLeading) {
              HomeElementRenderder(isPrivateModeOn: $isPrivateModeOn, searchField: $searchField, element: homeToolbar1, isInList: false, values: "")
            }
            ToolbarItem(placement: .topBarTrailing) {
              HomeElementRenderder(isPrivateModeOn: $isPrivateModeOn, searchField: $searchField, element: homeToolbar2, isInList: false, values: "")
            }
            ToolbarItemGroup(placement: .bottomBar) {
              HStack {
                HomeElementRenderder(isPrivateModeOn: $isPrivateModeOn, searchField: $searchField, element: homeToolbar3, isInList: false, values: "")
                if homeToolbar3 != "nil" {
                  Spacer()
                }
                if !homeToolbarMonogram.isEmpty {
                  Text(homeToolbarMonogram)
                    .font(homeToolbarMonogramFontIsUsingTitle3 ? .title3 : .body)
                    .fontDesign(fontDesign[homeToolbarMonogramFontDesign])
                    .textCase(homeToolbarMonogramFontIsCapitalized ? .uppercase : nil)
                    .foregroundColor(.accentColor)
                    .lineLimit(1)
                }
                if homeToolbar4 != "nil" {
                  Spacer()
                }
                HomeElementRenderder(isPrivateModeOn: $isPrivateModeOn, searchField: $searchField, element: homeToolbar4, isInList: false, values: "")
              }
              .background {
                if homeToolbarBottomBlur != 0 {
                  Color.clear.background(Material.ultraThin)
                    .opacity(homeToolbarBottomBlur == 1 ? 0.8 : 1)
                    .brightness(0.1)
                    .saturation(2.5)
                    .frame(width: screenWidth+100, height: 100)
                    .blur(radius: 10)
                    .offset(y: 20)
                }
              }
            }
          }
      } else {
        HomeView(isPrivateModeOn: $isPrivateModeOn, searchField: $searchField)
          .navigationTitle("Home.Iris")
          .navigationBarTitleDisplayMode(.large)
      }
    }
    .onAppear {
      if userLatestVersion == "0.0.0" {
        userLatestVersion = currentIrisVersion
      } else if userLatestVersion != currentIrisVersion {
        userLatestVersion = currentIrisVersion
        isUpdateSheetDisplayed = true
      }
    }
    .onAppear {
      //Legacy Passcode Handling Program
      if isPasscodeRequired {
        correctPasscode = "\(passcode1)\(passcode2)\(passcode3)\(passcode4)"
        isPasscodeRequired = false
        passcode1 = 0
        passcode2 = 0
        passcode3 = 0
        passcode4 = 0
      }
    }
    .sheet(isPresented: $isUpdateSheetDisplayed, content: {
      NewFearturesView()
    })
  }
}

struct HomeElementRenderder: View {
  @Binding var isPrivateModeOn: Bool
  @Binding var searchField: String
  var element: String
  var isInList: Bool
  var values: String
  var isEditing: Bool = false
  var body: some View {
    if element == "nil" {
      if !isEditing {
        EmptyView()
      } else {
        Image(systemName: "circle.dashed")
      }
    } else if element == "search-field" {
      HomeSearchFieldElement(searchField: $searchField)
        .privacySensitive(isPrivateModeOn)
    } else if element == "search-button" {
      HomeSearchButtonElement(isPrivateModeOn: $isPrivateModeOn, searchField: $searchField, isInList: isInList)
    } else if element == "bookmarks" {
      HomeBookmarksLinkElement(isInList: isInList)
    } else if element == "history" {
      HomeHistoryLinkElement(isInList: isInList)
    } else if element == "privacy" {
      HomePrivateModeToggleElement(isPrivateModeOn: $isPrivateModeOn, isInList: isInList)
    } else if element == "settings" {
      HomeSettingsLinkElement(isInList: isInList)
    } else if element == "carina" {
      HomeCarinaLinkElement(isInList: isInList)
    } else if element == "update-indicator" {
      HomeUpdateIndicatorElement(isInList: isInList)
    } else if element == "bookmark-link" {
      HomeBookmarkOpenLinkElement(isInList: isInList, values: values)
    } else if element == "archives" {
      HomeArchivesLinkElement(isInList: isInList)
    } else if element == "scripts" {
      HomeScriptsLinkElement(isInList: isInList)
    }
  }
}

struct HomeSearchFieldElement: View {
  @Binding var searchField: String
  var body: some View {
    CepheusKeyboard(input: $searchField, prompt: "Home.search-field", autoCorrectionIsEnabled: false)
  }
}

struct HomeSearchButtonElement: View {
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("currentEngine") var currentEngine = 0
  @AppStorage("secondaryEngine") var secondaryEngine = 1
  @AppStorage("leftSwipeSearchButton") var leftSwipeSearchButton = 4
  @AppStorage("rightSwipeSearchButton") var rightSwipeSearchButton = 3
  @Binding var isPrivateModeOn: Bool
  @Binding var searchField: String
  @State var engineNames: [String] = defaultSearchEngineNames as! [String]
  @State var engineLinks: [String] = defaultSearchEngineLinks as! [String]
  @State var engineNameIsEditable: [Bool] = defaultSearchEngineEditable as! [Bool]
  @State var configPageIsDisplaying = false
  @State var temporarySearchEngine = 0
  @State var temporaryPrivateMode = false
  @State var temporaryUseSearch = false
  @State var temporaryUseLegacyEngine = false
  var isInList: Bool
  var body: some View {
    Button(action: {
      searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[currentEngine])
    }, label: {
      if isInList {
        Label(searchField.isURL() ? "Home.open" : "Home.search", systemImage:  searchField.isURL() ? "network" : "magnifyingglass")
      } else {
        Image(systemName: searchField.isURL() ? "network" : "magnifyingglass")
      }
    })
    .onAppear {
      engineNames = (UserDefaults.standard.array(forKey: "engineNames") ?? defaultSearchEngineNames) as! [String]
      engineLinks = (UserDefaults.standard.array(forKey: "engineLinks") ?? defaultSearchEngineLinks) as! [String]
      engineNameIsEditable = (UserDefaults.standard.array(forKey: "engineNameIsEditable") ?? defaultSearchEngineEditable) as! [Bool]
    }
    .swipeActions(edge: .leading, content: {
      if leftSwipeSearchButton == 1 {
        Button(action: {
          isPrivateModeOn = true
          searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[currentEngine])
          isPrivateModeOn = false
        }, label: {
          Image(systemName: "hand.raised.fill")
        })
      } else if leftSwipeSearchButton == 2 {
        Button(action: {
          searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[currentEngine], isURL: false)
        }, label: {
          Image(systemName: "magnifyingglass")
        })
      } else if leftSwipeSearchButton == 3 {
        Button(action: {
          configPageIsDisplaying = true
        }, label: {
          Image(systemName: "ellipsis")
        })
      }  else if leftSwipeSearchButton == 4 {
        Button(action: {
          searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[secondaryEngine], isURL: false)
        }, label: {
          Image(systemName: "option")
        })
      }
    })
    .swipeActions(edge: .trailing, content: {
      if rightSwipeSearchButton == 1 {
        Button(action: {
          isPrivateModeOn = true
          searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[currentEngine])
          isPrivateModeOn = false
        }, label: {
          Image(systemName: "hand.raised.fill")
        })
      } else if rightSwipeSearchButton == 2 {
        Button(action: {
          searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[currentEngine], isURL: false)
        }, label: {
          Image(systemName: "magnifyingglass")
        })
      } else if rightSwipeSearchButton == 3 {
        Button(action: {
          configPageIsDisplaying = true
        }, label: {
          Image(systemName: "ellipsis")
        })
      } else if rightSwipeSearchButton == 4 {
        Button(action: {
          searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[secondaryEngine], isURL: false)
        }, label: {
          Image(systemName: "option")
        })
      }
    })
    .sheet(isPresented: $configPageIsDisplaying, content: {
      List {
        Section(content: {
          Picker("Home.config.search-engine", selection: $temporarySearchEngine) {
            ForEach(0..<engineNames.count, id: \.self) { index in
                  Text(engineNameIsEditable[index] ? engineNames[index] : String(localized: LocalizedStringResource(stringLiteral: engineNames[index])))
                .tag(index)
            }
          }
          Toggle(isOn: $temporaryPrivateMode, label: {
            Text("Home.config.private-mode")
          })
          Toggle(isOn: $temporaryUseSearch, label: {
            Text("Home.config.search")
          })
          Toggle(isOn: $temporaryUseLegacyEngine, label: {
            Text("Home.config.legacy-engine")
          })
          
          DismissButton(action: {
            searchButtonAction(isPrivateModeOn: temporaryPrivateMode, searchField: searchField, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[temporarySearchEngine], isURL: temporaryUseSearch ? false : nil, useLegacyEngine: temporaryUseLegacyEngine)
          }, label: {
            Label("Home.config.open", systemImage: "arrow.up.right.circle")
          })
        }, footer: {
          Text("Home.config.footer")
        })
      }
      .navigationTitle("Home.config")
    })
  }
}


struct HomeConfigPickEngineDismissButton<L: View>: View {
  var action: () -> Void
  @Environment(\.dismiss) var dismiss
  var body: some View {
    Button(action: {
      action()
      dismiss()
    }, label: {
      
    })
  }
}

struct HomePrivateModeToggleElement: View {
  @Binding var isPrivateModeOn: Bool
  var isInList: Bool
  var body: some View {
    if isInList {
      Toggle(isOn: $isPrivateModeOn, label: {
        Label("Home.privacy-mode", systemImage: "hand.raised")
      })
    } else {
      if #available(watchOS 10.0, *) {
        Button(action: {
          isPrivateModeOn.toggle()
        }, label: {
          Image(systemName: isPrivateModeOn ? "hand.raised" : "hand.raised.slash")
        })
        .accessibilityValue(isPrivateModeOn ? "Home.private-mode.value.on" : "Home.private-mode.value.off")
        .accessibilityHint(isPrivateModeOn ? "Home.private-mode.hint.on" : "Home.private-mode.hint.off")
        .accessibilityAddTraits(.isToggle)
      } else {
        Button(action: {
          isPrivateModeOn.toggle()
        }, label: {
          Image(systemName: isPrivateModeOn ? "hand.raised" : "hand.raised.slash")
        })
        .accessibilityValue(isPrivateModeOn ? "Home.private-mode.value.on" : "Home.private-mode.value.off")
        .accessibilityHint(isPrivateModeOn ? "Home.private-mode.hint.on" : "Home.private-mode.hint.off")
      }
    }
  }
}

struct HomeBookmarksLinkElement: View {
  @AppStorage("lockBookmarks") var lockBookmarks = false
  var isInList: Bool
  var body: some View {
    NavigationLink(destination: {
      if lockBookmarks {
        PasscodeView(destination: {
          BookmarksView()
        }, title: "Passcode.title.access.bookmarks")
      } else {
        BookmarksView()
      }
    }, label: {
      if isInList {
        HStack {
          Label("Home.bookmarks", systemImage: "bookmark")
          Spacer()
          LockIndicator(destination: "bookmarks")
        }
      } else {
        Image(systemName: "bookmark")
      }
    })
  }
}

struct HomeHistoryLinkElement: View {
  @AppStorage("lockHistory") var lockHistory = true
  var isInList: Bool
  var body: some View {
    NavigationLink(destination: {
      if lockHistory {
        PasscodeView(destination: {
          HistoryView()
        }, title: "Passcode.title.access.history")
      } else {
        HistoryView()
      }
    }, label: {
      if isInList {
        HStack {
          Label("Home.history", systemImage: "clock")
          Spacer()
          LockIndicator(destination: "history")
        }
      } else {
        Image(systemName: "clock")
      }
    })
  }
}

struct HomeSettingsLinkElement: View {
  var isInList: Bool
  var body: some View {
    NavigationLink(destination: {
      SettingsView()
    }, label: {
      if isInList {
        Label("Home.settings", systemImage: "gear")
      } else {
        Image(systemName: "gear")
      }
    })
  }
}

struct HomeCarinaLinkElement: View {
  var isInList: Bool
  var body: some View {
    NavigationLink(destination: {
      CarinaView()
    }, label: {
      if isInList {
        Label("Home.carina", systemImage: "exclamationmark.bubble")
      } else {
        Image(systemName: "exclamationmark.bubble")
      }
    })
//    .disabled(Date.now.timeIntervalSince1970 >= 1733932800)
  }
}

struct HomeUpdateIndicatorElement: View {
  var isInList: Bool
  @State var latestVer = ""
  @State var isImportant: Bool = false
  @State var isReady = false
  var body: some View {
    Group {
      if isReady {
        if isInList { //List Style
          if (latestVer != Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) && !latestVer.isEmpty { //Need's update
            if latestVer == "error" || latestVer == "failed" { //Failed
              Text("Home.update.error")
            } else { //Found
              Text(isImportant ? "Home.update.\(latestVer).important" : "Home.update.\(latestVer)")
                .foregroundStyle(isImportant ? .yellow : .primary)
            }
          }
        } else { //Toolbar Style
          if (latestVer != Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) && !latestVer.isEmpty { //Need's update
            if latestVer == "error" || latestVer == "failed" { //Failed
              Button(action: {}, label: {
                Image(systemName: "clock.badge.questionmark")
              })
            } else { //Found
              Button(action: {}, label: {
                Image(systemName: isImportant ? "clock.badge.exclamationmark" : "clock.badge")
                  .foregroundStyle(isImportant ? .yellow : .primary)
              })
            }
          } else { //Doesn't need
            if latestVer.isEmpty {
              Button(action: {}, label: {
                Image(systemName: "clock.badge.questionmark")
              })
            } else {
              Button(action: {}, label: {
                Image(systemName: "clock.badge.checkmark")
              })
            }
          }
        }
      } else {
        ProgressView()
      }
    }
    .onAppear {
      if !isReady {
        fetchWebPageContent(urlString: "https://fapi.darock.top:65535/iris/newver") { result in
          switch result {
            case .success(let content):
              latestVer = content.components(separatedBy: "\"")[1]
              if latestVer.contains("!") {
                latestVer = latestVer.components(separatedBy: "!")[0]
                isImportant = true
              }
              isReady = true
            case .failure(_):
              latestVer = "failed"
              isReady = true
          }
        }
      }
    }
  }
}

struct HomeBookmarkOpenLinkElement: View {
  var isInList: Bool
  var values: String
  
  @State var bookmarks: [(Bool, String, String, [(Bool, String, String, String)])] = []
  @State var groupIndex = 0
  @State var bookmarkIndex = 0
  @State var linkUnavailable = false
  @State var valueComponents: [String] = []
  @State var linkIsReady = false
  
  //For accessing web
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("currentEngine") var currentEngine = 0
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @State var engineLinks: [String] = defaultSearchEngineLinks as! [String]
  var body: some View {
    Button(action: {
      searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: bookmarks[groupIndex].3[bookmarkIndex].3, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[currentEngine])
    }, label: {
      if linkIsReady && !linkUnavailable {
        HStack {
          if bookmarks[groupIndex].3[bookmarkIndex].0 { //isEmoji
            Text(bookmarks[groupIndex].3[bookmarkIndex].1)
              .font(.title3)
          } else {
            Image(systemName: bookmarks[groupIndex].3[bookmarkIndex].1)
          }
          Text(bookmarks[groupIndex].3[bookmarkIndex].2)
          Spacer()
        }
      } else {
        Label("Home.unavailable", systemImage: "bookmark")
      }
    })
    .disabled(linkUnavailable || !linkIsReady)
    .onAppear {
      linkIsReady = false
      bookmarks = getBookmarkLibrary()
      if values == "nil" || values.isEmpty {
        linkUnavailable = true
      } else {
        valueComponents = values.components(separatedBy: "/")
        if let group = arraySafeAccess(valueComponents, element: 0) {
          groupIndex = Int(group) ?? -1
          if let bookmark = arraySafeAccess(valueComponents, element: 1) {
            bookmarkIndex = Int(bookmark) ?? -1
          } else {
            linkUnavailable = true
          }
        } else {
          linkUnavailable = true
        }
      }
      if groupIndex == -1 || bookmarkIndex == -1 {
        linkUnavailable = true
      }
      linkIsReady = true
    }
  }
}

struct HomeArchivesLinkElement: View {
  @AppStorage("lockArchives") var lockArchives = true
  var isInList: Bool
  var body: some View {
    NavigationLink(destination: {
      if lockArchives {
        PasscodeView(destination: {
          ArchivesView()
        }, title: "Passcode.title.access.archives")
      } else {
        HistoryView()
      }
    }, label: {
      if isInList {
        HStack {
          Label("Home.archives", systemImage: "archivebox")
          Spacer()
          LockIndicator(destination: "history")
        }
      } else {
        Image(systemName: "archivebox")
      }
    })
  }
}

struct HomeScriptsLinkElement: View {
  var isInList: Bool
  var body: some View {
    NavigationLink(destination: {
      ExtensionsView()
    }, label: {
      if isInList {
        Label("Home.scripts", systemImage: "puzzlepiece.extension")
      } else {
        Image(systemName: "puzzlepiece.extension")
      }
    })
  }
}

struct LockIndicator: View {
  @AppStorage("correctPasscode") var correctPasscode = ""
  @AppStorage("lockBookmarks") var lockBookmarks = false
  @AppStorage("lockHistory") var lockHistory = true
  var destination: String = "lock"
  var showChevron = false
  var body: some View {
    if !correctPasscode.isEmpty && ((lockBookmarks && destination == "bookmarks") || (lockHistory && destination == "history") || destination == "history") {
      Image(systemName: "lock")
        .foregroundStyle(.secondary)
    } else if showChevron {
      Image(systemName: "chevron.forward")
        .foregroundStyle(.secondary)
    }
  }
}

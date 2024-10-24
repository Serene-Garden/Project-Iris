//
//  ExtensionsView.swift
//  Project Iris Watch App
//
//  Created by ThreeManager785 on 9/30/24.
//

import SwiftUI
import SwiftSoup

struct ExtensionInfo {
  var title: String
  var subtitle: String?
  var about: String?
  var author: String?
  var gid: Int
  var ratingsPositive: Int?
  var ratingsNeutral: Int?
  var ratingsNegative: Int?
  var totalInstalls: Int?
  var jsLink: String?
  var scriptUpdateDate: Date?
  var appliers: [String]?
}

struct ExtensionsView: View {
//  @AppStorage("LastExtensionIID") var lastExtensionIID = -1
  @State var extensionIIDs: [Int] = []
  @State var extensionTitles: [String: String] = [:]
  @State var extensionGIDs: [String: String] = [:]
  @State var extensionSearchingSheetIsDisplaying = false
  
  @State var focusingGID: Int = -1
  @State var detailsSheetIsDisplaying = false
  @State var isReady = false
  var body: some View {
    NavigationStack {
      if !extensionIIDs.isEmpty {
        List {
          if #unavailable(watchOS 10) {
            Button(action: {
              extensionSearchingSheetIsDisplaying = true
            }, label: {
              Label("Extension.add", systemImage: "plus")
            })
          }
          ForEach(0..<extensionIIDs.count, id: \.self) { extensionIIDIndex in
            HStack {
              Text(extensionTitles[String(extensionIIDs[extensionIIDIndex])] ?? "Unknown")
                .lineLimit(2)
              Spacer()
            }
            .swipeActions(edge: .trailing, content: {
              Button(role: .destructive, action: {
                extensionTitles.removeValue(forKey: String(extensionIIDs[extensionIIDIndex]))
                extensionGIDs.removeValue(forKey: String(extensionIIDs[extensionIIDIndex]))
                extensionIIDs.remove(at: extensionIIDIndex)
                UserDefaults.standard.set("", forKey: "Extension\(extensionIIDs[extensionIIDIndex])")
                UserDefaults.standard.set(extensionIIDs, forKey: "ExtensionIIDs")
                UserDefaults.standard.set(extensionTitles, forKey: "ExtensionTitles")
                UserDefaults.standard.set(extensionGIDs, forKey: "ExtensionGIDs")
              }, label: {
                Image(systemName: "trash")
              })
              Button(action: {
                focusingGID = Int(extensionGIDs[String(extensionIIDs[extensionIIDIndex])] ?? "0") ?? 0
                detailsSheetIsDisplaying = true
              }, label: {
                Image(systemName: "info.circle")
              })
            })
          }
        }
      } else {
        if #available(watchOS 10, *) {
          ContentUnavailableView {
            Label("Extension.empty", systemImage: "puzzlepiece.extension")
          } description: {
            Text("Extension.empty.description")
          }
        } else {
          Button(action: {
            extensionSearchingSheetIsDisplaying = true
          }, label: {
            Text("Extension.add")
          })
        }
      }
    }
    .sheet(isPresented: $detailsSheetIsDisplaying, onDismiss: {
      extensionIIDs = (UserDefaults.standard.array(forKey: "ExtensionIIDs") ?? []) as! [Int]
      extensionTitles = (UserDefaults.standard.dictionary(forKey: "ExtensionTitles") ?? [:]) as! [String: String]
      extensionGIDs = (UserDefaults.standard.dictionary(forKey: "ExtensionGIDs") ?? [:]) as! [String: String]
    }, content: {
      if isReady {
        ExtensionsDetailsView(gid: focusingGID)
      } else {
        ProgressView()
          .onAppear {
            isReady = true
          }
      }
    })
    .navigationTitle("Extension")
    .toolbar {
      if #available(watchOS 10, *) {
        ToolbarItem(placement: .topBarTrailing, content: {
          Button(action: {
            extensionSearchingSheetIsDisplaying = true
          }, label: {
            Image(systemName: "plus")
          })
        })
      }
    }
    .sheet(isPresented: $extensionSearchingSheetIsDisplaying, content: {
      ExtensionsAddView()
    })
    .onAppear {
      if (UserDefaults.standard.array(forKey: "ExtensionIIDs") ?? []).isEmpty {
        UserDefaults.standard.set([], forKey: "ExtensionIIDs")
        UserDefaults.standard.set([:], forKey: "ExtensionTitles")
        UserDefaults.standard.set([:], forKey: "ExtensionGIDs")
      }
      extensionIIDs = (UserDefaults.standard.array(forKey: "ExtensionIIDs") ?? []) as! [Int]
      extensionTitles = (UserDefaults.standard.dictionary(forKey: "ExtensionTitles") ?? [:]) as! [String: String]
      extensionGIDs = (UserDefaults.standard.dictionary(forKey: "ExtensionGIDs") ?? [:]) as! [String: String]
    }
  }
}

struct ExtensionsAddView: View {
  @AppStorage("appLanguage") var appLanguage = ""
  @State var searchField = ""
  @State var searchResults: [ExtensionInfo] = []
  @State var isSearching = false
  var body: some View {
    NavigationStack {
      List {
        Section(content: {
          TextField("Extension.add.search-field", text: $searchField)
            .onSubmit {
              isSearching = true
              getGreasyforkSearchContent(searchField, lang: getGreasyforkLanguageCode(appLanguage), completion: { list in
                searchResults = list
                isSearching = false
              })
            }
          if !searchResults.isEmpty {
            ForEach(0..<searchResults.count, id: \.self) { searchIndex in
              NavigationLink(destination: {
                ExtensionsDetailsView(gid: searchResults[searchIndex].gid)
              }, label: {
              HStack {
                Text(searchResults[searchIndex].title)
                  .lineLimit(2)
                Spacer()
                Image(systemName: "chevron.forward")
                  .foregroundStyle(.secondary)
              }
              })
            }
          } else {
            if isSearching {
              ProgressView()
            } else if searchField.isEmpty {
              if #available(watchOS 10, *) {
                ContentUnavailableView {
                  Label("Extension.add.empty", systemImage: "magnifyingglass")
                } description: {
                  Text("Extension.add.empty.description")
                }
              } else {
                List {
                  Text("Extension.add.empty")
                    .bold()
                    .foregroundStyle(.secondary)
                }
              }
            } else {
              if #available(watchOS 10, *) {
                ContentUnavailableView {
                  Label("Extension.add.none", systemImage: "puzzlepiece.extension")
                } description: {
                  Text("Extension.add.none.description")
                }
              } else {
                List {
                  Text("Extension.add.none")
                    .bold()
                    .foregroundStyle(.secondary)
                }
              }
            }
          }
        }, footer: {
          Text("Extension.add.declarement")
        })
      }
      .navigationTitle("Extension.add")
    }
  }
  
}

struct ExtensionsDetailsView: View {
  var gid: Int
  @AppStorage("appLanguage") var appLanguage = ""
  @State var infos: ExtensionInfo?
  @State var titlesAreExpanded = false
  @State var additionSheetIsDisplaying = false
  @State var deletionSheetIsDisplaying = false
  
  @AppStorage("LastExtensionIID") var lastExtensionIID = -1
  @State var extensionIIDs: [Int] = []
  @State var extensionTitles: [String: String] = [:]
  @State var extensionGIDs: [String: String] = [:]
  @State var extensionIsInstalled = false
  let dateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
  }()
  var body: some View {
    Group {
      if infos != nil {
        List {
          VStack {
            if #available(watchOS 10, *) {
              HStack {
                Text(infos!.title)
                  .bold()
                  .font(.title3)
                  .lineLimit(titlesAreExpanded ? nil : 2)
                Spacer()
              }
            }
            if infos?.subtitle != nil {
              HStack {
                Text(infos!.subtitle!)
                  .font(.caption)
                  .foregroundStyle(.secondary)
                  .lineLimit(titlesAreExpanded ? nil : 2)
                Spacer()
              }
            }
          }
          .listRowBackground(Color.clear)
          .onTapGesture {
            titlesAreExpanded.toggle()
          }
          if #unavailable(watchOS 10) {
            Section {
              Button(action: {
                if extensionIsInstalled {
                  deletionSheetIsDisplaying = true
                } else {
                  additionSheetIsDisplaying = true
                }
              }, label: {
                if extensionIsInstalled {
                  Label("Extension.details.remove", systemImage: "trash")
                    .foregroundStyle(.red)
                } else {
                  Label("Extension.details.add", systemImage: "plus")
                }
              })
            }
          }
          if infos?.about != nil && !((infos?.about?.isEmpty) ?? true) {
            Section("Extension.details.about") {
              NavigationLink(destination: {
                List {
                  Text(infos!.about!)
                }
                .navigationTitle("Extension.details.about")
              }, label: {
                Text(infos!.about!)
                  .lineLimit(3)
              })
            }
          }
          if infos?.author != nil && !((infos?.author?.isEmpty) ?? true) {
            Section("Extension.details.author") {
              Text(infos!.author!)
                .lineLimit(3)
            }
          }
          if infos?.appliers != nil && infos!.appliers!.count > 0 {
            Section("Extension.details.appliers") {
              if infos!.appliers!.count == 1 {
                Text(infos!.appliers!.first!)
                  .lineLimit(2)
              } else {
                NavigationLink(destination: {
                  List {
                    ForEach(0..<infos!.appliers!.count, id: \.self) { applierIndex in
                      Text(infos!.appliers![applierIndex])
                    }
                  }
                  .navigationTitle("Extension.details.appliers")
                }, label: {
                  Text("Extension.details.appliers.\(infos!.appliers!.first!).\(infos!.appliers!.count-1)")
                    .lineLimit(2)
                })
              }
            }
          }
          if infos?.ratingsPositive != nil && infos?.ratingsNeutral != nil && infos?.ratingsNegative != nil && (infos!.ratingsPositive! + infos!.ratingsNeutral! + infos!.ratingsNegative!) > 0 {
            Section("Extension.details.ratings") {
              VStack(alignment: .leading) {
                HStack {
                  Image(systemName: "hand.thumbsup")
                    .font(.title3)
                  Text("\(Int((Double(infos!.ratingsPositive!)/Double(infos!.ratingsPositive! + infos!.ratingsNeutral! + infos!.ratingsNegative!)*100)))%")
                    .font(.title2)
                  Spacer()
                }
                if #available(watchOS 10.0, *) {
                  Text("\(infos!.ratingsPositive!)").foregroundStyle(.green) + Text(verbatim: " · ") + Text("\(infos!.ratingsNeutral!)").foregroundStyle(.yellow) + Text(verbatim: " · ") + Text("\(infos!.ratingsNegative!)").foregroundStyle(.red)
                }
              }
            }
          }
          if infos?.scriptUpdateDate != nil || infos?.totalInstalls != nil {
            Section {
              VStack(alignment: .leading) {
                if infos?.scriptUpdateDate != nil {
                  Label("Extension.details.update.\(dateFormatter.string(from: infos!.scriptUpdateDate!))", systemImage: "clock")
                }
                if infos?.totalInstalls != nil {
                  Label("Extension.details.installs.\(infos!.totalInstalls!)", systemImage: "arrow.down.circle")
                }
              }
            }
            .listRowBackground(Color.clear)
            .font(.footnote)
          }
        }
        .navigationTitle(infos!.title)
        .toolbar {
          if #available(watchOS 10, *) {
            ToolbarItem(placement: .topBarTrailing, content: {
              Button(action: {
                if extensionIsInstalled {
                  deletionSheetIsDisplaying = true
                } else {
                  additionSheetIsDisplaying = true
                }
              }, label: {
                if extensionIsInstalled {
                  Image(systemName: "trash")
                    .foregroundStyle(.red)
                } else {
                  Image(systemName: "plus")
                }
              })
            })
          }
        }
      } else {
        ProgressView()
      }
    }
    .onAppear {
      extensionIIDs = (UserDefaults.standard.array(forKey: "ExtensionIIDs") ?? []) as! [Int]
      extensionTitles = (UserDefaults.standard.dictionary(forKey: "ExtensionTitles") ?? [:]) as! [String: String]
      extensionGIDs = (UserDefaults.standard.dictionary(forKey: "ExtensionGIDs") ?? [:]) as! [String: String]
      getGreasyforkInfoByGID(gid, lang: getGreasyforkLanguageCode(appLanguage), completion: { info in
        infos = info
      })
      extensionIsInstalled = false
      for (key, value) in extensionGIDs {
        if value == String(gid) {
          extensionIsInstalled = true
        }
      }
    }
    .onChange(of: extensionGIDs, perform: { value in
      UserDefaults.standard.set(extensionIIDs, forKey: "ExtensionIIDs")
      UserDefaults.standard.set(extensionTitles, forKey: "ExtensionTitles")
      UserDefaults.standard.set(extensionGIDs, forKey: "ExtensionGIDs")
      extensionIsInstalled = false
      for (key, value) in extensionGIDs {
        if value == String(gid) {
          extensionIsInstalled = true
        }
      }
    })
    .sheet(isPresented: $additionSheetIsDisplaying, content: {
      NavigationStack {
        if #available(watchOS 10, *) {
          ContentUnavailableView {
            Label("Extension.details.add.succeed", systemImage: "puzzlepiece.extension")
          } description: {
            Text("Extension.details.add.succeed.description")
          }
        } else {
          List {
            Text("Extension.details.add.succeed")
              .bold()
              .foregroundStyle(.secondary)
          }
        }
      }
      .onAppear {
        lastExtensionIID += 1
        extensionIIDs.append(lastExtensionIID)
        extensionTitles.updateValue(infos!.title, forKey: String(lastExtensionIID))
        extensionGIDs.updateValue(String(gid), forKey: String(lastExtensionIID))
        fetchWebPageContent(urlString: infos!.jsLink!) { result in
          switch result {
            case .success(let content):
              UserDefaults.standard.set(content, forKey: "Extension#\(lastExtensionIID)")
            case .failure(let error):
              print(error)
          }
        }
      }
    })
    .sheet(isPresented: $deletionSheetIsDisplaying, onDismiss: {
      extensionIIDs = (UserDefaults.standard.array(forKey: "ExtensionIIDs") ?? []) as! [Int]
      extensionTitles = (UserDefaults.standard.dictionary(forKey: "ExtensionTitles") ?? [:]) as! [String: String]
      extensionGIDs = (UserDefaults.standard.dictionary(forKey: "ExtensionGIDs") ?? [:]) as! [String: String]
    }, content: {
      NavigationStack {
        if #available(watchOS 10, *) {
          ContentUnavailableView {
            Label("Extension.details.delete.succeed", systemImage: "puzzlepiece.extension")
          } description: {
            Text("Extension.details.delete.succeed.description")
          }
        } else {
          List {
            Text("Extension.details.delete.succeed")
              .bold()
              .foregroundStyle(.secondary)
          }
        }
      }
      .onAppear {
        for (key, value) in extensionGIDs {
          if value == String(gid) {
//                extensionIIDs.removeAll(where: { $0 == key })
            for index in 0..<extensionIIDs.count {
              if extensionIIDs[index] == Int(key) {
                extensionIIDs.remove(at: index)
              }
            }
            extensionTitles.removeValue(forKey: key)
            extensionGIDs.removeValue(forKey: key)
            UserDefaults.standard.set("", forKey: "Extension#\(key)")
          }
        }
      }
    })
  }
}

func getGreasyforkLanguageCode(_ appLang: String) -> String {
  var langCache = ""
  if appLang.isEmpty {
    langCache = (languageCode?.identifier) ?? "en"
  } else {
    langCache = appLang
  }
  if langCache.hasPrefix("zh") {
    if langCache == "zh" {
      langCache.append("-")
      langCache.append((Locale.current.language.script?.identifier) ?? "CN")
    }
    if langCache == "zh-Hans" {
      langCache = "zh-CN"
    } else if langCache == "zh-Hant" {
      langCache = "zh-TW"
    }
  }
  return langCache
}

func getGreasyforkSearchContent(_ content: String, lang: String = "en", completion: @escaping ([ExtensionInfo]) -> Void) {
  fetchWebPageContent(urlString: "https://greasyfork.org/\(lang)/scripts?q=\(content)") { result in
    switch result {
    case .success(let content):
        do {
          let webpage = try SwiftSoup.parse(content).body()!
          let extensionListClass = try arraySafeAccess(webpage.getElementsByClass("width-constraint").array(), element: 1) ?? Element(Tag("error"), "error")
          let extensionListSubclass = try extensionListClass.getElementsByClass("sidebarred-main-content").first() ?? Element(Tag("error"), "error")
          let extensionListGroup = try extensionListSubclass.getElementById("browse-script-list") ?? Element(Tag("error"), "error")
          let extensionListElements = try extensionListGroup.children().array()
//          print(extensionListElements)
          
          var outputs: [ExtensionInfo] = []
          var attributes: [String: String] = [:]
          for extensionIndex in 0..<extensionListElements.count {
            attributes = extensionListElements[extensionIndex].dataset()
            if attributes["class"] == "ad-entry" {
              continue //Skip Ads
            }
            if attributes["script-language"] != "js" {
              continue //Skip non-js scripts
            }
            var authorInfo = attributes["script-authors"] ?? "{:\"Unknown\"}"
            authorInfo = String(authorInfo.components(separatedBy: ":")[1].dropFirst().dropLast().dropLast())
            var subtitleInfo = try extensionListElements[extensionIndex].getElementsByClass("script-description description").first()?.text() ?? "Unknown"
            var ratingsPositiveInfo = try extensionListElements[extensionIndex].getElementsByClass("good-rating-count").first()?.text() ?? "0"
            var ratingsNeutralInfo = try extensionListElements[extensionIndex].getElementsByClass("ok-rating-count").first()?.text() ?? "0"
            var ratingsNegativeInfo = try extensionListElements[extensionIndex].getElementsByClass("bad-rating-count").first()?.text() ?? "0"
            outputs.append(ExtensionInfo(title: attributes["script-name"] ?? "Unknown",
//                                                 subtitle: subtitleInfo,
//                                                 author: authorInfo,
                                                 gid: Int(attributes["script-id"] ?? "Unknown") ?? 0
//                                                 ratingsPositive: Int(ratingsPositiveInfo) ?? 0,
//                                                 ratingsNeutral: Int(ratingsNeutralInfo) ?? 0,
//                                                 ratingsNegative: Int(ratingsNegativeInfo) ?? 0,
//                                                 totalInstalls: Int(attributes["script-total-installs"] ?? "0") ?? 0,
//                                                 jsLink: attributes["code-url"] ?? "Unknown",
//                                                 scriptUpdateDate: attributes["script-updated-date"] ?? "1970-01-01",
//                                                 dataSensitive: (attributes["sensitive"] ?? "Unknown") == "true"))
                                                 ))
          }
//          return outputs
          completion(outputs)
        } catch {
          print(error)
        }
    case .failure(let error):
        print(error)
//        return []
        completion([])
    }
  }
}

func getGreasyforkInfoByGID(_ gid: Int, lang: String = "en", completion: @escaping (ExtensionInfo?) -> Void) {
  fetchWebPageContent(urlString: "https://greasyfork.org/\(lang)/scripts/\(gid)") { result in
    switch result {
    case .success(let content):
        do {
          let webpage = try SwiftSoup.parse(content).body()!
          let extensionHeader = try webpage.getElementById("script-info")?.children().array()[1] ?? Element(Tag("error"), "error")
          let extensionContent = try webpage.getElementById("script-content") ?? Element(Tag("error"), "error")
          let extensionStats = try webpage.getElementById("script-stats") ?? Element(Tag("error"), "error")
          
          let title = try extensionHeader.children().first()?.text() ?? "Unknown"
          let subtitle = try extensionHeader.children().array()[1].text()
          
          let jsLinkInfo = try (webpage.getElementsByClass("install-link").first)?.dataset()["href"] ?? ""
          
          let authorInfo = try extensionStats.getElementsByClass("script-show-author").array()[1].text()
          
          var dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
          
          let updateDateElement = try extensionStats.getElementsByClass("script-show-updated-date").array()[1].children().first()?.children().first() ?? Element(Tag("error"), "error")
          let updateDateString = updateDateElement.getAttributes()?.asList()[0].getValue()
          let updateDateInfo = dateFormatter.date(from: updateDateString ?? "1970-01-01T00:00:00+00:00") //2014-04-14T16:25:56+00:00
          
          let appliersElements = try extensionStats.getElementsByClass("script-show-applies-to").array()[1].children().first()?.children() ?? Elements()
          var appliersInfo: [String] = []
          for i in 0..<appliersElements.count {
            appliersInfo.append(try appliersElements.array()[i].children().first()?.text() ?? "unknown")
          }
          
          let ratingsElements = try extensionStats.getElementsByClass("script-list-ratings").array()[1].children().first()?.children() ?? Elements()
          let ratingsPositiveInfo = try Int(ratingsElements.array()[0].text())
          let ratingsNeutralInfo = try Int(ratingsElements.array()[1].text())
          let ratingsNegativeInfo = try Int(ratingsElements.array()[2].text())
          
          let totalInstallsInfo = try Int(extensionStats.getElementsByClass("script-show-total-installs").array()[1].children().first()?.text() ?? "0")
          
          let aboutInfo = try (webpage.getElementById("additional-info")?.children().first()?.text())
                               
          completion(ExtensionInfo(title: title,
                                   subtitle: subtitle,
                                   about: aboutInfo,
                                   author: authorInfo,
                                   gid: gid,
                                   ratingsPositive: ratingsPositiveInfo,
                                   ratingsNeutral: ratingsNeutralInfo,
                                   ratingsNegative: ratingsNegativeInfo,
                                   totalInstalls: totalInstallsInfo,
                                   jsLink: jsLinkInfo,
                                   scriptUpdateDate: updateDateString == nil ? nil : updateDateInfo,
                                   appliers: appliersInfo
                                  ))
        } catch {
          print(error)
        }
    case .failure(let error):
        print(error)
        completion(nil)
    }
  }
}

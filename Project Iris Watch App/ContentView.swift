//
//  ContentView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/19.
//

import SwiftUI
import AuthenticationServices

struct HomeView: View {
  @Binding var isPrivateModeOn: Bool
  @Binding var isPrivateModePinned: Bool
  @Binding var isCookiesAllowed: Bool
  @Binding var isSettingsButtonPinned: Bool
  @Binding var searchEngineSelection: String
  @Binding var searchEngineBackup: String
  @Binding var customizedSearchEngine: String
  @Binding var longPressButtonAction: Int
  @Binding var tintSaturation: Int
  @Binding var tintBrightness: Int
  @Binding var searchField: String
  @Binding var isURL: Bool
  @Binding var historyLinks: [Any]
  @Binding var usingSearchEngine: String
  @Binding var isSelectionSheetDisplaying: Bool
  @Binding var latestVer: String
  @Binding var wasPrivateModeOn: Bool
  var body: some View {
    List {
      Section {
        TextField(text: $searchField, label: {
          Text("Home.search-field")
        })
        .autocorrectionDisabled()
        .onSubmit {
          if searchField.contains(".com") || searchField.contains(".cn") || searchField.contains(".org") || searchField.contains(".gov") || searchField.contains(".top") || searchField.contains(".vip") || searchField.contains(".edu") || searchField.contains(".tv") || searchField.contains(".net") || searchField.contains(".int") ||  searchField.contains(".gov") || searchField.contains(".mil") || searchField.contains(".arpa") || searchField.contains(".ac") || searchField.contains(".ae") || searchField.contains(".af") || searchField.contains(".ag") || searchField.contains(".ai") || searchField.contains(".al") || searchField.contains(".am") || searchField.contains(".ao") || searchField.contains(".aq") || searchField.contains(".ar") || searchField.contains(".as") || searchField.contains(".at") || searchField.contains(".au") || searchField.contains(".aw") || searchField.contains(".ax") || searchField.contains(".az") || searchField.contains(".ba") || searchField.contains(".bb") || searchField.contains(".bd") || searchField.contains(".be") || searchField.contains(".bf") || searchField.contains(".bg") || searchField.contains(".bh") || searchField.contains(".bi") || searchField.contains(".bj") || searchField.contains(".bm") || searchField.contains(".bn") || searchField.contains(".bo") || searchField.contains(".br") || searchField.contains(".bs") || searchField.contains(".bt") || searchField.contains(".bw") || searchField.contains(".by") || searchField.contains(".bz") || searchField.contains(".ca") || searchField.contains(".cc") || searchField.contains(".cd") || searchField.contains(".cf") || searchField.contains(".cg") || searchField.contains(".ch") || searchField.contains(".ci") || searchField.contains(".ck") || searchField.contains(".cl") || searchField.contains(".cm") || searchField.contains(".cn") || searchField.contains(".co") || searchField.contains(".cr") || searchField.contains(".cu") || searchField.contains(".cv") || searchField.contains(".cw") || searchField.contains(".cx") || searchField.contains(".cy") || searchField.contains(".cz") || searchField.contains(".de") || searchField.contains(".dj") || searchField.contains(".dk") || searchField.contains(".dm") || searchField.contains(".do") || searchField.contains(".dz") || searchField.contains(".ec") || searchField.contains(".ee") || searchField.contains(".eg") || searchField.contains(".er") || searchField.contains(".es") || searchField.contains(".et") || searchField.contains(".eu") || searchField.contains(".fi") || searchField.contains(".fk") || searchField.contains(".fm") || searchField.contains(".fo") || searchField.contains(".fr") || searchField.contains(".ga") || searchField.contains(".gd") || searchField.contains(".ge") || searchField.contains(".gf") || searchField.contains(".gg") || searchField.contains(".gh") || searchField.contains(".gi") || searchField.contains(".gl") || searchField.contains(".gm") || searchField.contains(".gn") || searchField.contains(".gp") || searchField.contains(".gq") || searchField.contains(".gr") || searchField.contains(".gs") || searchField.contains(".gt") || searchField.contains(".gu") || searchField.contains(".gw") || searchField.contains(".gy") || searchField.contains(".hk") || searchField.contains(".hm") || searchField.contains(".hn") || searchField.contains(".hr") || searchField.contains(".ht") || searchField.contains(".hu") || searchField.contains(".id") || searchField.contains(".ie") || searchField.contains(".il") || searchField.contains(".im") || searchField.contains(".in") || searchField.contains(".io") || searchField.contains(".iq") || searchField.contains(".ir") || searchField.contains(".is") || searchField.contains(".it") || searchField.contains(".je") || searchField.contains(".jm") || searchField.contains(".jo") || searchField.contains(".jp") || searchField.contains(".ke") || searchField.contains(".kg") || searchField.contains(".kh") || searchField.contains(".ki") || searchField.contains(".km") || searchField.contains(".kn") || searchField.contains(".kp") || searchField.contains(".kr") || searchField.contains(".kw") || searchField.contains(".ky") || searchField.contains(".kz") || searchField.contains(".la") || searchField.contains(".lb") || searchField.contains(".lc") || searchField.contains(".li") || searchField.contains(".lk") || searchField.contains(".lr") || searchField.contains(".ls") || searchField.contains(".lt") || searchField.contains(".lu") || searchField.contains(".lv") || searchField.contains(".ly") || searchField.contains(".ma") || searchField.contains(".mc") || searchField.contains(".md") || searchField.contains(".me") || searchField.contains(".mg") || searchField.contains(".mh") || searchField.contains(".mk") || searchField.contains(".ml") || searchField.contains(".mm") || searchField.contains(".mn") || searchField.contains(".mo") || searchField.contains(".mp") || searchField.contains(".mq") || searchField.contains(".mr") || searchField.contains(".ms") || searchField.contains(".mt") || searchField.contains(".mu") || searchField.contains(".mv") || searchField.contains(".mw") || searchField.contains(".mx") || searchField.contains(".my") || searchField.contains(".mz") || searchField.contains(".na") || searchField.contains(".mil") || searchField.contains(".gov") || searchField.contains(".mil") || searchField.contains(".gov") || searchField.contains(".mil") || searchField.contains(".gov") || searchField.contains(".nc") || searchField.contains(".ne") || searchField.contains(".nf") || searchField.contains(".ng") || searchField.contains(".ni") || searchField.contains(".nl") || searchField.contains(".no") || searchField.contains(".np") || searchField.contains(".nr") || searchField.contains(".nu") || searchField.contains(".nz") || searchField.contains(".om") || searchField.contains(".pa") || searchField.contains(".pe") || searchField.contains(".pf") || searchField.contains(".pg") || searchField.contains(".ph") || searchField.contains(".pk") || searchField.contains(".pl") || searchField.contains(".pm") || searchField.contains(".pn") || searchField.contains(".pr") || searchField.contains(".ps") || searchField.contains(".pt") || searchField.contains(".pw") || searchField.contains(".py") || searchField.contains(".qa") || searchField.contains(".re") || searchField.contains(".ro") || searchField.contains(".rs") || searchField.contains(".ru") || searchField.contains(".rw") || searchField.contains(".sa") || searchField.contains(".sb") || searchField.contains(".sc") || searchField.contains(".sd") || searchField.contains(".se") || searchField.contains(".sg") || searchField.contains(".sh") || searchField.contains(".si") || searchField.contains(".sk") || searchField.contains(".sl") || searchField.contains(".sm") || searchField.contains(".sn") || searchField.contains(".so") || searchField.contains(".sr") || searchField.contains(".ss") || searchField.contains(".st") || searchField.contains(".su") || searchField.contains(".sv") || searchField.contains(".sx") || searchField.contains(".sy") || searchField.contains(".sz") || searchField.contains(".tc") || searchField.contains(".td") || searchField.contains(".tf") || searchField.contains(".tg") || searchField.contains(".th") || searchField.contains(".tj") || searchField.contains(".tk") || searchField.contains(".tl") || searchField.contains(".tm") || searchField.contains(".tn") || searchField.contains(".to") || searchField.contains(".tr") || searchField.contains(".tt") || searchField.contains(".tv") || searchField.contains(".tw") || searchField.contains(".tz") || searchField.contains(".ua") || searchField.contains(".ug") || searchField.contains(".uk") || searchField.contains(".us") || searchField.contains(".uy") || searchField.contains(".uz") || searchField.contains(".va") || searchField.contains(".vc") || searchField.contains(".ve") || searchField.contains(".vg") || searchField.contains(".vi") || searchField.contains(".vn") || searchField.contains(".vu") || searchField.contains(".wf") || searchField.contains(".ws") || searchField.contains(".ye") || searchField.contains(".yt") || searchField.contains(".za") || searchField.contains(".zm") || searchField.contains(".zw") || searchField.contains(".xyz") || searchField.contains(".ltd") || searchField.contains(".top") || searchField.contains(".cc") || searchField.contains(".group") || searchField.contains(".shop") || searchField.contains(".vip") || searchField.contains(".site") || searchField.contains(".art") || searchField.contains(".club") || searchField.contains(".wiki") || searchField.contains(".online") || searchField.contains(".cloud") || searchField.contains(".fun") || searchField.contains(".store") || searchField.contains(".wang") || searchField.contains(".tech") || searchField.contains(".pro") || searchField.contains(".biz") || searchField.contains(".space") || searchField.contains(".link") || searchField.contains(".info") || searchField.contains(".team") || searchField.contains(".mobi") || searchField.contains(".city") || searchField.contains(".life") || searchField.contains(".life") || searchField.contains(".zone") || searchField.contains(".asia") || searchField.contains(".host") || searchField.contains(".website") || searchField.contains(".world") || searchField.contains(".center") || searchField.contains(".cool") || searchField.contains(".ren") || searchField.contains(".company") || searchField.contains(".plus") || searchField.contains(".video") || searchField.contains(".pub") || searchField.contains(".email") || searchField.contains(".live") || searchField.contains(".run") || searchField.contains(".love") || searchField.contains(".show") || searchField.contains(".work") || searchField.contains(".ink") || searchField.contains(".fund") || searchField.contains(".red") || searchField.contains(".chat") || searchField.contains(".today") || searchField.contains(".press") || searchField.contains(".social") || searchField.contains(".gold") || searchField.contains(".design") || searchField.contains(".auto") || searchField.contains(".guru") || searchField.contains(".black") || searchField.contains(".blue") || searchField.contains(".green") || searchField.contains(".pink") || searchField.contains(".poker") || searchField.contains(".news") || searchField.hasPrefix("https://") || searchField.hasPrefix("http://") {
            isURL = true
          } else {
            isURL = false
          }
        }
        Button(action: {
          searchButtonAction(isURL: isURL, isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, historys: historyLinks, usingSearchEngine: usingSearchEngine, customizedSearchEngine: customizedSearchEngine)
        }, label: {
          Label(isURL ? "Home.open" : "Home.search", systemImage: isURL ? "network" : "magnifyingglass" )
        })
        .onTapGesture {
          searchButtonAction(isURL: isURL, isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, historys: historyLinks, usingSearchEngine: usingSearchEngine, customizedSearchEngine: customizedSearchEngine)
        }
        .onLongPressGesture {
          if longPressButtonAction == 1 {
            usingSearchEngine = searchEngineBackup
            searchButtonAction(isURL: isURL, isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, historys: historyLinks, usingSearchEngine: usingSearchEngine, customizedSearchEngine: customizedSearchEngine)
          } else if longPressButtonAction == 2 {
            isSelectionSheetDisplaying = true
          } else if longPressButtonAction == 3 {
            isPrivateModeOn = true
            searchButtonAction(isURL: isURL, isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, historys: historyLinks, usingSearchEngine: usingSearchEngine, customizedSearchEngine: customizedSearchEngine)
            isPrivateModeOn = wasPrivateModeOn
          }
        }
        .sheet(isPresented: $isSelectionSheetDisplaying, content: {
          List {
            Section(content: {
              Picker("Settings.search-engine.temporary", selection: $usingSearchEngine) {
                Text("Settings.search-engine.Bing").tag("Bing")
                Text("Settings.search-engine.Google").tag("Google")
                Text("Settings.search-engine.Baidu").tag("Baidu")
                Text("Settings.search-engine.Sougou").tag("Sougou")
                Text("Settings.search-engine.customize").tag("Customize")
              }
            }, footer: {
              Text("Home.selection.description")
            })
            Button(action: {
              searchButtonAction(isURL: isURL, isPrivateModeOn: isPrivateModeOn, searchField: searchField, isCookiesAllowed: isCookiesAllowed, historys: historyLinks, usingSearchEngine: usingSearchEngine, customizedSearchEngine: customizedSearchEngine)
              usingSearchEngine = searchEngineSelection
            }, label: {
              Label("Home.search", systemImage: "magnifyingglass" )
            })
          }
        })
        if isPrivateModePinned {
          Toggle(isOn: $isPrivateModeOn, label: {
            Label("Home.privacy-mode", systemImage: "hand.raised")
          })
        }
      }
      Section {
        NavigationLink(destination: {
          if #available(watchOS 10.0, *) {
            PasscodeView(destination: 1)
          } else {
            BookmarksView()
          }
        }, label: {
          Label("Home.bookmarks", systemImage: "bookmark")
        })
      }
      Section {
        if !isPrivateModePinned {
          Toggle(isOn: $isPrivateModeOn, label: {
            Label("Home.privacy-mode", systemImage: "hand.raised")
          })
        }
        NavigationLink(destination: {
          if #available(watchOS 10.0, *) {
            PasscodeView(destination: 0)
          } else {
            HistoryView()
          }
        }, label: {
          Label("Home.history", systemImage: "clock")
        })
        if !isSettingsButtonPinned {
          NavigationLink(destination: SettingsView(), label: {
            Label("Home.settings", systemImage: "gear")
          })
        }
        NavigationLink(destination: CarinaView(), label: {
          if !isOpenSource {
            Label("Settings.carina", systemImage: "bubble.left.and.exclamationmark.bubble.right")
          } else {
            Label("Settings.carina.unavailable", systemImage: "bubble.left.and.exclamationmark.bubble.right")
              .foregroundStyle(.secondary)
          }
        })
        .disabled(isOpenSource)
        if !isOpenSource {
          if latestVer != Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String {
            if latestVer == "Error" || latestVer == "Failed" || latestVer.isEmpty {
              Text("Home.update.error")
            } else {
              Text("Home.update.\(latestVer)")
            }
          }
        }
      }
    }
  }
}

struct ContentView: View {
  let tintColor: Color = Color(hue: 275/360, saturation: 40/100, brightness: 100/100)
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @AppStorage("isPrivateModePinned") var isPrivateModePinned = false
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("isSettingsButtonPinned") var isSettingsButtonPinned = false
  @AppStorage("searchEngineSelection") var searchEngineSelection = "Bing"
  @AppStorage("searchEngineBackup") var searchEngineBackup = "Google"
  @AppStorage("customizedSearchEngine") var customizedSearchEngine = ""
  @AppStorage("longPressButtonAction") var longPressButtonAction = 0
  @AppStorage("tintSaturation") var tintSaturation: Int = 40
  @AppStorage("tintBrightness") var tintBrightness: Int = 100
  @State var historyLinks: [Any] = []
  @State var usingSearchEngine = ""
  @State var searchField = ""
  @State var isURL = false
  @State var isSelectionSheetDisplaying = false
  @State var latestVer = ""
  @State var wasPrivateModeOn = false
  public var BingAbility = 4
  var lightColors: [Color] = [.secondary, .orange, .green, .green, .secondary]
  var body: some View {
    NavigationStack {
      if #available(watchOS 10.0, *) {
        HomeView(isPrivateModeOn: $isPrivateModeOn, isPrivateModePinned: $isPrivateModePinned, isCookiesAllowed: $isCookiesAllowed, isSettingsButtonPinned: $isSettingsButtonPinned, searchEngineSelection: $searchEngineSelection, searchEngineBackup: $searchEngineBackup, customizedSearchEngine: $customizedSearchEngine, longPressButtonAction: $longPressButtonAction, tintSaturation: $tintSaturation, tintBrightness: $tintBrightness, searchField: $searchField, isURL: $isURL, historyLinks: $historyLinks, usingSearchEngine: $usingSearchEngine, isSelectionSheetDisplaying: $isSelectionSheetDisplaying, latestVer: $latestVer, wasPrivateModeOn: $wasPrivateModeOn)
          .navigationTitle("Home.Iris")
          .containerBackground(tintColor.gradient, for: .navigation)
          .navigationBarTitleDisplayMode(.large)
          .toolbar {
            if isSettingsButtonPinned {
              ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: {SettingsView()}, label: {
                  Image(systemName: "gear")
                })
              }
            }
          }
          .onAppear {
            usingSearchEngine = searchEngineSelection
            historyLinks = UserDefaults.standard.array(forKey: "HistoryLink") ?? []
            if !isOpenSource {
              fetchWebPageContent(urlString: irisVersionAPI) { result in
                switch result {
                case .success(let content):
                  latestVer = content.components(separatedBy: "\"")[1]
                case .failure(_):
                  latestVer = "Failed"
                }
              }
            }
          }
      } else {
        HomeView(isPrivateModeOn: $isPrivateModeOn, isPrivateModePinned: $isPrivateModePinned, isCookiesAllowed: $isCookiesAllowed, isSettingsButtonPinned: $isSettingsButtonPinned, searchEngineSelection: $searchEngineSelection, searchEngineBackup: $searchEngineBackup, customizedSearchEngine: $customizedSearchEngine, longPressButtonAction: $longPressButtonAction, tintSaturation: $tintSaturation, tintBrightness: $tintBrightness, searchField: $searchField, isURL: $isURL, historyLinks: $historyLinks, usingSearchEngine: $usingSearchEngine, isSelectionSheetDisplaying: $isSelectionSheetDisplaying, latestVer: $latestVer, wasPrivateModeOn: $wasPrivateModeOn)
          .navigationTitle("Home.Iris")
          .navigationBarTitleDisplayMode(.large)
          .onAppear {
            wasPrivateModeOn = isPrivateModeOn
            usingSearchEngine = searchEngineSelection
            historyLinks = UserDefaults.standard.array(forKey: "HistoryLink") ?? []
            if !isOpenSource {
              fetchWebPageContent(urlString: irisVersionAPI) { result in
                switch result {
                case .success(let content):
                  latestVer = content.components(separatedBy: "\"")[1]
                case .failure(let error):
                  latestVer = "Failed"
                }
              }
            }
          }
      }
    }
  }
}

public func fetchWebPageContent(urlString: String, completion: @escaping (Result<String, Error>) -> Void) {
  guard let url = URL(string: urlString) else {
    completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
    return
  }
  let session = URLSession.shared
  let task = session.dataTask(with: url) { data, response, error in
    if let error = error {
      completion(.failure(error))
      return
    }
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
      return
    }
    guard let data = data else {
      completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
      return
    }
    if let content = String(data: data, encoding: .utf8) {
      completion(.success(content))
    } else {
      completion(.failure(NSError(domain: "Unable to parse data", code: 0, userInfo: nil)))
    }
  }
  task.resume()
}

public extension String {
  //将原始的url编码为合法的url
  func urlEncoded() -> String {
    let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
        .urlQueryAllowed)
    return encodeUrlString ?? ""
  }
  
  //将编码后的url转换回原始的url
  func urlDecoded() -> String {
    return self.removingPercentEncoding ?? ""
  }
}

public func searchButtonAction(isURL: Bool, isPrivateModeOn: Bool, searchField: String, isCookiesAllowed: Bool, historys: [Any], usingSearchEngine: String, customizedSearchEngine: String) {
  var searchContent: String = searchField
  var historyLinks: [Any] = historys
  if isURL {
    if !searchContent.hasPrefix("http://") && !searchContent.hasPrefix("https://") {
      searchContent = "http://" + searchContent
    }
    let session = ASWebAuthenticationSession(
      url: URL(string: searchContent.urlEncoded())!,
      callbackURLScheme: nil
    ) { _, _ in
      
    }
    if isPrivateModeOn {
      session.prefersEphemeralWebBrowserSession = true
    } else {
      session.prefersEphemeralWebBrowserSession = !isCookiesAllowed
    }
    session.start()
    if !isPrivateModeOn && !searchContent.isEmpty {
      historyLinks.insert(searchContent.urlEncoded(), at: 0)
      UserDefaults.standard.set(historyLinks, forKey: "HistoryLink")
    }
  } else {
    let session = ASWebAuthenticationSession(
      url: URL(string: GetWebSearchedURL(searchContent, usingSearchEngine: usingSearchEngine, customizedSearchEngine: customizedSearchEngine))!,
      callbackURLScheme: nil
    ) { _, _ in
      
    }
    if isPrivateModeOn {
      session.prefersEphemeralWebBrowserSession = true
    } else {
      session.prefersEphemeralWebBrowserSession = !isCookiesAllowed
    }
    session.start()
    if !isPrivateModeOn && !searchField.isEmpty {
      historyLinks.insert(searchContent, at: 0)
      UserDefaults.standard.set(historyLinks, forKey: "HistoryLink")
    }
  }
}

public func GetWebSearchedURL(_ input: String, usingSearchEngine: String, customizedSearchEngine: String) -> String {
  var output = ""
  switch usingSearchEngine {
  case "Bing":
    output = "https://www.bing.com/search?q=\(input.urlEncoded())"
    break
  case "Google":
    output = "https://www.google.com/search?q=\(input.urlEncoded())"
    break
  case "Baidu":
    output = "https://www.baidu.com/s?wd=\(input.urlEncoded())"
    break
  case "Sougou":
    output = "https://www.sogou.com/web?query=\(input.urlEncoded())"
    break
  case "Customize":
    output = customizedSearchEngine.replacingOccurrences(of: "\\Iris", with: input.urlEncoded())
    break
  default:
    output = "https://www.bing.com/search?q=\(input.urlEncoded())"
    break
  }
  return output
}

/*
 if textOrURL.isURL() {
 if !textOrURL.hasPrefix("http://") && !textOrURL.hasPrefix("https://") {
 textOrURL = "http://" + textOrURL
 }
 let session = ASWebAuthenticationSession(
 url: URL(string: textOrURL.urlEncoded())!,
 callbackURLScheme: nil
 ) { _, _ in
 
 }
 session.prefersEphemeralWebBrowserSession = !isAllowCookie
 session.start()
 } else {
 let session = ASWebAuthenticationSession(
 url: URL(string: GetWebSearchedURL(textOrURL))!,
 callbackURLScheme: nil
 ) { _, _ in
 
 }
 session.prefersEphemeralWebBrowserSession = !isAllowCookie
 session.start()
 }*/

#Preview {
  ContentView()
}

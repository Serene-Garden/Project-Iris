//
//  ContentView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/19.
//

import SwiftUI
import AuthenticationServices

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
    public var BingAbility = 4
    var lightColors: [Color] = [.secondary, .orange, .green, .green, .secondary]
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField(text: $searchField, label: {
                        Text("Home.search-field")
                    })
                    .onSubmit {
                        if searchField.contains(".com") || searchField.contains(".cn") || searchField.contains(".org") || searchField.contains(".gov") || searchField.contains(".top") || searchField.contains(".vip") ||
                            searchField.contains(".edu") || searchField.contains(".tv") || searchField.contains("https://") || searchField.contains("http://") {
                            isURL = true
                        } else {
                            isURL = false
                        }
                    }
                    Button(action: {
                        searchButtonAction()
                    }, label: {
                        Label(isURL ? "Home.open" : "Home.search", systemImage: isURL ? "network" : "magnifyingglass" )
                    })
                    .onLongPressGesture {
                        if longPressButtonAction == 1 {
                            usingSearchEngine = searchEngineBackup
                            searchButtonAction()
                        } else if longPressButtonAction == 2 {
                            isSelectionSheetDisplaying = true
                        } else if longPressButtonAction == 3 {
                            
                            searchButtonAction()
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
                                searchButtonAction()
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
                    NavigationLink(destination: {PasscodeView(destination: 1)}, label: {
                        Label("Home.bookmarks", systemImage: "bookmark")
                    })
                }
                Section {
                    if !isPrivateModePinned {
                        Toggle(isOn: $isPrivateModeOn, label: {
                            Label("Home.privacy-mode", systemImage: "hand.raised")
                        })
                    }
                    NavigationLink(destination: PasscodeView(destination: 0), label: {
                        Label("Home.history", systemImage: "clock")
                    })
                    if !isSettingsButtonPinned {
                        NavigationLink(destination: SettingsView(), label: {
                            Label("Home.settings", systemImage: "gear")
                        })
                    }
                    
                    /* NavigationLink(destination: {}, label: {
                        HStack {
                            if BingAbility == 0 {
                                Text("Home.Bing-API-key.none")
                            } else if BingAbility == 1 {
                                Text("Home.Bing-API-key.unavailable")
                            } else if BingAbility == 2 {
                                Text("Home.Bing-API-key.own")
                            } else if BingAbility == 3 {
                                Text("Home.Bing-API-key.subscription")
                            } else {
                                Text("Home.Bing-API-key.coming-in-future")
                            }
                            Spacer()
                            Circle()
                                .frame(width: 10)
                                .foregroundStyle(lightColors[BingAbility])
                                .padding(.trailing, 7)
                        }
                    })
                    .disabled(BingAbility > 3 || BingAbility < 0) */
                }
            }
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
            }
        }
    }
    func searchButtonAction() {
        if isURL {
            if !searchField.hasPrefix("http://") && !searchField.hasPrefix("https://") {
                searchField = "http://" + searchField
            }
            let session = ASWebAuthenticationSession(
                url: URL(string: searchField.urlEncoded())!,
                callbackURLScheme: nil
            ) { _, _ in
                
            }
            session.prefersEphemeralWebBrowserSession = !isCookiesAllowed && !isPrivateModeOn
            session.start()
            if !isPrivateModeOn {
                historyLinks.insert(searchField.urlEncoded(), at: 0)
                UserDefaults.standard.set(historyLinks, forKey: "HistoryLink")
            }
        } else {
            let session = ASWebAuthenticationSession(
                url: URL(string: GetWebSearchedURL(searchField))!,
                callbackURLScheme: nil
            ) { _, _ in
                
            }
            session.prefersEphemeralWebBrowserSession = !isCookiesAllowed && !isPrivateModeOn
            session.start()
            if !isPrivateModeOn {
                historyLinks.insert(searchField, at: 0)
                UserDefaults.standard.set(historyLinks, forKey: "HistoryLink")
            }
        }
    }
    func GetWebSearchedURL(_ input: String) -> String {
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

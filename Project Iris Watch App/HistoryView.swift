//
//  HistoryView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/21.
//

import SwiftUI
import AuthenticationServices

struct HistoryView: View {
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("searchEngineSelection") var searchEngineSelection = "Bing"
  @AppStorage("customizedSearchEngine") var customizedSearchEngine = ""
  @State var historyLinks: [Any] = []
  var body: some View {
    NavigationStack {
      if historyLinks.count > 0 {
        List {
          ForEach(0..<historyLinks.count, id: \.self) {history in
            Button(action: {
              if (historyLinks[history] as! String).description.hasPrefix("http://") || (historyLinks[history] as! String).hasPrefix("https://")  {
                let session = ASWebAuthenticationSession(
                  url: URL(string: (historyLinks[history] as! String).urlEncoded())!,
                  callbackURLScheme: nil
                ) { _, _ in
                  
                }
                session.prefersEphemeralWebBrowserSession = !isCookiesAllowed && !isPrivateModeOn
                session.start()
              } else {
                let session = ASWebAuthenticationSession(
                  url: URL(string: GetWebSearchedURL((historyLinks[history] as! String)))!,
                  callbackURLScheme: nil
                ) { _, _ in
                  
                }
                session.prefersEphemeralWebBrowserSession = !isCookiesAllowed && !isPrivateModeOn
                session.start()
              }
            }, label: {
              Label(historyLinks[history] as! String, systemImage: ((historyLinks[history] as! String).hasPrefix("http://") || (historyLinks[history] as! String).hasPrefix("https://")) ? "network" : "magnifyingglass")
            })
          }
          .onDelete(perform: { history in
            historyLinks.remove(atOffsets: history)
            UserDefaults.standard.set(historyLinks, forKey: "HistoryLink")
          })
        }
      } else {
        Text("History.nothing")
          .bold()
          .foregroundStyle(.secondary)
          .font(.title3)
      }
    }
    .navigationTitle("Home.history")
    .onAppear {
      historyLinks = UserDefaults.standard.array(forKey: "HistoryLink") ?? []
    }
  }
  func GetWebSearchedURL(_ input: String) -> String {
    var output = ""
    switch searchEngineSelection {
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

#Preview {
  HistoryView()
}

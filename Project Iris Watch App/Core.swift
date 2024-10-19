//
//  Core.swift
//  Project Iris
//
//  Created by ThreeManager785 on 9/15/24.
//

import SwiftUI
import AuthenticationServices
import Cepheus
import UIKit

public final class WebViewUIDelegate: NSObject, WKUIDelegate {
  public static let shared = WebViewUIDelegate()
  
  public func webView(
    _ webView: WKWebView,
    createWebViewWith configuration: WKWebViewConfiguration,
    for navigationAction: WKNavigationAction,
    windowFeatures: WKWindowFeatures
  ) -> WKWebView? {
    if navigationAction.targetFrame == nil {
      webView.load(navigationAction.request)
    }
    return nil
  }
}

public final class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
  public static let shared = WebViewNavigationDelegate()
  
  public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}
  
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
  
  public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {}
  
  public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
    print(error)
  }
  
  public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {}
}

//@MainActor public var webpageIsDisplaying = false
@MainActor public func searchButtonAction(isPrivateModeOn: Bool, searchField: String, isCookiesAllowed: Bool, searchEngine: String, isURL: Bool? = nil, useLegacyEngine: Bool? = nil) {
  let useLegacyEngine = UserDefaults.standard.bool(forKey: "UseLegacyBrowsingEngine")
  //Complete
  var optimizedSearchField: String = searchField
  var optimizedSearchEngine: String = searchEngine
  var optimizedIsURL: Bool? = isURL
  if optimizedIsURL == nil {
    optimizedIsURL = optimizedSearchField.isURL()
  }
  if !optimizedSearchField.hasPrefix("http://") && !optimizedSearchField.hasPrefix("https://") && optimizedIsURL! {
    optimizedSearchField = "http://" + optimizedSearchField
  }
  if !optimizedSearchEngine.hasPrefix("http://") && !optimizedSearchEngine.hasPrefix("https://") {
    optimizedSearchEngine = "http://" + optimizedSearchEngine
  }
  
  //Access
  if useLegacyEngine ?? UserDefaults.standard.bool(forKey: "UseLegacyBrowsingEngine") {
    let session = ASWebAuthenticationSession(
      url: URL(string: (optimizedIsURL! ? optimizedSearchField : optimizedSearchEngine.lowercased().replacingOccurrences(of: "\\iris", with: optimizedSearchField)).urlEncoded())!,
      callbackURLScheme: nil
    ) { _, _ in
      
    }
    if isPrivateModeOn {
      session.prefersEphemeralWebBrowserSession = true
    } else {
      session.prefersEphemeralWebBrowserSession = !isCookiesAllowed
    }
    session.start()
  } else {
    if !optimizedSearchField.isEmpty {
      let webpageConfig = WKWebView()
      webpageConfig.navigationDelegate = WebViewNavigationDelegate.shared
      webpageConfig.uiDelegate = WebViewUIDelegate.shared
      let webpageURLRequest = URLRequest(url: URL(string: (optimizedIsURL! ? optimizedSearchField : optimizedSearchEngine.lowercased().replacingOccurrences(of: "\\iris", with: optimizedSearchField)).urlEncoded())!)
      if #available(watchOS 10.0, *) {
        webpageConfig.configuration.websiteDataStore.httpCookieStore.setCookiePolicy(isCookiesAllowed ? .allow : .disallow)
      }
      webpageConfig.load(webpageURLRequest)
      webpageContent = webpageConfig
      webpageIsArchive = false
      webpageArchiveURL = nil
      webpageArchiveTitle = nil
      webpageIsDisplaying = true
    }
    //    print(webpageIsDisplaying)
  }
  
  //Record
  if !isPrivateModeOn && !optimizedSearchField.isEmpty {
    recordHistory(searchField)
  }
}

@MainActor public func recordHistory(_ content: String) {
  //Record
  var history = getHistory()
  var lastHistoryID = UserDefaults.standard.integer(forKey: "lastHistoryID")
  history.insert((content, Date.now, lastHistoryID+1), at: 0)
  UserDefaults.standard.set(lastHistoryID+1, forKey: "lastHistoryID")
  updateHistory(history)
}

public func fetchWebPageContent(urlString: String, completion: @escaping (Result<String, Error>) -> Void) {
  guard let url = URL(string: urlString) else {
    completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
    return
  }
  let session = URLSession.shared
  let task = session.dataTask(with: url) { data, response, error in
    if let error = error {
      DispatchQueue.main.async { @MainActor in
        completion(.failure(error))
      }
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

func getTopLevel(from url: String) -> String? {
  if !url.contains(".") {
    return nil
  }
  let noScheme: String
  if url.hasPrefix("http://")
      || url.hasPrefix("https://")
      || url.hasPrefix("file://"),
     let spd = url.split(separator: "://")[from: 1] {
    noScheme = String(spd)
  } else {
    noScheme = url
  }
  if let dotSpd = noScheme.split(separator: "/").first {
    let specialCharacters: [Character] = ["/", "."]
    if let splashSpd = dotSpd.split(separator: ".").last, let colonSpd = splashSpd.split(separator: ":").first {
      if !colonSpd.contains(specialCharacters) {
        return String(colonSpd)
      }
    }
  }
  return nil
}

func arraySafeAccess<T>(_ array: Array<T>, element: Int) -> T? {
  //This function avoids index out of range error when accessing a range.
  //If out, then it will return nil instead of throwing an error.
  //Normally it will just return the content, but in optional.
  if element >= array.count || element < 0 { //Index out of range
    return nil
  } else { //Index in range
    //    print(array)
    //    print(element)
    return array[element]
  }
}

func getDocumentsDirectory() -> URL {
  let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
  return paths[0]
}

func readPlainTextFile(_ fileName: String) -> String {
  do {
    let fileData = try Data(contentsOf: getDocumentsDirectory().appendingPathComponent(fileName))
    let fileContent = String(decoding: fileData, as: UTF8.self)
    return fileContent
  } catch {
    return "error"
  }
}

func writePlainTextFile(_ content: String, to: String) {
  do {
    let fileURL = getDocumentsDirectory().appendingPathComponent(to)
    try content.write(to: fileURL, atomically: true, encoding: .utf8)
  } catch {
    print(error)
  }
}

func readDataFile(_ fileName: String) -> Data? {
  do {
    let fileData = try Data(contentsOf: getDocumentsDirectory().appendingPathComponent(fileName))
    return fileData
  } catch {
    print(error)
    return nil
  }
}

func writeDataFile(_ content: Data, to: String) {
  do {
    let fileURL = getDocumentsDirectory().appendingPathComponent(to)
    try content.write(to: fileURL)
  } catch {
    print(error)
  }
}

struct DismissButton<L: View>: View {
  var action: () -> Void
  var label: () -> L
  var doDismiss: Bool = true
  @Environment(\.dismiss) var dismiss
  var body: some View {
    Button(action: {
      action()
      if doDismiss {
        dismiss()
      }
    }, label: {
      label()
    })
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

func getStorageDictionary() -> [String: Any]? {
  let prefPath = NSHomeDirectory() + "/Library/Preferences/\(Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String).plist"
  if let plistData = FileManager.default.contents(atPath: prefPath) {
    do {
      if var plistObject = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
        return plistObject
      }
    } catch {
      print(error)
    }
  }
  return nil
}

extension String {
  func urlEncoded() -> String {
    let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
        .urlQueryAllowed)
    return encodeUrlString ?? ""
  }
  
  func urlDecoded() -> String {
    return self.removingPercentEncoding ?? ""
  }
  
  func isURL() -> Bool {
    var topLevelDomainList = (try! String(contentsOf: Bundle.main.url(forResource: "TopLevelDomainList", withExtension: "txt")!, encoding: .utf8))
      .split(separator: "\n")
      .map { String($0) }
    topLevelDomainList.removeAll(where: { str in str.hasPrefix("#") || str.isEmpty })
    if let topLevel = getTopLevel(from: self), topLevelDomainList.contains(topLevel.uppercased().replacingOccurrences(of: " ", with: "")) {
      return true
    } else if self.hasPrefix("http://") || self.hasPrefix("https://") {
      return true
    } else if self.components(separatedBy: ".").count == 4 {
      var components = self.components(separatedBy: ".")
      if components[3].components(separatedBy: ":").count == 2 {
        if (Int(components[3].components(separatedBy: ":")[1]) ?? 999) > 65535 {
          return false
        }
        components[3] = components[3].components(separatedBy: ":")[0]
      }
      for i in 0...3 {
        if (Int(components[i]) ?? 266) > 255 {
          return false
        }
      }
      return true
    } else {
      return false
    }
  }
  
  func numberOfOccurrencesOf(_ string: String) -> Int {
    let theArray = self.components(separatedBy: string)
    return theArray.count - 1
  }
}

extension Array {
  subscript(from index: Int) -> Element? {
    return self.indices ~= index ? self[index] : nil
  }
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

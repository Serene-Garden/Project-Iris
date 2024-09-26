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

//var webpageIsDisplaying: Bool = false

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
      let webpageURLRequest = URLRequest(url: URL(string: (optimizedIsURL! ? optimizedSearchField : optimizedSearchEngine.lowercased().replacingOccurrences(of: "\\iris", with: optimizedSearchField)).urlEncoded())!)
      webpageConfig.load(webpageURLRequest)
      webpageContent = webpageConfig
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

public extension String {
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

//
//  Migration.swift
//  Project Iris
//
//  Created by ThreeManager785 on 11/4/24.
//

import Foundation
import SwiftUI
import SwiftSoup

//let passkey = "bread"
//let gridOffset = "CYBERlumin"
let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
let onlineDocKeys = ["4B38CC11-805D-65AE-E127-0156FFE4E334", "49EEB494-98BE-B7B3-3018-4B5A8589CA98", "503E86E2-DB74-BECF-765A-6472F4BA8AB9"]

struct MigrationView: View {
  @AppStorage("lastMigrationTime") var lastMigrationTime = 0.0
  @AppStorage("lastMigrationCode") var lastMigrationCode = ""
  @AppStorage("lastMigrationSlot") var lastMigrationSlot = -1
  @State var lastMigrationStatus = 0
    //  @State var lastMigrationValidTime = 30
  
  let lastMigrationStatusLocalizedStringKey: [Int: LocalizedStringKey] = [1: "Migration.cooldown.status.invalid", 2: "Migration.cooldown.status.valid"]
  let lastMigrationStatusColor: [Int: Color] = [1: .red, 2: .green]
  var body: some View {
    List {
      HStack {
        Spacer()
        VStack {
          Image(systemName: "square.on.square.badge.person.crop")
            .foregroundStyle(.blue)
            .font(.title)
          Text("Migration.title")
            .bold()
            .font(.title3)
          Text("Migration.caption")
            .font(.footnote)
            .multilineTextAlignment(.center)
        }
        Spacer()
      }
      .listRowBackground(Color.clear)
      if lastMigrationSlot != -1 {
        VStack(alignment: .leading) {
          Text(lastMigrationCode)
            .bold()
            .fontDesign(.monospaced)
            .font(.footnote)
            .scaledToFit()
          Group {
            if lastMigrationStatus == 1 || lastMigrationStatus == 2 {
              Text("Migration.cooldown.period.\(Int((1800 - Date.now.timeIntervalSince1970 + lastMigrationTime)/60))") + Text(verbatim: " · ") + Text(lastMigrationStatusLocalizedStringKey[lastMigrationStatus]!).foregroundColor(lastMigrationStatusColor[lastMigrationStatus]!)
            } else {
              Text("Migration.cooldown.period.\(Int((1800 - Date.now.timeIntervalSince1970 + lastMigrationTime)/60))")
            }
          }
          .foregroundColor(.secondary)
          .font(.caption)
            //          .onAppear {
            //            lastMigrationValidTime = Int((1800 - Date.now.timeIntervalSince1970 + lastMigrationTime)/60)
            //          }
        }
      } else {
        NavigationLink(destination: {
          MigrationSendView()
        }, label: {
          HStack {
            Label("Migration.send", systemImage: "paperplane")
            Spacer()
            Image(systemName: "chevron.forward")
              .foregroundStyle(.secondary)
          }
        })
      }
      NavigationLink(destination: {
        MigrationRecieveView()
      }, label: {
        HStack {
          Label("Migration.recieve", systemImage: "square.and.arrow.down")
          Spacer()
          Image(systemName: "chevron.forward")
            .foregroundStyle(.secondary)
        }
      })
    }
    .navigationTitle("Migration")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      if Date.now.timeIntervalSince1970 - lastMigrationTime > 1800 {
        lastMigrationCode = ""
        lastMigrationSlot = -1
        lastMigrationTime = 0
        lastMigrationStatus = 0
          //        lastMigrationValidTime = 30
      } else {
        readOnlineDocContent(onlineDocKeys[lastMigrationSlot], completion: { value in
          if value != nil {
            lastMigrationStatus = (validateMigrationPackage(value!, encryption: getEncryptionStrings([lastMigrationCode])) == nil ? 1 : 2)
          } else {
            lastMigrationStatus = 1
          }
        })
      }
    }
  }
}

func createRandomPasskey(_ digits: Int = 3) -> [String] {
  //  if digits == 0 {
  var passkeyList = (try! String(contentsOf: Bundle.main.url(forResource: "MigrationKeyList", withExtension: "txt")!, encoding: .utf8))
    .split(separator: "\n")
    .map { String($0) }
  
  var passkeyWords = Array(repeating: "", count: digits)
  for i in 0..<digits {
    passkeyWords[i] = passkeyList.randomElement()!
  }
  return passkeyWords
  //  } else {
  //    var result = String(Int.random(in: 0..<(10^digits)))
  //    while result.count < digits {
//      result = "0" + result
//    }
//    return result
//  }
}

func createVigenereCipher(_ gridOffset: String, alphabet: String) -> [Substring] {
  //Create Vigenere Cipher Index Set
  var alphabetArray = alphabet.split(separator: "")
  var gridOffsetArray: [Substring] = gridOffset.split(separator: "").reversed()
  for charIndex in 0..<gridOffsetArray.count {
    var alphabetIndex = alphabetArray.firstIndex(of: gridOffsetArray[charIndex]) ?? 0
    if alphabetArray.firstIndex(of: gridOffsetArray[charIndex]) == nil {
    }
    alphabetArray.insert(alphabetArray.remove(at: alphabetIndex), at: 0)
  }
  return alphabetArray
}

func encryptMigrationData(_ source: String, encryption: (String, String)) -> String {
  let passkey = encryption.0
  let gridOffset = encryption.1
  let encodedSource = encodeBase64(source)
//  let encodedSource = source
  let alphabetArray = createVigenereCipher(gridOffset, alphabet: alphabet)
  
  //Vigenere Encode
  let passkeyArray = passkey.split(separator: "")
  let sourceArray = encodedSource.split(separator: "")
  var vigenereResult = ""
  var sourceCharIndex = 0
  var passkeyIndex = 0
  var alphabetIndex = 0
  for sourceIndex in 0..<sourceArray.count {
    sourceCharIndex = alphabetArray.firstIndex(of: sourceArray[sourceIndex]) ?? 0
    passkeyIndex = sourceIndex%passkeyArray.count
    alphabetIndex = (sourceCharIndex+passkeyIndex)%alphabetArray.count
    vigenereResult.append(String(alphabetArray[alphabetIndex]))
  }
  
  return vigenereResult
  
  func encodeBase64(_ originalString: String) -> String {
    let data = originalString.data(using: .utf8)!
    let base64String = data.base64EncodedString()
    return base64String
  }
}

func decryptMigrationData(_ source: String, encryption: (String, String)) -> String? {
  let passkey = encryption.0
  let gridOffset = encryption.1
  let alphabetArray = createVigenereCipher(gridOffset, alphabet: alphabet)
  
  let sourceArray = source.split(separator: "")
  var vigenereResult = ""
  var alphabetIndex = 0
  var passkeyIndex = 0
  var resultIndex = 0
  for sourceIndex in 0..<sourceArray.count {
    alphabetIndex = alphabetArray.firstIndex(of: sourceArray[sourceIndex]) ?? 0
    passkeyIndex = sourceIndex%passkey.count
    resultIndex = (alphabetIndex-passkeyIndex+alphabetArray.count)%alphabetArray.count
    vigenereResult.append(String(alphabetArray[resultIndex])) //(number−c+n)%n
  }
  
  return decodeBase64(vigenereResult)
  
  func decodeBase64(_ source: String) -> String? {
    if let data = Data(base64Encoded: source),
       let decodedString = String(data: data, encoding: .utf8) {
      return decodedString
    } else {
      return nil
    }
  }
}

func writeOnlineDocContent(_ id: String, content: String, completion: @escaping (Bool) -> Void) {
  fetchWebPageContent(urlString: "https://api.textdb.online/update/?key=\(id)&value=\(content)") { result in
    switch result {
    case .success(let result):
        completion(true)
    case .failure(let error):
        completion(false)
    }
  }
}

func readOnlineDocContent(_ id: String, completion: @escaping (String?) -> Void) {
  fetchWebPageContent(urlString: "https://textdb.online/\(id)") { result in
    switch result {
    case .success(let content):
        completion(content)
    case .failure(let error):
        print(error)
        print(id)
        print("https://textdb.online/\(id)")
        completion(nil)
    }
  }
}

func checkNewMigrationAvailablility(completion: @escaping (Int) -> Void) {
  readOnlineDocContent(onlineDocKeys[0]) { result in
    if !(result == nil || sourceIsAvailable(result ?? "nil")) {
      readOnlineDocContent(onlineDocKeys[1]) { result1 in
        if !(result == nil || sourceIsAvailable(result1 ?? "nil")) {
          readOnlineDocContent(onlineDocKeys[2]) { result2 in
            if result2 == nil {
              completion(-2) //Unconnectable
            } else if !sourceIsAvailable(result2 ?? "nil") {
              completion(-1) //Time all below 30min
            } else {
              completion(2)
            }
          }
        } else {
          completion(1)
        }
      }
    } else {
      completion(0)
    }
  }
}

func sourceIsAvailable(_ source: String) -> Bool {
  if source == "free" {
    return true
  } else if source == "nil" {
    return false
  } else if source.contains("|") {
    var timestamp = Double(source.components(separatedBy: "|").first ?? "30000")
    if timestamp != nil {
      if Date.now.timeIntervalSince(Date.init(timeIntervalSince1970: timestamp!)) < 1800 { //<30min
        return false
      } else {
        return true
      }
    } else {
      return false
    }
  } else if source.isEmpty {
    return true
  } else {
    return false
  }
}

func createMigrationPackage(_ encryption: (String, String)) -> String {
  var content = ""
  
  //Settings
  content += getSettingsForAppdiagnose { data in
    data.removeValue(forKey: "correctPasscode")
    data.removeValue(forKey: "UserNotificationToken")
  } ?? "nil"
  content += "|"
  
  content += readPlainTextFile("BookmarkLibrary.txt").replacingOccurrences(of: "\n", with: "\\n")
  content += "|"
  
  content += readPlainTextFile("historyData.txt").replacingOccurrences(of: "\n", with: "\\n")
  content += "|"
  
  content.append("IRIS-EOF")
  
//  content = "春天，树叶开始闪出黄青，花苞轻轻地在风中摆动，似乎还带着一种冬天的昏黄。可是只要经过一场春雨的洗淋，那种颜色和神态是难以想象的。每一棵树仿佛都睁开特别明亮的眼睛。树枝的手臂也顿时柔软了，而那萌发的叶子，简直就像起伏着一层绿茵茵的波浪。水珠子从花苞里滴下来，比少女的眼泪还娇媚。半空中似乎总挂着透明的水雾的丝帘，牵动着阳光的彩棱镜。这时，整个大地是美丽的。小草似乎像复苏的蚯蚓一样翻动，发出一种春天才能听到的沙沙声。呼吸变得畅快，空气里像有无数芳甜的果子，在诱惑着鼻子和嘴唇。真的，只有这一场雨，才完全驱走了冬天，才使世界改变了姿容。|IRIS-EOF"
  content = encryptMigrationData(content, encryption: encryption)
  
  var package = String(Date.now.timeIntervalSince1970) + "|" + content
  package = package.replacingOccurrences(of: "/", with: "@").replacingOccurrences(of: "+", with: "-")
  
  return package
}

func validateMigrationPackage(_ package: String, encryption: (String, String)) -> String? {
  var packageSplitted = package.split(separator: "|", maxSplits: 1)
  var content = ""
  if packageSplitted.count <= 1 {
    return nil
  } else {
    content = String(packageSplitted[1])
  }
  content = content.replacingOccurrences(of: "@", with: "/").replacingOccurrences(of: "-", with: "+")
  var decryptedMessage = decryptMigrationData(content, encryption: encryption)
  if decryptedMessage == nil {
    return nil
  } else if decryptedMessage!.isEmpty {
    return nil
  } else if !decryptedMessage!.hasSuffix("IRIS-EOF") {
    return nil
  } else {
    print("[decryption]\(decryptedMessage)")
    return decryptedMessage
  }
}

func applyMigrationPackage(_ package: String) {
  var source = package.replacingOccurrences(of: "\\n", with: "\n")
  var packageSections = (source.split(separator: "|").dropLast()).map { String($0) }
  //[Settings, Bookmarks, History]
  writePlainTextFile(packageSections[1], to: "BookmarkLibrary.txt")
  writePlainTextFile(packageSections[2], to: "historyData.txt")
  
  
}

func getEncryptionStrings(_ source: [String]) -> (String, String) {
  var plainString = ""
  if source.count > 1 {
    for i in 0..<source.count {
      plainString.append(source[i])
    }
  } else {
    plainString = source.first!.replacingOccurrences(of: " ", with: "")
  }
  
  let splitIndex = max(0, plainString.count - 5)
  let prefixPart = String(plainString.prefix(splitIndex))
  let suffixPart = String(plainString.suffix(5))
  
  return (prefixPart, suffixPart)
}

func getReadableCode(_ passkey: [String]) -> String {
  var readablePasskey = ""
//  .onChange(of: passkey, perform: { value in
    for i in 0..<passkey.count {
      readablePasskey.append(passkey[i])
      if i != passkey.count-1 {
        readablePasskey.append(" ")
      }
    }
//  })
  return readablePasskey
}

func parseSettingsValuesJSON(_ source: String) -> [String: Any] {
  if let data = source.data(using: .utf8) {
    do {
        // 将 JSON 数据转换成字典格式
      let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      
        // 输出转换后的字典
      if let jsonDict = jsonDict {
        return jsonDict
      }
    } catch {
      print("JSON解析错误: \(error.localizedDescription)")
    }
  }
  return [:]
}

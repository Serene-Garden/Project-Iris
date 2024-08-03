//
//  CarinaProgressView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI
import Cepheus

struct CarinaDetailView: View {
  var carinaID: Int
  @State var status = 1
  @State var carinaInfos: [String: String] = [:]
  @State var contentIsExpanded = false
  let dateFormatter = DateFormatter()
  //For accessing web
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  var body: some View {
    NavigationStack {
      if status == 0 { //Ready
        List {
          Section {
            Text(carinaInfos["Title"] ?? String(localized: "Carina.details.unknown"))
              .bold()
            NavigationLink(destination: {
              List {
                HStack {
                  Image(systemName: carinaStateIcons[Int(carinaInfos["State"] ?? "8") ?? 8] ?? "ellipsis")
                  Text(carinaStates[Int(carinaInfos["State"] ?? "8") ?? 8] ?? "Carina.info.load")
                  Spacer()
                  Circle()
                    .frame(width: 10)
                    .foregroundStyle(carinaStateColors[Int(carinaInfos["State"] ?? "8") ?? 8] ?? .secondary)
                    .padding(.trailing, 7)
                }
                .bold()
                Text(carinaStateDescription[Int(carinaInfos["State"] ?? "8") ?? 8] ?? "Carina.info.load")
              }
              .navigationTitle(carinaStates[Int(carinaInfos["State"] ?? "8") ?? 8] ?? "Carina.info.load")
            }, label: {
              HStack {
                Circle()
                  .frame(width: 10)
                  .foregroundStyle(carinaStateColors[Int(carinaInfos["State"] ?? "8") ?? 8] ?? .secondary)
                  .padding(.horizontal, 7)
                Text(carinaStates[Int(carinaInfos["State"] ?? "8") ?? 8] ?? "Carina.info.load")
                Spacer()
              }
            })
            if carinaInfos["Body"] != "none" {
              Button(action: {
                contentIsExpanded.toggle()
              }, label: {
                Text(carinaInfos["Body"] ?? String(localized: "Carina.details.unknown"))
                  .multilineTextAlignment(.leading)
                  .lineLimit(contentIsExpanded ? nil : 3)
              })
            }
          }
          Section {
            NavigationLink(destination: {
              CarinaRepliesView(carinaID: carinaID)
            }, label: {
              HStack {
                Label("Carina.reply.\(Int(carinaInfos["ReplyCount"] ?? "0") ?? 0)", systemImage: "arrowshape.turn.up.left")
                Spacer()
                Image(systemName: "chevron.forward")
                  .foregroundStyle(.secondary)
              }
            })
          }
          Section {
            HStack {
              Image(systemName: "rectangle.3.group")
              Text(carinaTypes[Int(carinaInfos["CarinaType"] ?? "8") ?? 8] ?? "Carina.type.other")
              Spacer()
            }
            HStack {
              Image(systemName: "mappin.and.ellipse")
              Text(carinaPlaces[Int(carinaInfos["IrisPlace"] ?? "8") ?? 8] ?? "Carina.place.other")
              Spacer()
            }
            HStack {
              Image(systemName: "clock")
              Text(dateFormatter.string(from: Date(timeIntervalSince1970: (Double(carinaInfos["CarinaTime"] ?? "0") ?? 0))))
              Spacer()
            }
            HStack {
              Image(systemName: "applewatch.side.right")
              Text("watchOS \(carinaInfos["OS"] ?? String(localized: ("Carina.details.unknown")))")
              Spacer()
            }
            HStack {
              Image(systemName: "app.badge")
              Text("Iris \(carinaInfos["Version"] ?? String(localized: ("Carina.details.unknown")))")
              Spacer()
            }
            if carinaInfos["AttachedLinks"] != nil {
              NavigationLink(destination: {
                List {
                  ForEach(0..<(stringToStringArray(carinaInfos["AttachedLinks"]!)!.count)) { linkIndex in
                    Button(action: {
                      searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: stringToStringArray(carinaInfos["AttachedLinks"]!)![linkIndex], isCookiesAllowed: isCookiesAllowed, searchEngine: "")
                    }, label: {
                      Text(stringToStringArray(carinaInfos["AttachedLinks"]!)![linkIndex])
                    })
                  }
                }
                .navigationTitle("Carina.new.attachments.links")
              }, label: {
                HStack {
                  Image(systemName: "link")
                  Text("Carina.new.attachments.links.\(stringToStringArray(carinaInfos["AttachedLinks"]!)!.count)")
                  Spacer()
                  Image(systemName: "chevron.forward")
                    .foregroundStyle(.secondary)
                }
              })
            }
          }
        }
      } else if status == 2 { //Deleted
        if #available(watchOS 10, *) {
          ContentUnavailableView {
            Label("Carina.details.deleted", systemImage: "trash")
          } description: {
            Text("Carina.details.deleted.description")
          }
        } else {
          List {
            Text("Carina.details.deleted")
              .bold()
            Text("Carina.details.deleted.description")
          }
          .foregroundStyle(.secondary)
        }
      } else if status == 3 { //Connection Failure
        if #available(watchOS 10, *) {
          ContentUnavailableView {
            Label("Carina.details.connection-failure", systemImage: "bolt.horizontal")
          } description: {
            Text("Carina.details.connection-failure.description")
          }
        } else {
          List {
            Text("Carina.details.connection-failure")
              .bold()
            Text("Carina.details.connection-failure.description")
          }
          .foregroundStyle(.secondary)
        }
      } else { //Fetching (expected)
        ProgressView()
      }
    }
    .onAppear {
      status = 1
      dateFormatter.dateStyle = .short
      dateFormatter.timeStyle = .short
      getCarinaInformations(carinaID: carinaID, completion: { result in
        carinaInfos = result ?? [:]
        if carinaInfos.contains(where: { $0.key == "Error" }) {
          status = 2
        } else if carinaInfos.isEmpty {
          status = 3
        } else {
          status = 0
        }
      })
    }
    .navigationTitle("#\(String(carinaID))")
  }
}

struct CarinaRepliesView: View {
  var carinaID: Int
  @State var ready = false
  @State var replies: [[String: String]] = []
  @State var repliesExpanded: [Int: Bool] = [:]
  @State var showSendingSheet = false
  let dateFormatter = DateFormatter()
  var body: some View {
    NavigationStack {
      if ready {
        if replies.count > 0 {
          List {
            if #unavailable(watchOS 10) {
              Button(action: {
                showSendingSheet = true
              }, label: {
                Label("Carina.reply.send.title", systemImage: "paperplane")
              })
            }
            ForEach(0..<replies.count, id: \.self) { replyIndex in
              Section(content: {
                if repliesExpanded[replyIndex]! {
                  if replies[replyIndex]["State"] != nil {
                    HStack {
                      Image(systemName: carinaStateIcons[Int(replies[replyIndex]["State"]!) ?? 8] ?? "ellipsis")
                      Text(carinaStates[Int(replies[replyIndex]["State"]!) ?? 8] ?? "Carina.info.load")
                      Spacer()
                      Circle()
                        .frame(width: 10)
                        .foregroundStyle(carinaStateColors[Int(replies[replyIndex]["State"]!) ?? 8] ?? .secondary)
                        .padding(.trailing, 7)
                    }
                  }
                  if replies[replyIndex]["Content"] != nil {
                    Label(replies[replyIndex]["Content"]!, systemImage: "text.bubble")
                  }
                }
              }, header: {
                HStack {
                  Text(replies[replyIndex]["Sender"] ?? String(localized: "Carina.reply.sender.unknown"))
                  Spacer()
                  Image(systemName: "chevron.forward")
                    .rotationEffect(Angle(degrees: repliesExpanded[replyIndex]! ? 90 : 0))
                    .overlay {
                      Rectangle()
                        .opacity(0.02)
                        .onTapGesture {
                          withAnimation {
                            repliesExpanded[replyIndex]?.toggle()
                          }
                        }
                    }
                }
                .font(.caption)
                .fontWeight(.medium)
              }, footer: {
                if replies[replyIndex]["Time"] != nil {
                  Text(dateFormatter.string(from: Date(timeIntervalSince1970: (Double(replies[replyIndex]["Time"]!) ?? 0))))
                }
              })
            }
          }
        } else {
          if #available(watchOS 10, *) {
            ContentUnavailableView {
              Label("Carina.reply.none", systemImage: "bubble.and.pencil")
            } description: {
              Text("Carina.reply.none.description")
            }
          } else {
            List {
              if #unavailable(watchOS 10) {
                Button(action: {
                  showSendingSheet = true
                }, label: {
                  Label("Carina.reply.send.title", systemImage: "paperplane")
                })
              }
              Text("Carina.reply.none")
                .bold()
              Text("Carina.reply.none.description")
            }
            .foregroundStyle(.secondary)
          }
        }
      } else {
        ProgressView()
      }
    }
    .navigationTitle("Carina.reply")
    .onAppear {
      ready = false
      dateFormatter.dateStyle = .short
      dateFormatter.timeStyle = .short
      getCarinaReplies(carinaID: carinaID, completion: { result in
        replies = result
        for index in 0..<replies.count {
          repliesExpanded.updateValue(true, forKey: index)
        }
        ready = true
      })
    }
    .toolbar {
      if #available(watchOS 10.0, *) {
        ToolbarItemGroup(placement: .bottomBar, content: {
          HStack {
            Spacer()
            Button(action: {
              showSendingSheet = true
            }, label: {
              Image(systemName: "paperplane")
            })
          }
        })
      }
    }
    .sheet(isPresented: $showSendingSheet, content: {
      CarinaReplySendingView(carinaID: carinaID)
        .onDisappear {
          getCarinaReplies(carinaID: carinaID, completion: { result in
            replies = result
            for index in 0..<replies.count {
              repliesExpanded.updateValue(true, forKey: index)
            }
            ready = true
          })
        }
    })
  }
}

struct CarinaReplySendingView: View {
  var carinaID: Int
  @State var message: String = ""
  var body: some View {
    NavigationStack {
      List {
        Section(content: {
          CepheusKeyboard(input: $message, prompt: "Carina.reply.send.content")
          DismissButton(action: {
            var package = """
Sender：Iris \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
Content：\(message)
Time：\(Date().timeIntervalSince1970)
"""
            var encodedPackage = (package.data(using: .utf8)?.base64EncodedString() ?? "").replacingOccurrences(of: "/", with: "{slash}")
            fetchWebPageContent(urlString: "https://fapi.darock.top:65535/radar/reply/Project Iris/\(carinaID)/\(encodedPackage)".urlEncoded(), completion: { result in
              switch result {
                case .success(let content):
                  DispatchQueue.main.async {
                    showTip("Carina.reply.send.success", symbol: "paperplane")
                  }
                case .failure(let error):
                  DispatchQueue.main.async {
                    showTip("Carina.reply.send.failure", symbol: "xmark")
                  }
              }
            })
          }, label: {
            Label("Carina.reply.send.button", systemImage: "paperplane")
          })
          .disabled(message.isEmpty)
        }, footer: {
          Text("Carina.reply.send.sign.\("Iris \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")")
        })
      }
      .navigationTitle("Carina.reply.send.title")
    }
  }
}


func getCarinaInformations(carinaID: Int, getTitle: Bool = true, completion: @escaping ([String: String]?) -> Void) {
  var output: [String: String] = [:]
  fetchWebPageContent(urlString: "https://fapi.darock.top:65535/radar/details/Project Iris/\(carinaID)".urlEncoded()) { result in
    switch result {
      case .success(let content):
        getDictionary(content, completion: { result in
          output = result
        })
      case .failure(let error):
        print("Carina Fetch Failure")
        output = [:]
    }
    completion(output)
  }
}

func getCarinaReplies(carinaID: Int, completion: @escaping ([[String: String]]) -> Void) {
  var output: [[String: String]] = []
  fetchWebPageContent(urlString: "https://fapi.darock.top:65535/radar/details/Project Iris/\(carinaID)".urlEncoded()) { result in
    switch result {
      case .success(let content):
        var originalContent = content
        originalContent.removeFirst()
        originalContent.removeLast()
        var breakedContent = originalContent.components(separatedBy: "---")
        breakedContent.remove(at: 0)
        if breakedContent.count > 0 {
          for replyIndex in 0..<breakedContent.count {
            getDictionary(breakedContent[replyIndex], removeQuoteMark: false, getTitle: false, completion: { result in
              output.append(result)
            })
          }
        }
      case .failure(let error):
        print("Carina Fetch Failure")
        output = []
    }
    completion(output.reversed())
  }
}

func getDictionary(_ content: String, removeQuoteMark: Bool = true, getTitle: Bool = true, completion: @escaping ([String: String]) -> Void) {
  var originalContent = content
  if removeQuoteMark {
    originalContent.removeFirst()
    originalContent.removeLast()
  }
  var output: [String: String] = [:]
  if originalContent != "Internal Server Error" && !originalContent.isEmpty {
    let parsedContent: [String] = originalContent.components(separatedBy: "\\n")
    var currentLineKey = ""
    var currentLineContent = ""
    var replyCounts = 0
    for lineIndex in 0..<parsedContent.count {
      if lineIndex == 0 && getTitle {
        output.updateValue(parsedContent[lineIndex], forKey: "Title")
      } else {
        if !parsedContent[lineIndex-(lineIndex == 0 ? 0 : 1)].hasSuffix("\\") { //If the last line was terminated (does not ends with a back-slash), then a new key should appear.
          currentLineKey = String(parsedContent[lineIndex].split(separator: "：").first ?? "Unknown") //Get the key
          currentLineContent = parsedContent[lineIndex].replacingOccurrences(of: "\(currentLineKey)：", with: "") //Get the content by replacing the key with an empty string.
        } else { //Last line not terminated then append this whole line to the last content.
          currentLineContent.append(parsedContent[lineIndex].replacingOccurrences(of: "\\", with: ""))
        }
        if !parsedContent[lineIndex].hasSuffix("\\") { //If this line does not ends with back-slash (content not terminated), then do save.
          if parsedContent[lineIndex] != "---" {
            output.updateValue(currentLineContent, forKey: currentLineKey)
          } else {
            replyCounts += 1
            output.updateValue(String(replyCounts), forKey: "ReplyCount")
          }
        } //No need to handle unterminated content and just let it do the next repeat.
      }
    }
    completion(output)
  } else {
    print("Carina Fetch Info Invalid")
    completion(["Error": "true"])
  }
}

func decodeBase64(string: String) -> String? {
  guard let data = Data(base64Encoded: string) else {
    return nil
  }
  
  return String(data: data, encoding: .utf8)
}

func stringToStringArray(_ input: String) -> [String]? {
  var source = input
  var output: [String]
  if source.hasPrefix("[") && source.hasSuffix("]") {
    source.removeFirst()
    source.removeLast()
    output = source.components(separatedBy: ",")
    for i in 0..<output.count {
        output[i] = String(output[i].dropFirst().dropLast().dropFirst().dropLast())
    }
    return output
  } else {
    return nil
  }
}

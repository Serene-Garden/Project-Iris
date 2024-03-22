//
//  CarinaProgressView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI

struct CarinaProgressView: View {
  var carinaID: Int
  @State var originalPackage = ""
  @State var originalDecoded = [""]
  @State var package = ""
  @State var packageInfo = [""]
  @State var title = ""
  @State var details = ""
  @State var type: Int = 0
  @State var place: Int = 0
  @State var state: Int = 8
  @State var version: String = ""
  @State var isTitleExpanded = false
  @State var isNewReplyDisplaying = false
  @State var is_watchOS10 = false
  @State var replyContent = ""
  @State var updateSendState = 0
  @State var source = ""
  var body: some View {
    NavigationStack {
      List {
        if title.isEmpty {
          Section(content: {
            NavigationLink(destination: {
              List {
                Text("Carina.loading.waiting-too-long")
                  .bold()
                Text("Carina.loading.check-internet")
                Text("Carina.loading.deleted")
                Text("Carina.loading.server-problem")
              }
            }, label: {
              Text("Carina.loading")
                .bold()
                .foregroundStyle(.secondary)
            })
            
          }, footer: {
            Text("Carina.loading.footer")
          })
        } else if package == "Error" {
          VStack {
            Image(systemName: "questionmark.bubble")
              .font(.largeTitle)
            //.bold()
            Text("Carina.failed-fetching")
          }
        } else {
          Text(title)
            .bold()
            .lineLimit(isTitleExpanded ? 1145 : 2)
            .onTapGesture {
              isTitleExpanded.toggle()
            }
          NavigationLink(destination: {
            List {
              HStack {
                Image(systemName: carinaStateIcons[state])
                Text(carinaStates[state])
                Spacer()
                Circle()
                  .frame(width: 10)
                  .foregroundStyle(carinaStateColors[state])
                  .padding(.trailing, 7)
              }
              .bold()
              Text(carinaStateDescription[state])
            }
            .navigationTitle("Carina.state")
          }, label: {
            HStack {
              Circle()
                .frame(width: 10)
                .foregroundStyle(carinaStateColors[state])
                .padding(.trailing, 7)
              Text(carinaStates[state])
              Spacer()
            }
            .padding()
          })
          Text(carinaTypes[type]) + Text(" · ") + Text(carinaPlaces[place]) + Text(" · ") + Text(version)
          if !details.isEmpty && details != "none" {
            NavigationLink(destination: {
              List{Text(details)}
                .navigationTitle("Carina.content")
            }, label: {
              Text(details)
                .font(.caption)
                .lineLimit(3)
            })
          }
          if source.isEmpty {
            NavigationLink(destination: {
              List {
                if #available(watchOS 10.0, *) {} else {
                  Button(action: {
                    isNewReplyDisplaying = true
                  }, label: {
                    Label("Carina.reply.add", systemImage: "arrowshape.turn.up.left")
                  })
                }
                if originalDecoded.count > 1 {
                  Section(content: {
                    ForEach(1..<originalDecoded.count, id: \.self) {update in
                      VStack(alignment: .leading) {
                        if originalDecoded[update].components(separatedBy: "\\n")[0].components(separatedBy: "：")[0] == "State" {
                          Text("Carina.reply.state")
                            .bold()
                          Label(carinaStates[Int(String(originalDecoded[update].components(separatedBy: "\\n")[0].components(separatedBy: "：")[1]))!], systemImage: carinaStateIcons[Int(String(originalDecoded[update].components(separatedBy: "\\n")[0].components(separatedBy: "：")[1]))!]).foregroundColor(carinaStateColors[Int(String(originalDecoded[update].components(separatedBy: "\\n")[0].components(separatedBy: "：")[1]))!])
                        } else {
                          Text(originalDecoded[update].components(separatedBy: "\\n")[0].components(separatedBy: "：")[0])
                            .bold()
                          Text(originalDecoded[update].components(separatedBy: "\\n")[0].components(separatedBy: "：")[1])
                        }
                      }
                    }
                  })
                } else {
                  Text("Carina.reply.none")
                    .bold()
                    .foregroundColor(.secondary)
                }
              }
              .navigationTitle("Carina.reply")
              .toolbar {
                if #available(watchOS 10.0, *) {
                  ToolbarItem(placement: .bottomBar) {
                    HStack {
                      Spacer()
                      Button(action: {
                        isNewReplyDisplaying = true
                      }, label: {
                        Image(systemName: "arrowshape.turn.up.left")
                      })
                    }
                  }
                }
              }
              .sheet(isPresented: $isNewReplyDisplaying, content: {
                Group {
                  if updateSendState == 0 {
                    List {
                      Section(content: {
                        TextField("Carina.reply.send.content", text: $replyContent)
                        Button(action: {
                          if !isOpenSource {
                            fetchWebPageContent(urlString: "\(carinaUpdateAPI)\(carinaID)/\("Iris \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)\(is_watchOS10 ? "" : "!")：\(replyContent)".data(using: .utf8)?.base64EncodedString() ?? "")") { result in
                              switch result {
                              case .success(let content):
                                if content.components(separatedBy: "\"")[1] == "Success" {
                                  updateSendState = 1
                                } else {
                                  updateSendState = 3
                                }
                              case .failure(let error):
                                updateSendState = 2
                              }
                            }
                          }
                        }, label: {
                          Label("Carina.reply.send", systemImage: "paperplane")
                        })
                      }, footer: {
                        Text("Carina.reply.send.by.\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                      })
                    }
                  } else if updateSendState == 1 {
                    VStack {
                      Image(systemName: "paperplane")
                        .font(.system(size: 50))
                      Text("Carina.reply.sent")
                      Text("Carina.reply.refresh-tip")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    }
                  } else {
                    VStack {
                      Image(systemName: "circle.badge.exclamationmark")
                        .font(.system(size: 50))
                      Text("Carina.reply.failed")
                      Text(updateSendState == 3 ? "Carina.reply.refuse" : "Carina.reply.disconnect")
                        .foregroundColor(.secondary)
                    }
                  }
                }
                .onDisappear {
                  updateSendState = 0
                }
              })
              .onAppear {
                if #available(watchOS 10.0, *) {
                  is_watchOS10 = true
                }
              }
            }, label: {
              Label(originalDecoded.count > 1 ? "Carina.reply.\(originalDecoded.count-1)" : "Carina.reply.none", systemImage: "arrowshape.turn.up.left")
            })
          }
        }
      }
      .navigationTitle("#\(carinaID)")
      .onAppear {
        if source.isEmpty {
          if !isOpenSource {
            fetchWebPageContent(urlString: "\(carinaPullFeedbackAPI)\(carinaID)") { result in
              switch result {
              case .success(let content):
                originalPackage = content.components(separatedBy: "\"")[1]
                originalDecoded = originalPackage.components(separatedBy: "---\\n")
                package = originalDecoded[0]
                packageInfo = package.components(separatedBy: "\\n")
                title = packageInfo[0]
                
                for i in 1..<packageInfo.count {
                  if packageInfo[i].hasPrefix("Type：") {
                    type = Int(packageInfo[i].components(separatedBy: "Type：")[1]) ?? 4
                  } else if packageInfo[i].hasPrefix("Place：") {
                    place = Int(packageInfo[i].components(separatedBy: "Place：")[1]) ?? 8
                  } else if packageInfo[i].hasPrefix("State：") {
                    state = Int(packageInfo[i].components(separatedBy: "State：")[1]) ?? 8
                  } else if packageInfo[i].hasPrefix("Content：") {
                    details = packageInfo[i].components(separatedBy: "Content：")[1]
                  } else if packageInfo[i].hasPrefix("Version：") {
                    version = packageInfo[i].components(separatedBy: "Version：")[1]
                  }
                }
                if originalDecoded.count > 1 {
                  for i in 1..<originalDecoded.count {
                    if originalDecoded[i].components(separatedBy: "\\n")[0].components(separatedBy: "：")[0] == "State" {
                      state = Int(String(originalDecoded[i].components(separatedBy: "\\n")[0].components(separatedBy: "：")[1])) ?? 0
                    }
                  }
                }
              case .failure(let error):
                originalPackage = "Error"
                package = "Error"
              }
            }
          }
        } else {
          packageInfo = source.components(separatedBy: "\\\\n")
          title = packageInfo[0].contains("<lang>") ? (languageCode! == "zh" ? packageInfo[0].components(separatedBy: "<lang>")[0] : packageInfo[0].components(separatedBy: "<lang>")[1]) : packageInfo[0]
          
          for i in 1..<packageInfo.count {
            if packageInfo[i].hasPrefix("Type：") {
              type = Int(packageInfo[i].components(separatedBy: "Type：")[1]) ?? 4
            } else if packageInfo[i].hasPrefix("Place：") {
              place = Int(packageInfo[i].components(separatedBy: "Place：")[1]) ?? 8
            } else if packageInfo[i].hasPrefix("State：") {
              state = Int(packageInfo[i].components(separatedBy: "State：")[1]) ?? 8
            } else if packageInfo[i].hasPrefix("Content：") {
              //                            details = packageInfo[i].components(separatedBy: "Content：")[1]
              if packageInfo[i].components(separatedBy: "Content：")[1].contains("<lang>") {
                if languageCode! == "zh" {
                  details = packageInfo[i].components(separatedBy: "Content：")[1].components(separatedBy: "<lang>")[0]
                } else {
                  details = packageInfo[i].components(separatedBy: "Content：")[1].components(separatedBy: "<lang>")[1]
                }
              } else {
                details = packageInfo[i].components(separatedBy: "Content：")[1]
              }
              //                            details = packageInfo[i].components(separatedBy: "Content：")[1].contains("<lang>") ? (languageCode! == "zh" ? packageInfo[i].components(separatedBy: "Content：")[1].components(separatedBy: "<lang>")[0] : packageInfo[i].components(separatedBy: "Content：")[1].components(separatedBy: "<lang>")[1]) : packageInfo[i].components(separatedBy: "Content：")[1]
            } else if packageInfo[i].hasPrefix("Version：") {
              version = packageInfo[i].components(separatedBy: "Version：")[1]
            }
          }
        }
      }
    }
  }
}

func decodeBase64(string: String) -> String? {
  guard let data = Data(base64Encoded: string) else {
    return nil
  }
  
  return String(data: data, encoding: .utf8)
}

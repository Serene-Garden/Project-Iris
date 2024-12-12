//
//  CarinaNewView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import Cepheus
import RadarKitCore
import SwiftUI
import UserNotifications

struct CarinaNewView: View {
  var projectManager: RKCFeedbackManager = RKCFeedbackManager(projectName: "Project Iris")
  @AppStorage("feedbackTitle") var feedbackTitle: String = ""
  @AppStorage("feedbackContent") var feedbackContent: String = ""
  @State var carinaID = 0
  @State var sendDeviceInfos: Bool = true
  @State var sendSettingsValues: Bool = true
  @State var sendRegionInfos: Bool = false
  @State var sendBookmarkFiles: Bool = false
  @State var sendHistoryFiles: Bool = false
  @State var attachedLinks: [String] = []
  @State var lastHistoryID = UserDefaults.standard.integer(forKey: "lastHistoryID")
  @State var replyData: NewFeedbackData?
  @State var sending = false
  @State var recentThreeHistoryAttached = false
  var body: some View {
    NavigationStack {
      if carinaID == 0 {
        List {
          Section("Carina.new.app") {
            Text(verbatim: "Project Iris \(currentIrisVersion)")
          }
          Section(content: {
            CepheusKeyboard(input: $feedbackTitle, prompt: "Carina.new.describe.title")
            CepheusKeyboard(input: $feedbackContent, prompt: "Carina.new.describe.content")
          }, header: {
            Text("Carina.new.describe")
          }, footer: {
            VStack {
              Text("Carina.new.describe.footer.1")
              Text("Carina.new.describe.footer.2")
            }
          })
          Section(content: {
            NavigationLink(destination: {
              CarinaAttachmentsView(sendDeviceInfos: $sendDeviceInfos, sendSettingsValues: $sendSettingsValues, sendRegionInfos: $sendRegionInfos, sendBookmarkFiles: $sendBookmarkFiles, sendHistoryFiles: $sendHistoryFiles, attachedLinks: $attachedLinks)
            }, label: {
              HStack {
                Label("Carina.new.attachments", systemImage: "paperclip")
                Spacer()
                Text("\(countAttachmentNumbers(attachedLinks: attachedLinks, sendDeviceInfos, sendRegionInfos, sendHistoryFiles, sendBookmarkFiles, sendSettingsValues))")
                  .foregroundStyle(.secondary)
                Image(systemName: "chevron.forward")
                  .foregroundStyle(.secondary)
              }
            })
          }, header: {
            Text("Carina.new.attachments")
          }, footer: {
            Text("Carina.new.attachments.footer")
          })
          Section {
            Button(action: {
              Task {
                sending = true
                do {
//                  try replyData = .init(title: feedbackTitle, content: feedbackContent, sender: "User")
                  try replyData = .init(title: feedbackTitle, content: feedbackContent, sender: "User", additionalData: .rawString("""
OS：\(systemVersion)
Version：\(currentIrisVersion)
NotificationToken：\(UserDefaults.standard.string(forKey: "UserNotificationToken") ?? "None")
\(generateAttachmentDatas(sendDeviceInfos: sendDeviceInfos, sendSettingsValues: sendSettingsValues, sendRegionInfos: sendRegionInfos, sendBookmarkFiles: sendBookmarkFiles, sendHistoryFiles: sendHistoryFiles, attachedLinks: attachedLinks))
"""))
                } catch {
                  print(error)
                }
                carinaID = await projectManager.newFeedback(replyData!) ?? -1
                if carinaID > 0 {
                  var personalFeedbacks = (UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []) as! [Int]
                  personalFeedbacks.append(carinaID)
                  UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
                }
                sending = false
              }
            }, label: {
              HStack {
                Label("Carina.new.send", systemImage: "paperplane")
                Spacer()
                if sending {
                  ProgressView()
                    .frame(width: 25)
                }
              }
            })
            .disabled(sending || feedbackTitle.isEmpty)
          }
        }
      } else if carinaID == -1 {
        if #available(watchOS 10, *) {
          ContentUnavailableView(label: {
            Label("Carina.new.failure", systemImage: "exclamationmark.bubble")
          }, description: {
            Text("Carina.new.failure.description")
          }, actions: {
            Button(action: {
              Task {
                sending = true
                carinaID = await projectManager.newFeedback(replyData!) ?? -1
                if carinaID > 0 {
                  var personalFeedbacks = (UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []) as! [Int]
                  personalFeedbacks.append(carinaID)
                  UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
                }
                sending = false
              }
            }, label: {
              HStack {
                Spacer()
                if sending {
                  ProgressView()
                } else {
                  Label("Carina.new.re-send", systemImage: "paperplane")
                }
                Spacer()
              }
            })
            .disabled(sending)
          })
        } else {
          VStack {
            Image(systemName: "exclamationmark.bubble")
              .bold()
            Text("Carina.new.failure")
            Button(action: {
              Task {
                sending = true
                carinaID = await projectManager.newFeedback(replyData!) ?? -1
                if carinaID > 0 {
                  var personalFeedbacks = (UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []) as! [Int]
                  personalFeedbacks.append(carinaID)
                  UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
                }
                sending = false
              }
            }, label: {
              HStack {
                Spacer()
                if sending {
                  ProgressView()
                } else {
                  Label("Carina.new.re-send", systemImage: "paperplane")
                }
                Spacer()
              }
            })
          }
        }
      } else {
        Group {
          if #available(watchOS 10, *) {
            ContentUnavailableView(label: {
              Label("Carina.new.succeed", systemImage: "checkmark")
            }, description: {
              Text("Carina.new.succeed.description.\(String(carinaID))")
            }, actions: {
              NavigationLink(destination: {
                CarinaDetailView(id: String(carinaID))
              }, label: {
                HStack {
                  Spacer()
                  Label("Carina.new.navigate", systemImage: "richtext.page")
                  Spacer()
                }
              })
            })
          } else {
            VStack {
              Image(systemName: "checkmark")
                .bold()
              Text("Carina.new.succeed")
              NavigationLink(destination: {
                CarinaDetailView(id: String(carinaID))
              }, label: {
                HStack {
                  Spacer()
                  Label("Carina.new.navigate", systemImage: "richtext.page")
                  Spacer()
                }
              })
            }
            .onAppear {
              feedbackTitle = ""
              feedbackContent = ""
            }
          }
        }
        .onAppear {
          feedbackTitle = ""
          feedbackContent = ""
        }
      }
    }
    .navigationTitle("Carina.new")
    .onAppear {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isGrand, _ in
        DispatchQueue.main.async {
          if isGrand {
            WKExtension.shared().registerForRemoteNotifications()
          }
        }
      }
      if !recentThreeHistoryAttached {
        var history = getHistory()
        for repeatIndex in 0..<history.count {
          if history[repeatIndex].2 == lastHistoryID || history[repeatIndex].2 == lastHistoryID-1 || history[repeatIndex].2 == lastHistoryID-2 {
            attachedLinks.append(history[repeatIndex].0)
          }
        }
        recentThreeHistoryAttached = true
      }
    }
  }
}

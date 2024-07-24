//
//  CarinaNewView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/6.
//

import SwiftUI
import Cepheus

struct CarinaNewView: View {
  @State var personalFeedbacks: [Any] = []
  @State var type = 0
  @State var place = 7
  @State var title = ""
  @State var content = ""
  @State var sent = false
  @State var CarinaID = 0
  @State var is_watchOS10 = false
  @State var sending = false
  @State var package = """
"""
  @State var encodedPackage = ""
  @State var isAddedToList = false
  var body: some View {
    if sent {
      if CarinaID == -1 || CarinaID == -2 {
        VStack {
          Image(systemName: "circle.badge.exclamationmark")
            .font(.system(size: 50))
          Text("Carina.failed")
          Group {
            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) + Text(is_watchOS10 ? "" : "!") + Text(" · ") + Text(CarinaID == -1 ? "Carina.failed.fetching" : "Carina.failed.connecting")
          }
          .foregroundStyle(.secondary)
          Button(action: {
            sendCarina()
          }, label: {
            if !sending {
              Label("Carina.failed.resend", systemImage: "arrow.clockwise")
            } else {
                ProgressView()
            }
          })
          .disabled(sending)
          .foregroundStyle(title.isEmpty && !sending ? Color.secondary : Color.primary)
        }
        .multilineTextAlignment(.center)
      } else if CarinaID == 0 {
        VStack {
          Image(systemName: "hourglass")
            .font(.system(size: 50))
          Text("Carina.sending")
          Group {
            Text(carinaTypes[type]) + Text(" · ") + Text(carinaPlaces[place]) + Text(" · ") + Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) + Text(is_watchOS10 ? "" : "!")
          }
          .foregroundStyle(.secondary)
        }.multilineTextAlignment(.center)
      } else  {
        VStack {
          Image(systemName: "paperplane")
            .font(.system(size: 50))
          //.bold()
          Text("Carina.sent") + Text(" · ") + Text("#\(CarinaID)").monospaced()
          Group {
            Text(carinaTypes[type]) + Text(" · ") + Text(carinaPlaces[place]) + Text(" · ") + Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) + Text(is_watchOS10 ? "" : "!")
          }
          .foregroundStyle(.secondary)
          //.multilineTextAlignment(.center)
          NavigationLink(destination: {
            CarinaProgressView(carinaID: CarinaID)
          }, label: {
            Label("Carina.sent.view", systemImage: "doc.text.image")
          })
        }.multilineTextAlignment(.center)
          .onAppear {
            if !isAddedToList {
              personalFeedbacks.append(CarinaID)
              UserDefaults.standard.set(personalFeedbacks, forKey: "personalFeedbacks")
              isAddedToList = true
            }
          }
      }
    } else {
      List {
        Section("Carina.new.app") {
          Text("Project Iris \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)\(is_watchOS10 ? "" : "!")")
        }
        Section(content: {
          Picker("Carina.type", selection: $type) {
            ForEach(carinaTypes.indices) { typeIndex in
              Text(carinaTypes[typeIndex]).tag(typeIndex)
            }
          }
          Picker("Carina.place", selection: $place) {
            ForEach(carinaPlaces.indices) { placeIndex in
              Text(carinaPlaces[placeIndex]).tag(placeIndex)
            }
          }
        }, header: {
          Text("Carina.new.basic-information")
        }, footer: {
          if type == 0 {
            Text("Carina.type.function.description")
          } else if type == 1 {
            Text("Carina.type.interface.description")
          } else if type == 2 {
            Text("Carina.type.texts.description")
          } else if type == 3 {
            Text("Carina.type.suggestions.description")
          }
        })
        Section("Carina.new.details") {
          CepheusKeyboard(input: $title, prompt: "Carina.new.title")
          CepheusKeyboard(input: $content, prompt: "Carina.new.content")
        }
        Button(action: {
          sendCarina()
        }, label: {
          if sending {
            HStack {
              ProgressView()
              Text("Carina.new.sending")
              Spacer()
            }
          } else {
            Label("Carina.new.send", systemImage: "paperplane")
          }
        })
        .disabled(title.isEmpty && !sending)
        .foregroundStyle(title.isEmpty && !sending ? Color.secondary : Color.primary)
      }
      .navigationTitle("Carina.new")
      .onAppear {
        if #available(watchOS 10.0, *) {
          is_watchOS10 = true
        }
        personalFeedbacks = UserDefaults.standard.array(forKey: "personalFeedbacks") ?? []
        isAddedToList = false
      }
    }
    
  }
  func sendCarina() {
    sending = true
    CarinaID = 0
    package = """
\(title)
Type：\(type)
Place：\(place)
/Users/tom/Xcode/Project Iris/Project Iris Watch App/CarinaNewView.swiftState：0
Content：\(content.isEmpty ? "none" : content)
Version：\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)\(is_watchOS10 ? "" : "!")
"""
    encodedPackage = package.data(using: .utf8)?.base64EncodedString() ?? ""
    fetchWebPageContent(urlString: "\(carinaPushFeedbackAPI)\(encodedPackage)") { result in
        switch result {
        case .success(let content):
          CarinaID = Int(content) ?? -1
        case .failure(let error):
          CarinaID = -2
        }
        sending = false
      }
    sent = true
  }
}

#Preview {
  CarinaNewView()
}

//
//  CreditView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/7/6.
//

import SwiftUI

struct CreditView: View {
  @AppStorage("poemIsDiscovered") var poemIsDiscovered = false
  @AppStorage("debug") var debug = false
  @State var showContacts = false
  var body: some View {
    NavigationStack {
      List {
        Section(content: {
          VStack(alignment: .leading) {
            Text(verbatim: "ThreeManager785")
            HStack {
              Image(systemName: "hammer")
              Image(systemName: "paintbrush.pointed")
              Image(systemName: "globe")
              Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
          }
          VStack(alignment: .leading) {
            Text(verbatim: "WindowsMEMZ")
            HStack {
              Image(systemName: "hammer")
              Image(systemName: "lightbulb.max")
              Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
          }
          VStack(alignment: .leading) {
            Text(verbatim: "Linecom")
            HStack {
              Image(systemName: "building.columns.fill")
              Image(systemName: "lightbulb.max")
              Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
          }
          VStack(alignment: .leading) {
            Text(verbatim: "qwasd")
            HStack {
              Image(systemName: "lightbulb.max")
              Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
          }
          VStack(alignment: .leading) {
            Text(verbatim: "2073")
            HStack {
              Image(systemName: "globe")
              Text("Credit.lang.ru")
              Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
          }
          //          VStack(alignment: .leading) {
          //            Text(verbatim: "神之子.環環")
          //            HStack {
          //              Image(systemName: "globe")
          //              Text("Credit.lang.zh_Hant")
          //              Spacer()
          //            }
          //            .font(.caption)
          //            .foregroundStyle(.secondary)
          //          }
          VStack(alignment: .leading) {
            Text(verbatim: "樱井白风")
            HStack {
              Image(systemName: "globe")
              Text("Credit.lang.de")
              Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
          }
          Button(action: {
            showContacts = true
          }, label: {
            Text("Credit.contacts")
          })
        }, footer: {
          VStack(alignment: .leading) {
            Label("Credit.footer.development", systemImage: "hammer")
            Label("Credit.footer.design", systemImage: "paintbrush.pointed")
            Label("Credit.footer.global", systemImage: "globe")
            Label("Credit.footer.inspiration", systemImage: "lightbulb.max")
            Label("Credit.footer.legality", systemImage: "building.columns.fill")
          }
        })
        Section {
          NavigationLink(destination: {
            List {
              Section(content: {
                Text(verbatim: "百合花")
                  .bold()
                  .onTapGesture(count: 3, perform: {
                    debug = true
                    showTip("Debug.toggled", symbol: "hammer")
                  })
                Text(theLily)
              }, footer: {
                Text("About.785.easteregg.language")
              })
            }
            .onAppear {
              Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
              }
              poemIsDiscovered = true
            }
            .navigationTitle("About.785.easteregg")
          }, label: {
            Text("About.785.easteregg")
          })
          .listRowBackground(Color(red: 31 / 255, green: 31 / 255, blue: 32 / 255).cornerRadius(10).opacity(poemIsDiscovered ? 1 : 0.02))
          .opacity(poemIsDiscovered ? 1 : 0.02)
//                .animation(.easeInOut(duration: 2), value: poemIsDiscovered)
          .contentShape(Rectangle())
          .navigationTitle("Settings.credits")
          .onChange(of: poemIsDiscovered, perform: { value in
            fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/add/garden_iris_poem_1/\(Date.now.timeIntervalSince1970)") { result in
            }
          })
        }
      }
    }
    .sheet(isPresented: $showContacts, content: {
      List {
        Group {
          VStack(alignment: .leading) {
            Text(verbatim: "ThreeManager785")
            HStack {
//              Image(systemName: "envelope")
              Text(verbatim: "mallets02.plums@icloud.com")
              Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
          }
        }
        Group {
          VStack(alignment: .leading) {
            Text(verbatim: "WindowsMEMZ")
            HStack {
//              Image(systemName: "envelope")
              Text(verbatim: "0.wits.tempo@icloud.com")
              Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
          }
        }
        Group {
          VStack(alignment: .leading) {
            Text(verbatim: "Linecom")
            HStack {
//              Image(systemName: "envelope")
              Text(verbatim: "linecom@linecom.net.cn")
              Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
          }
        }
        Group {
          VStack(alignment: .leading) {
            Text(verbatim: "qwasd")
            HStack {
//              Image(systemName: "envelope")
              Text(verbatim: "sjbstudio233@gmail.com")
              Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
          }
        }
      }
      .navigationTitle("Credit.contacts")
    })
  }
}

public let theLily = """
我漫步于森林间，
繁茂的植物生长着；
在那温暖的春季，
花朵竞相绽放。

百合花在土壤上开出，
默默地望着蓝天；
不同于其他花，
她洁白而宁静。

不同于妖艳的红花，
她从不张扬自己的鲜艳；
人们总是走过她，
但她却有最完美的正六边形。

我望着她，
她望着天；
我多么希望能留在她身旁，
与她共度余生。

但我清楚的明白，
我无法比肩她的高雅；
时间总会逝去，
我没有能力栽培或照顾她。

于是，我便静静地望着她；
享受着与她的时光，欣赏她的优雅与温柔……
"""

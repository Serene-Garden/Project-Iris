//
//  Untitled.swift
//  Project Iris
//
//  Created by ThreeManager785 on 9/20/24.
//

import SwiftUI

struct TroubleshooterView: View {
  @State var progressTimer: Timer?
  @State var networkState = 0
  @State var darockAPIState = 0
  @State var isTroubleshooting = false
  @State var isNewVerAvailable = false
  var lightColors: [Color] = [.secondary, .orange, .red, .green, .red]
  var body: some View {
    List {
      Section {
        if !isTroubleshooting {
          if networkState == 3 && darockAPIState == 3 {
            HStack {
              Image(systemName: "checkmark")
                .foregroundColor(.green)
              Text("Troubleshooter.okay")
                .bold()
            }
          } else {
            Text("Troubleshooter.issues")
              .bold()
            if networkState == 2 {
              NavigationLink(destination: { /*NetworkProblemDetailsView()*/ }, label: {
                Text("Troubleshooter.issues.internet")
              })
            }
            if darockAPIState == 2 || darockAPIState == 4 {
              NavigationLink(destination: { /*DarockAPIProblemDetailsView()*/ }, label: {
                Text(darockAPIState == 2 ? "Troubleshooter.issues.darock.unconnectable" : "Troubleshooter.issues.darock.unparsable")
              })
            }
          }
        } else {
          Text("Troubleshooter.checking")
            .bold()
        }
      } footer: {
        if !(networkState == 3 && darockAPIState == 3) {
          Text("Troubleshooter.footer")
        }
      }
      Section("Troubleshooter.status") {
        HStack {
          Circle()
            .frame(width: 10)
            .foregroundStyle(lightColors[networkState])
            .padding(.trailing, 7)
          if networkState == 0 {
            Text("Troubleshooter.internet")
          } else if networkState == 1 {
            Text("Troubleshooter.internet.checking")
          } else if networkState == 2 {
            Text("Troubleshooter.internet.offline")
          } else if networkState == 3 {
            Text("Troubleshooter.internet.online")
          }
          Spacer()
        }
        .padding()
        HStack {
          Circle()
            .frame(width: 10)
            .foregroundStyle(lightColors[darockAPIState])
            .padding(.trailing, 7)
          if darockAPIState == 0 {
            Text("Troubleshooter.darock")
              .foregroundStyle(networkState != 3 ? Color.secondary : .primary)
          } else if darockAPIState == 1 {
            Text("Troubleshooter.darock.checking")
          } else if darockAPIState == 2 {
            Text("Troubleshooter.darock.unavailable")
          } else if darockAPIState == 3 {
            Text("Troubleshooter.darock.available")
          } else if darockAPIState == 4 {
            Text("Troubleshooter.darock.unparsable")
          }
          Spacer()
        }
        .disabled(networkState != 3)
        .padding()
        Button(action: {
          isTroubleshooting = true
          networkState = 0
          darockAPIState = 0
          checkInternet()
        }, label: {
          Text(isTroubleshooting ? "Troubleshooter.checking" : "Troubleshooter.checking.re-check")
        })
        .disabled(isTroubleshooting)
      }
    }
    .navigationTitle("Troubleshooter")
    .onAppear {
      isTroubleshooting = true
      networkState = 0
      darockAPIState = 0
      checkInternet()
    }
    .onDisappear {
      progressTimer?.invalidate()
    }
  }
  
  func checkInternet() {
    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
      timer.invalidate()
      networkState = 177
      fetchWebPageContent(urlString: "https://api.darock.top") { result in
        switch result {
          case .success(let content):
            checkDarock()
            networkState = 3
          case .failure(let error):
            networkState = 2
            isTroubleshooting = false
        }
      }
    }
  }

  func checkDarock() {
    darockAPIState = 1
    fetchWebPageContent(urlString: "https://api.darock.top") { result in
      switch result {
        case .success(let content):
          if content == "\"OK\"" {
            darockAPIState = 3
          } else {
            darockAPIState = 4
          }
        case .failure(let error):
          darockAPIState = 1
      }
      isTroubleshooting = false
    }
  }
}
  
  
  
//struct NetworkProblemDetailsView: View {
//  var body: some View {
//    List {
//      Section {
//        Text("网络问题")
//          .bold()
//      }
//      Section("这代表什么？") {
//        Text("Apple Watch 目前无法连接到互联网")
//      }
//      Section("我应当怎么做？") {
//        Text("确认 Apple Watch 已连接到互联网")
//        Text("断开 Apple Watch 与 iPhone 的连接")
//      }
//      Section("还是不行？") {
//        Text("尝试在 iPhone 设置中关闭无线局域网与蓝牙")
//      }
//    }
//  }
//}
//struct DarockAPIProblemDetailsView: View {
//  var body: some View {
//    NavigationStack {
//      List {
//        Section {
//          Text("Darock API 问题")
//            .bold()
//        }
//        Section("这代表什么？") {
//          Text("Darock API 服务器目前出现了问题，这不是你的错")
//        }
//        Section("我应当怎么做？") {
//          Text("等待 Darock 修复")
//        }
//      }
//    }
//  }
//}
//

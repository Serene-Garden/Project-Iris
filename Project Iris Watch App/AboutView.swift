//
//  AboutView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/2.
//
import SwiftUI

struct AboutView: View {
  var body: some View {
    NavigationStack {
      if #available(watchOS 10, *) {
        TabView {
          AboutViewOne()
          SettingsAdvancedView()
        }
        .tabViewStyle(.verticalPage)
      } else {
        ScrollView {
          AboutViewOne()
          SettingsAdvancedView()
        }
      }
    }
  }
}

struct AboutViewOne: View {
  @State var isEasterEggDisplayed = false
  @State var isICPSheetDisplaying = false
  let AppIconLength: CGFloat = 70
  let ICPFillingNumber = "浙ICP备2024071295号-4A"
  var body: some View {
    VStack(alignment: .center) {
      Image("AppIconImage")
        .resizable()
        .frame(width: AppIconLength, height: AppIconLength)
        .mask(Circle())
      Text("Project Iris")
        .bold()
        .font(.title3)
      Group {
        Text("ThreeManager785")
        Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)").monospaced() + Text(" · ") + Text("GPL-3.0").monospaced()
        if countryCode == "CN" {
          Text(ICPFillingNumber).font(.system(size: 10))
            .onTapGesture {
              isICPSheetDisplaying = true
            }
            .sheet(isPresented: $isICPSheetDisplaying, content: {
              List {
                Text(ICPFillingNumber).bold()
                Button(action: {
                  searchButtonAction(isPrivateModeOn: true, searchField: "https://beian.miit.gov.cn", isCookiesAllowed: true, searchEngine: "")
                }, label: {
                  HStack {
                    Text(String("https://beian.miit.gov.cn")).monospaced()
                    Spacer()
                    Image(systemName: "arrow.up.right.circle")
                  }
                })
              }
            })
        }
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
    .onTapGesture(count: 3) {
      isEasterEggDisplayed = true
    }
    .sheet(isPresented: $isEasterEggDisplayed, content: {
      VStack {
        Image("DarockBrowserImage")
          .resizable()
          .frame(width: AppIconLength, height: AppIconLength)
          .mask(Circle())
        Text("About.easter-egg")
          .multilineTextAlignment(.center)
        Text("About.easter-egg.image-footer")
          .font(.caption2)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
    })
    .navigationTitle("About")
  }
}


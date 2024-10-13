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
          AboutViewMain()
          AboutMoreView()
        }
        .tabViewStyle(.verticalPage)
      } else {
        ScrollView {
          AboutViewMain()
          AboutMoreView()
        }
      }
    }
  }
}

struct AboutMoreView: View {
  var body: some View {
    List {
      NavigationLink(destination: {
        List {
          Text(verbatim: "https://discord.gg/Qx5PXXEeW9")
        }
      }, label: {
        Label("About.chat", systemImage: "bubble.left.and.bubble.right")
      })
      NavigationLink(destination: {
        NewFeaturesListView().navigationTitle("About.whats-new")
      }, label: {
        Label("About.whats-new", systemImage: "sparkles")
      })
      NavigationLink(destination: CreditView(), label: {
//        HStack {
          Label("Settings.credits", systemImage: "fleuron")
//          Spacer()
//          Image(systemName: "chevron.forward")
//            .foregroundStyle(.secondary)
//        }
      })
      NavigationLink(destination: {
        AboutPackagesView()
      }, label: {
        Label("About.acknowledgements", systemImage: "shippingbox")
      })
    }
  }
}

struct AboutViewMain: View {
  @State var isEasterEggDisplayed = false
  @State var isICPSheetDisplaying = false
  let AppIconLength: CGFloat = 70
  let ICPFillingNumber = "津ICP备2024024051号-1A"
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
        Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)").monospaced() + Text(" · ") + Text(verbatim: "GPL-3.0").monospaced()
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


struct AboutPackagesView: View {
  var body: some View {
    List {
      AboutPackagesUnit(title: "Cepheus", footnote: "Apache-2.0")
      AboutPackagesUnit(title: "Dynamic", footnote: "Apache-2.0")
      AboutPackagesUnit(title: "Pictor", footnote: "Apache-2.0")
      AboutPackagesUnit(title: "RadarKitCore", footnote: "Copyright 2024 Darock Studio. All rights reserved.", type: 1)
      AboutPackagesUnit(title: "SaltUICore", footnote: "by WindowsMEMZ", type: 1)
      AboutPackagesUnit(title: "SolarTime", footnote: "MIT")
      AboutPackagesUnit(title: "SwiftSoup", footnote: "MIT")
      AboutPackagesUnit(title: "Vela", footnote: "Apache-2.0")
    }
    .navigationTitle("About.acknowledgements")
  }
}

struct AboutPackagesUnit: View {
  var title: String
  var footnote: String
  var type: Int = 0
  @State var isExpanded: Bool = false
  let quotingImages = ["shippingbox.fill", "building.columns.fill"]
  let quotingColors = [Color(red: 194/255, green: 152/255, blue: 98/255), Color(red: 167/255, green: 188/255, blue: 202/255)]
  var body: some View {
    HStack {
      Image(systemName: quotingImages[type])
        .foregroundStyle(quotingColors[type])
      VStack(alignment: .leading) {
        Text(title)
        Text(footnote)
          .foregroundStyle(.secondary)
          .font(.footnote)
          .lineLimit(isExpanded ? nil : 1)
      }
      Spacer()
    }
    .onTapGesture {
      isExpanded.toggle()
    }
  }
}

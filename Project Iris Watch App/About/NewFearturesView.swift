//
//  NewFearturesView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/7/7.
//

import SwiftUI

let alwaysShowDetailsVersion = "0.0.0"
let showDetails = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).hasSuffix(".0") || (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) == alwaysShowDetailsVersion

struct NewFearturesView: View {
  var body: some View {
    if #available(watchOS 10, *) {
      TabView {
        NewFeaturesTitleView()
//        if showDetails {
          NewFeaturesListView()
//        }
      }
      .tabViewStyle(.verticalPage)
    } else {
      ScrollView {
        NewFeaturesTitleView()
//        if showDetails {
          NewFeaturesListView()
//        }
      }
    }
  }
}

struct NewFeaturesTitleView: View {
//  let showDetails = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).hasSuffix(".0")
  var body: some View {
    ScrollView {
      HStack {
        VStack(alignment: .leading) {
          Text("New.title.\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
            .bold()
            .font(.largeTitle)
          Group {
            if showDetails {
              if #available(watchOS 10, *) {
                Label("New.title.scroll", systemImage: "chevron.down")
              }
            } else {
              Label("New.title.minor", systemImage: "ellipsis.circle")
            }
          }
        }
        Spacer()
      }
      .padding()
    }
    /*.toolbar {
      if votesAvailable {
        if #available(watchOS 10, *) {
          ToolbarItemGroup(placement: .bottomBar, content: {
            HStack {
              Spacer()
              NavigationLink(destination: {
                VoteView()
              }, label: {
                Image(systemName: "arrow.right")
              })
            }
          })
        }
      }
     }*/
  }
}

struct NewFeaturesListView: View {
    //    let showDetails = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).hasSuffix(".0")
  var body: some View {
    List {
      Section(content: {
        SingleNewFeature(symbol: "photo.on.rectangle.angled", title: "New.images-updated", description: "New.images-updated.description")
        SingleNewFeature(symbol: "magnifyingglass", title: "New.search", description: "New.search.description")
        SingleNewFeature(symbol: "hammer", title: "New.bug-fixes", description: "New.bug-fixes.description")
      }, header: {
        if !showDetails {
          Text("New.last-major-update")
        }
      })
    }
  }
}

struct SingleNewFeature: View {
  @State var tintColorValues: [Any] = defaultColor
  @State var tintColor = Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100)
  var symbol: String
  var title: LocalizedStringKey
  var description: LocalizedStringKey
  var body: some View {
    HStack {
      Image(systemName: symbol)
        .foregroundStyle(tintColor)
      VStack(alignment: .leading) {
        Text(title)
          .bold()
        Text(description)
          .font(.footnote)
      }
    }
    .multilineTextAlignment(.leading)
    .onAppear {
      if (UserDefaults.standard.array(forKey: "tintColor") ?? []).isEmpty {
        UserDefaults.standard.set(defaultColor, forKey: "tintColor")
      }
      tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? (defaultColor as [Any])
      tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
    }
  }
}

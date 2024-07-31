//
//  NewFearturesView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/7/7.
//

import SwiftUI

struct NewFearturesView: View {
  var body: some View {
    if #available(watchOS 10, *) {
      TabView {
        NewFeaturesTitleView()
        NewFeaturesListView()
      }
      .tabViewStyle(.verticalPage)
    } else {
      ScrollView {
        NewFeaturesTitleView()
        NewFeaturesListView()
      }
    }
  }
}

struct NewFeaturesTitleView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text("New.title.\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
          .bold()
          .font(.largeTitle)
        Label("New.title.scroll", systemImage: "chevron.down")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}

struct NewFeaturesListView: View {
  var body: some View {
    List {
      SingleNewFeature(symbol: "bookmark", title: "New.2.1.0.bookmarks.title", description: "New.2.1.0.bookmarks.description")
      SingleNewFeature(symbol: "clock", title: "New.2.1.0.history.title", description: "New.2.1.0.history.description")
      SingleNewFeature(symbol: "exclamationmark.bubble", title: "New.2.1.0.carina.title", description: "New.2.1.0.carina.description")
      SingleNewFeature(symbol: "hand.raised", title: "New.2.1.0.privacy.title", description: "New.2.1.0.privacy.description")
      SingleNewFeature(symbol: "externaldrive.connected.to.line.below", title: "New.2.1.0.data.title", description: "New.2.1.0.data.description")
    }
  }
}

struct SingleNewFeature: View {
  @State var tintColorValues: [Any] = [275, 40, 100]
  @State var tintColor = Color(hue: 275/359, saturation: 40/100, brightness: 100/100)
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
        UserDefaults.standard.set([275, 40, 100], forKey: "tintColor")
      }
      tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? [275, 40, 100]
      tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
    }
  }
}

#Preview {
  NewFearturesView()
}

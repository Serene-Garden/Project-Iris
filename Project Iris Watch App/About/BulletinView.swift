//
//  BulletinView.swift
//  Project Iris
//
//  Created by ThreeManager785 on 10/3/24.
//

import SwiftUI

struct BulletinView: View {
  var bulletinContent: String
  @AppStorage("lastBulletin") var lastBulletin: String = ""
  @AppStorage("bulletinIsNew") var bulletinIsNew = false
  var body: some View {
    Group {
      if !bulletinContent.isEmpty {
        List {
          Text(bulletinContent)
        }
      } else if bulletinContent == "Error" {
        if #available(watchOS 10, *) {
          ContentUnavailableView {
            Label("Bulletin.error", systemImage: "megaphone")
          } description: {
            Text("Bulletin.error.details")
          }
        } else {
          List {
            Text("Bulletin.error")
              .bold()
              .foregroundStyle(.secondary)
          }
        }
      } else {
        if #available(watchOS 10, *) {
          ContentUnavailableView {
            Label("Bulletin.empty", systemImage: "megaphone")
          }
        } else {
          List {
            Text("Bulletin.empty")
              .bold()
              .foregroundStyle(.secondary)
          }
        }
      }
    }
    .navigationTitle("Bulletin")
    .onAppear {
      lastBulletin = bulletinContent
      bulletinIsNew = false
    }
  }
}

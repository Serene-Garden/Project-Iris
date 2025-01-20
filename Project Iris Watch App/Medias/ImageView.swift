  //
  //  ImageView.swift
  //  Project Iris
  //
  //  Created by ThreeManager785 on 11/1/24.
  //

import SwiftUI
import UIKit

let controllerDisplayTime: Double = 3
let longPressWaitingTime: Double = 0.5
let longPressFlippingInterval = 0.1

public struct ImageView: View {
  var caption: Text?
  var aspectRatic: Binding<CGFloat>?
//  var url: URL
  var urlSet: [URL]
  @State var urlIndex: Int = 0
  @State var image: Image?
  
  
  @State var dragOffset: CGSize = CGSize.zero
  @State var digitalCrownRotation: CGFloat = 0.7
  
  @State var controllerTimer: Timer?
  @State var showController = false
  @State var longPressTimer: Timer?
  @State var flipperTimer: Timer?
  @State var isQuickFlipping = false
  
  public var body: some View {
    VStack {
      AsyncImage(url: urlSet[urlIndex], content: { image in
        image
          .resizable()
          .scaledToFit()
          .scaleEffect(digitalCrownRotation)
          .offset(x: self.dragOffset.width, y: self.dragOffset.height)
          .gesture(DragGesture()
            .onChanged { value in
              dragOffset.width = dragOffset.width + value.location.x - value.startLocation.x
              dragOffset.height = dragOffset.height + value.location.y - value.startLocation.y
              dragOffset = value.translation
            }
          )
          .ignoresSafeArea()
      }, placeholder: {
        ProgressView()
      })
    }
    .focusable()
    .digitalCrownRotation($digitalCrownRotation, from: 0.5, through: 5.0, by: 0.1, sensitivity: .medium, isContinuous: false)
    .gesture(TapGesture().onEnded { _ in
      showController = true
    })
    ._statusBar(hidden: !showController)
    .onAppear {
      showController = true
      controllerTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
        showController = false
      }
    }
    .toolbar {
      if #available(watchOS 10.0, *) {
        if urlSet.count > 1 {
          ToolbarItemGroup(placement: .bottomBar) {
            HStack {
              Button(action: {
                showController = true
                if urlIndex > 0 {
                  urlIndex -= 1
                }
              }, label: {
                Image(systemName: "arrow.backward")
              })
              .disabled(urlIndex == 0)
              ._onButtonGesture(pressing: { value in
                if value {
                  longPressTimer = Timer.scheduledTimer(withTimeInterval: longPressWaitingTime, repeats: false) { _ in
                    isQuickFlipping = true
                    flipperTimer = Timer.scheduledTimer(withTimeInterval: longPressFlippingInterval, repeats: true) { _ in
                      if urlIndex > 0 {
                        urlIndex -= 1
                      }
                    }
                  }
                } else {
                  isQuickFlipping = false
                  longPressTimer?.invalidate()
                  flipperTimer?.invalidate()
                }
              }, perform: {
                //I am an easter egg.
              })
              Spacer()
              
              VStack {
                Label(String("\(urlIndex+1)/\(urlSet.count)"), systemImage: "photo.on.rectangle.angled")
                  .font(.caption)
                if isQuickFlipping {
                  Text("Image.is-quick-flipping")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
              }
              .animation(.easeInOut(duration: 0.2), value: isQuickFlipping)
              
              Spacer()
              Button(action: {
                showController = true
                if urlIndex < urlSet.count-1 {
                  urlIndex += 1
                }
              }, label: {
                Image(systemName: "arrow.forward")
              })
              .disabled(urlIndex == urlSet.count-1)
              ._onButtonGesture(pressing: { value in
                if value {
                  longPressTimer = Timer.scheduledTimer(withTimeInterval: longPressWaitingTime, repeats: false) { _ in
                    isQuickFlipping = true
                    flipperTimer = Timer.scheduledTimer(withTimeInterval: longPressFlippingInterval, repeats: true) { _ in
                      if urlIndex < urlSet.count-1 {
                        urlIndex += 1
                      }
                    }
                  }
                } else {
                  isQuickFlipping = false
                  longPressTimer?.invalidate()
                  flipperTimer?.invalidate()
                }
              }, perform: {
                //I guess @WindowsMEMZ would find this.
              })
            }
            .opacity(showController ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: showController)
            .onChange(of: showController, perform: { value in
              if showController {
                controllerTimer?.invalidate()
                controllerTimer = Timer.scheduledTimer(withTimeInterval: controllerDisplayTime, repeats: false) { _ in
                  showController = false
                }
              }
            })
            .onChange(of: isQuickFlipping, perform: { value in
              if isQuickFlipping {
                controllerTimer?.invalidate()
              } else {
                controllerTimer = Timer.scheduledTimer(withTimeInterval: controllerDisplayTime, repeats: false) { _ in
                  showController = false
                }
              }
            })
            .shadow(radius: 20)
          }
        }
      }
    }
  }
}

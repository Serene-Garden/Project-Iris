//
//  Dimming.swift
//  Project Iris
//
//  Created by ThreeManager785 on 9/15/24.
//

import SwiftUI

struct DimmingView: View {
  var isGlobal: Bool = false
  @AppStorage("dimmingCoefficientIndex") var dimmingCoefficientIndex = 100
  @AppStorage("globalDimming") var globalDimming = false
  @AppStorage("dimmingAtSpecificPeriod") var dimmingAtSpecificPeriod = false
  @AppStorage("AppearanceSchedule") var appearanceSchedule = 0
  @State var isScreenDimming = true
  var body: some View {
    Group {
      if isScreenDimming {
        Rectangle()
          .fill(Color.black)
          .opacity(1.0-(Double(dimmingCoefficientIndex)/100))
          .animation(.easeInOut(duration: 2))
          .ignoresSafeArea()
          .allowsHitTesting(false)
      }
    }
    .onAppear {
      isScreenDimming = shouldDimScreen(globalDimming: globalDimming, isGlobalCaller: isGlobal, dimmingAtSpecificPeriod: dimmingAtSpecificPeriod, lightMode: appearanceSchedule == 0)
      Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
        isScreenDimming = shouldDimScreen(globalDimming: globalDimming, isGlobalCaller: isGlobal, dimmingAtSpecificPeriod: dimmingAtSpecificPeriod, lightMode: appearanceSchedule == 0)
      }
    }
  }
}

@MainActor func shouldDimScreen(globalDimming: Bool = false, isGlobalCaller: Bool = false, dimmingAtSpecificPeriod: Bool = false, lightMode: Bool = false) -> Bool {
  if lightMode {
    return false
  } else if isGlobalCaller && !globalDimming {
    return false
  } else if dimmingAtSpecificPeriod {
    let fDimTime = readDimTime().0
    let fComponents = Calendar.current.dateComponents([.hour, .minute], from: fDimTime)
    let fHour = fComponents.hour ?? 0
    let fMinute = fComponents.minute ?? 0
    
    let tDimTime = readDimTime().1
    let tComponents = Calendar.current.dateComponents([.hour, .minute], from: tDimTime)
    let tHour = tComponents.hour ?? 0
    let tMinute = tComponents.minute ?? 0
    
    let currentTime = Date.now
    let cComponents = Calendar.current.dateComponents([.hour, .minute], from: currentTime)
    let cHour = cComponents.hour ?? 0
    let cMinute = cComponents.minute ?? 0
    
    if cHour > fHour && cHour > tHour { //Midnight, Dimming Not Terminated Yet
      return true
    } else if cHour < tHour && cHour < fHour { //Night, Dimming Started
      return true
    } else if (cHour == fHour) && (cMinute > fMinute) {
      return true
    } else if (cHour == tHour) && (cMinute < tMinute) {
      return true
    } else {
      return false
    }
    //    return (cHour < fHour || cHour > tHour || (cHour == fHour && cMinute < fMinute) || (cHour == tHour && cMinute > tMinute))
  } else {
    return true
  }
}

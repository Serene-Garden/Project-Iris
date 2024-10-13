//
//  SettingsAppearanceView.swift
//  Project Iris
//
//  Created by ThreeManager785 on 10/5/24.
//

import CoreLocation
import SolarTime
import SwiftUI

struct SettingsAppearanceView: View {
  @AppStorage("AppearanceSchedule") var appearanceSchedule = 0
  @AppStorage("dimmingCoefficientIndex") var dimmingCoefficientIndex = 100
  @AppStorage("globalDimming") var globalDimming = false
  @AppStorage("dimmingAtSpecificPeriod") var dimmingAtSpecificPeriod = false
  @AppStorage("forceDarkMode") var forceDarkMode = false
  
  @StateObject var locationManager = LocationManager()
  @State var locationPrivacySheetIsDisplaying = false
  @State var locationAccessStatus: CLAuthorizationStatus = .authorizedWhenInUse
  @State var dimmingCoefficient = 1.0
  @State var isToolbarOnSelect = false
  @State var currentTextDirection = 0
  @State var selectedTextDirection = 0
  @State var scheduleStartingTime: Date = readDimTime().0
  @State var scheduleEndingTime: Date = readDimTime().1
  @State var is_watchOS10 = true
  
  var dateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    return dateFormatter
  }()
  var body: some View {
    List {
      Section("Settings.appearance.schedule") {
        NavigationLink(destination: {
          List {
            Section {
              ForEach(0..<scheduleNames.count, id: \.self) { scheduleIndex in
                if is_watchOS10 && scheduleIndex == 2 || scheduleIndex != 2 {
                  Button(action: {
                    appearanceSchedule = scheduleIndex
                    dimmingAtSpecificPeriod = (scheduleIndex >= 2)
                    //                  locationManager.requestWhenInUseAuthorization()
                  }, label: {
                    HStack {
                      Text(scheduleNames[scheduleIndex])
                      Spacer()
                      if scheduleIndex == appearanceSchedule {
                        Image(systemName: "checkmark")
                      }
                    }
                  })
                }
              }
            }
            Section(content: {
              if appearanceSchedule == 2 {
                if #available(watchOS 10, *) {
                  Section {
                    NavigationLink(destination: {
                      DatePicker(selection: $scheduleStartingTime, displayedComponents: .hourAndMinute, label: {
                        Text("Settings.appearance.schedule.period.from")
                      })
                      .navigationTitle("Settings.appearance.schedule.period.from")
                    }, label: {
                      HStack {
                        Text("Settings.appearance.schedule.period.from")
                        Spacer()
                        Text(dateFormatter.string(from: scheduleStartingTime))
                          .foregroundStyle(.secondary)
                      }
                    })
                    NavigationLink(destination: {
                      DatePicker(selection: $scheduleEndingTime, displayedComponents: .hourAndMinute, label: {
                        Text("Settings.appearance.schedule.period.to")
                      })
                      .navigationTitle("Settings.appearance.schedule.period.to")
                    }, label: {
                      HStack {
                        Text("Settings.appearance.schedule.period.to")
                        Spacer()
                        Text(dateFormatter.string(from: scheduleEndingTime))
                          .foregroundStyle(.secondary)
                      }
                    })
                  }
                  .onChange(of: scheduleStartingTime, {
                    writeDimTime(from: scheduleStartingTime, to: scheduleEndingTime)
                  })
                  .onChange(of: scheduleEndingTime, {
                    writeDimTime(from: scheduleStartingTime, to: scheduleEndingTime)
                  })
                }
              } else if appearanceSchedule == 3 {
                switch locationAccessStatus {
                  case .notDetermined:
                    Label("Settings.appearance.schedule.solar.location.state.not-determined", systemImage: "questionmark.circle")
                      .foregroundStyle(.yellow)
                      .onAppear {
                        locationPrivacySheetIsDisplaying = true
                      }
                    Button(action: {
                      locationManager.requestAccess()
                    }, label: {
                      Label("Settings.appearance.schedule.solar.location.request.button", systemImage: "location")
                    })
                    .foregroundStyle(.blue)
                  case .restricted:
                    Label("Settings.appearance.schedule.solar.location.state.restricted", systemImage: "xmark.circle")
                      .foregroundStyle(.red)
                  case .denied:
                    Label("Settings.appearance.schedule.solar.location.state.denied", systemImage: "exclamationmark.circle")
                      .foregroundStyle(.red)
                  case .authorizedAlways, .authorizedWhenInUse:
                    Label("Settings.appearance.schedule.solar.location.state.authorized", systemImage: "checkmark.circle")
                      .foregroundStyle(.green)
                      .onAppear {
                        updateDimTimeWithSolarTimes()
                      }
                }
                Text("Settings.appearance.schedule.solar.location.deviation")
              }
            }, footer: {
              if appearanceSchedule == 3 {
                Button(action: {
                  locationPrivacySheetIsDisplaying = true
                }, label: {
                  Text("Settings.appearance.schedule.solar.learn-about-privacy")
                    .foregroundStyle(.blue)
                })
                .buttonStyle(.plain)
              }
            })
          }
          .navigationTitle("Settings.appearance.schedule.title")
        }, label: {
          VStack(alignment: .leading) {
            Text("Settings.appearance.schedule.title")
            Text(scheduleNames[appearanceSchedule])
              .foregroundStyle(.secondary)
              .font(.caption)
          }
        })
      }
      
      Section(content: {
        Slider(value: $dimmingCoefficient, in: 0.2...1.0, label: {
          Text("Settings.interface.dimming")
        }, minimumValueLabel: {
          Image(systemName: "moon")
        }, maximumValueLabel: {
          Image(systemName: "sun.max")
        })
        .onChange(of: dimmingCoefficient, perform: { value in
          dimmingCoefficientIndex = Int(dimmingCoefficient * 100)
        })
        .listRowBackground(Color.clear)
        .padding(-10)
      }, header: {
        Text("Settings.appearance.dimming")
      }, footer: {
        if dimmingCoefficient == 1 {
          Text("Settings.appearance.dimming.description.same")
        } else {
          if globalDimming {
            Text("Settings.appearance.dimming.description.\("\(Int(dimmingCoefficient*100))%").globally")
          } else {
            Text("Settings.appearance.dimming.description.\("\(Int(dimmingCoefficient*100))%").portion")
          }
        }
      })
    }
    .navigationTitle("Settings.appearance")
    .sheet(isPresented: $locationPrivacySheetIsDisplaying, content: {
      ScrollView {
        VStack {
          Image(systemName: "location.fill")
            .foregroundStyle(.blue)
            .font(.largeTitle)
          Text("Settings.appearance.schedule.solar.location.request.title")
            .bold()
            .font(.title3)
          Text("Settings.appearance.schedule.solar.location.request.content")
            .multilineTextAlignment(.center)
            .font(.caption)
          Button(action: {
            CLLocationManager().requestWhenInUseAuthorization()
          }, label: {
            Label((locationAccessStatus == .authorizedAlways || locationAccessStatus == .authorizedWhenInUse) ? "Settings.appearance.schedule.solar.location.request.authorized" : "Settings.appearance.schedule.solar.location.request.button", systemImage: "location")
              .multilineTextAlignment(.center)
          })
          .foregroundStyle(.blue)
          .disabled(locationAccessStatus == .authorizedAlways || locationAccessStatus == .authorizedWhenInUse)
        }
      }
    })
    .onAppear {
      dimmingCoefficient = Double(dimmingCoefficientIndex)/100
      dimmingCoefficientIndex = Int(dimmingCoefficient * 100)
      scheduleStartingTime = readDimTime().0
      scheduleEndingTime = readDimTime().1
      if #available(watchOS 10, *) {
        is_watchOS10 = true
      } else {
        is_watchOS10 = false
      }
      locationManager.getAccessStatus(completion: { status in
        locationAccessStatus = status
      })
//        dimmingCoefficient = Double(dimmingCoefficientIndex) / 100
      Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
        locationManager.getAccessStatus(completion: { status in
          locationAccessStatus = status
        })
      }
    }
  }
}


let scheduleNames: [LocalizedStringKey] = ["Settings.appearance.schedule.constantly-off", "Settings.appearance.schedule.constantly-on", "Settings.appearance.schedule.period", "Settings.appearance.schedule.solar"]


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  
  override init() {
    super.init()
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyReduced
  }
  
  func requestAccess() {
    self.locationManager.requestWhenInUseAuthorization()
  }
  
  var gottenLocation: (CLLocation) -> Void = { _ in }
  var locationAccessStatus: (CLAuthorizationStatus) -> Void = { _ in }
  
  func getLocation(completion: @escaping (CLLocation) -> Void) {
    gottenLocation = completion
    self.locationManager.requestLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    gottenLocation(locations.first!)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    print(error)
  }
  
  func getAccessStatus(completion: @escaping (CLAuthorizationStatus) -> Void) {
//    locationAccessStatus = completion
    completion(self.locationManager.authorizationStatus)
//    locationAccessStatus()
  }
}

@MainActor @discardableResult func writeDimTime(from: Date, to: Date) -> Bool {
  do {
    let fileURL = getDocumentsDirectory().appendingPathComponent("DimTime.txt")
    let fComponents = Calendar.current.dateComponents([.hour, .minute], from: from)
    let fHour = fComponents.hour ?? 0
    let fMinute = fComponents.minute ?? 0
    
    let tComponents = Calendar.current.dateComponents([.hour, .minute], from: to)
    let tHour = tComponents.hour ?? 0
    let tMinute = tComponents.minute ?? 0
    try "\(fHour):\(fMinute),\(tHour):\(tMinute)".write(to: fileURL, atomically: true, encoding: .utf8)
    return true
  } catch {
    return false
  }
}

@MainActor func readDimTime() -> (Date, Date) {
  do {
    let fileData = try Data(contentsOf: getDocumentsDirectory().appendingPathComponent("DimTime.txt"))
    let fileContent = String(decoding: fileData, as: UTF8.self)
    
    var dateComponentsFrom = DateComponents()
    let dateFrom = fileContent.components(separatedBy: ",")[0]
    dateComponentsFrom.hour = Int(dateFrom.components(separatedBy: ":")[0])
    dateComponentsFrom.minute = Int(dateFrom.components(separatedBy: ":")[1])
    let calendarFrom = Calendar(identifier: .gregorian)
    
    var dateComponentsTo = DateComponents()
    let dateTo = fileContent.components(separatedBy: ",")[1]
    dateComponentsTo.hour = Int(dateTo.components(separatedBy: ":")[0])
    dateComponentsTo.minute = Int(dateTo.components(separatedBy: ":")[1])
    let calendarTo = Calendar(identifier: .gregorian)
    
    return (calendarFrom.date(from: dateComponentsFrom) ?? Date(), calendarTo.date(from: dateComponentsTo) ?? Date())
  } catch {
    return (Date(), Date())
  }
}

@MainActor func updateDimTimeWithSolarTimes() {
  var locationManager = LocationManager()
  locationManager.getLocation(completion: { result in
    var solarTime: SolarTime = SolarTime(latitude: .init(value: result.coordinate.latitude, unit: .degrees), longitude: .init(value: result.coordinate.longitude, unit: .degrees), elevation: .init(value: result.altitude, unit: .meters))
    writeDimTime(from: solarTime.sunrise() ?? Date(timeIntervalSince1970: 75600), to: solarTime.sunset() ?? Date(timeIntervalSince1970: 21600))
  })
}

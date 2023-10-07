//
//  ContentView.swift
//  API.challenge
//
//  Created by user on 07/10/23.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: WeatherData?

    var body: some View {
        VStack {
            if let weatherData = weatherData {
                Text ("\(Int(weatherData.temperature))ºC")
                    .font(.custom("", size: 70))
                    .padding()
                VStack {
                    Text("\(weatherData.locationName)")
                    .font(.title2).bold()
                    Text("\(weatherData.condition)")
                    .font(.body).bold()
                    .foregroundColor(.gray)
                }
                Spacer()
                HStack {
                    Text("Salvar")
                        .bold()
                        .padding()
                    .foregroundColor(.gray)
                    Image(systemName: "bookmark")
                        
                    .foregroundColor(.black)
                }
            } else {
                ProgressView()
            }
        }
        .frame(width: 300, height:300)
        .background(.blue.opacity(0.3))
        .cornerRadius(20)
        .onAppear{
            locationManager.requestLocation()
        }
        .onReceive(locationManager.$location) { location in
            guard let location = location else {return}
            fetchWeatherData(for: location)
            
        }
    }
        private func fetchWeatherData(for location: CLLocation) {
        let apiKey = "20ed1f02483fbe4862749ab775b77b9e"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        // Make a network request to fetch weather data
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.weatherData = WeatherData(locationName: weatherResponse.name, temperature: weatherResponse.main.temp, condition: weatherResponse.weather.first?.description ?? "")
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
        }
      }
    
     


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  Decsnow
//
//  Created by Decsnow on 2023/3/28.
//

import SwiftUI

struct ContentView: View {
    @State private var responseText: String = ""
    @State var requestText: String = "input dialogues here"
    
    var body: some View {
        VStack {
            TextEditor(text: $requestText)
                .frame(height: 100)
                .overlay(
                        RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                        )
            Button("GPT train data submission") {
                sendRequest(requestStr: requestText)
            }
            .buttonStyle(CustomButtonStyle())
            Text(responseText)
        }
        .padding()
    }
    
    func sendRequest(requestStr: String) {
        guard let url = URL(string: "https://api.decsnow.net/append-to-file") else {
            print("Invalid URL")
            return
        }
        guard let encodedRequestStr = requestStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Unable to encode request string")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let originalData = encodedRequestStr.data(using: .utf8)!
        //_ = originalData.base64EncodedData()
        request.httpBody = "data=\(originalData.base64EncodedString())".data(using: .utf8)!
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                responseText = "Response status code: \(response.statusCode)\n"
                if let decodedData = Data(base64Encoded: data), let responseBody = String(data: decodedData, encoding: .utf8) {
                    responseText += "Response body: \(responseBody)"
                }
            }
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

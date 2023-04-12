//
//  ContentView.swift
//  Decsnow
//
//  Created by Decsnow on 2023/3/28.
//

import SwiftUI

struct ContentView: View {
    @State private var responseText: String = ""
    @State var requestText: String = ""
    @State var respAlert = false
    @State var reqisEmpty = false
    @State var showAlert = false
    @State var isAnimation: Bool = false
    @State var loading: Bool = false
    
    var body: some View {
        VStack {
            HStack{
                Image(systemName: "arrow.down.app")
                Text("input dialogues in the text editor below")
                Image(systemName: "arrow.down.app")
            }
            TextEditor(text: $requestText)
                .frame(height: 100)
                .overlay(
                        RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                        )
            Button("GPT train data submission") {
                if requestText.countOccurrences(of:"\\n") < 1 {
                               reqisEmpty = true
                                showAlert = true
                } else {
                    reqisEmpty = false
                    // if is not empty send the request
                    loading = true
                    sendRequest(requestStr: requestText)
                }
            }
            .buttonStyle(CustomButtonStyle())
            .alert(isPresented: $showAlert) {
                if reqisEmpty {
                    return Alert(title: Text("Error"), message: Text("Please input dialogues \n(at least two lines)"), dismissButton: .default(Text("OK")))
                } else {
                    return Alert(title: Text("Response"), message: Text("\(responseText)"), dismissButton: .default(Text("Got it!")))
                }
            }
            Text(responseText)
            if loading{
                musicLoading()
                    .onAppear(){
                        self.isAnimation.toggle()
                    }
            }
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
                self.loading = false
                self.respAlert = true
                self.showAlert = true
                if let decodedData = Data(base64Encoded: data), let responseBody = String(data: decodedData, encoding: .utf8) {
                    responseText += "Response body: \(responseBody)"
                }
            }
        }
        task.resume()
    }
    // 音乐起伏加载
func musicLoading() -> some View {
    HStack(alignment: .center, spacing: 5) {
        ForEach(0 ..< 5) { index in
    Capsule(style: .continuous)
                .fill(Color.green)
                .frame(width: 10, height: 50)
                .scaleEffect(isAnimation ? 0.5 : 1.0)
                .animation(.easeInOut(duration: 0.5)
                .repeatForever()
                .delay(Double(index) * 0.1),value: isAnimation
                )
        }
    }
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
extension String {
    func countOccurrences(of stringToFind: String) -> Int {
        let regex = try! NSRegularExpression(pattern: stringToFind, options: [])
        return regex.numberOfMatches(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
    }
}

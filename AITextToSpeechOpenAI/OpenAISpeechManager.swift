//
//  OpenAISpeechManager.swift
//  AITextToSpeechOpenAI
//
//  Created by John goodstadt on 27/11/2023.
//

import Foundation

private let apiKey = "Your API Key"
private let urlString = "https://api.openai.com/v1/audio/speech"

class OpenAISpeechManager: NSObject {
	
	enum OpenAISpeechManagerError: Error {
		case busyError
		case returnedDataBadFormat
		case invalidResponseError
	}

	static let shared = OpenAISpeechManager()
	
	func callOpenAI(text:String,voice:String, quality:String, completion: @escaping ((Result<Data, Error>)) -> Void) {
		
		if let url = URL(string: urlString) {
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
			
			//models:tts-1 or tts-1-hd
			let body: [String: Any] = ["model":quality,"input": text,"voice": voice, "response_format": "mp3"]
			print(body)
			
			do {
				// Convert the parameters to JSON data
				let jsonData = try JSONSerialization.data(withJSONObject: body)
				request.httpBody = jsonData
				
				URLSession.shared.dataTask(with: request) { (data, response, error) in
					if let error = error {
						print("Error: \(error.localizedDescription)")
						return
					}
					
					if let audioContent = data {
						DispatchQueue.main.async {
							completion(.success(audioContent))
						}
					}
				}.resume()
			} catch {
				print("Error converting parameters to JSON: \(error.localizedDescription)")
			}
		}
		
	}

}

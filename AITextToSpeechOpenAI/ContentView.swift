//
//  ContentView.swift
//  AITextToSpeechOpenAI
//
//  Created by John goodstadt on 27/11/2023.
//

import SwiftUI
import AVFoundation



struct ContentView: View {
	
	@State private var selectedVoice = "nova"
	@State var voices = ["alloy", "echo","fable","onyx","nova","shimmer"]
	@State var phrase:String = ""
	@State var results:String = ""
	@State var audioPlayer: AVAudioPlayer? //Use to play returned mp3
	@State private var qualitySD = false
	@State private var enterWords = false
	@State var hideActivityIndicator: Bool = true
	@FocusState private var inFocus: Bool
	
	let defaultPhrase = "This is spoken by OpenAI's Text to Speech engine."
	let userPhrase = "Enter some words in the text box. Then hit play."

	init() {
		UITextField.appearance().clearButtonMode = .whileEditing
	}
	
	var body: some View {
		VStack {
			VStack {
				Text("Select a voice:")
				
				Picker("Select a voice to speak", selection: $selectedVoice) {
					ForEach(voices, id: \.self) {
						Text($0)
							.onTapGesture {
								inFocus = false
							}
					}
				}
				.pickerStyle(.menu)
				
				HStack {
					Text("Quality:tts-1")
					Toggle("tts-1", isOn: $qualitySD).labelsHidden()
						.onChange(of: qualitySD) { value in
							inFocus = false
						}
					Text("tts-1-hd")
					Spacer()
					ActivityIndicatorView(tintColor: .red, scaleSize: 2.0)
						.padding([.bottom,.top],16)
						.hidden(hideActivityIndicator)
					Spacer()
				}//: HSTACK
				
				Text("Tap to hear some spoken text")
					.font(.title2)
					.padding()
				
				Button(action: {
					inFocus = false
					hideActivityIndicator = false
					let quality = qualitySD ? "tts-1-hd" : "tts-1"//models:tts-1 or tts-1-hd
					OpenAISpeechManager.shared.callOpenAI(text: "Hello, my name is John",voice: selectedVoice, quality: quality) { result in
						hideActivityIndicator = true
						switch result {
							case .failure(let error):print("error \(error)")
								print(error)
								results = error.localizedDescription
							case .success(let mp3):
								do{
									self.audioPlayer = try AVAudioPlayer(data: mp3 , fileTypeHint: "mp3")
									self.audioPlayer?.prepareToPlay()
									self.audioPlayer?.play()
									results = "mp3 size:\(mp3.count) bytes"
									
								}catch{
									print(error)
									results = error.localizedDescription
								}
						}
					}
					
					
				}) {
					ZStack {
						Image(systemName: "play.fill")
							.frame(height: 36)
							.imageScale(.large)
							.foregroundColor(.accentColor)
							.font(.system(size: 36))
						
					}
				}
				
				Divider().frame(height: 1)
					.overlay(.gray)
					.padding()
				
				
				VStack{
					Text("Enter some words")
					TextEditor( text: $phrase)
						.frame(height: 100)
						.focused($inFocus,equals: true)
						.font(.custom("Helvetica", size: 16))
						.padding(.all)
						.overlay(
							RoundedRectangle(cornerRadius: 16)
								.stroke(.gray, lineWidth: 0.6)
						)
					
				}
				Spacer()
				
				Text("Tap to speak your text")
					.font(.title2)
					.padding()
				
				Button(action: {
					inFocus = false
					hideActivityIndicator = false
					let phraseToSpeak = phrase.isEmpty ? userPhrase : phrase
					let quality = qualitySD ? "tts-1-hd" : "tts-1"//models:tts-1 or tts-1-hd
					OpenAISpeechManager.shared.callOpenAI(text: phraseToSpeak,voice: selectedVoice, quality: quality) { result in
						hideActivityIndicator = true
						switch result {
							case .failure(let error):print("error \(error)")
								print(error)
								results = error.localizedDescription
							case .success(let mp3):
								do{
									self.audioPlayer = try AVAudioPlayer(data: mp3 , fileTypeHint: "mp3")
									self.audioPlayer?.prepareToPlay()
									self.audioPlayer?.play()
									results = "mp3 size:\(mp3.count) bytes"
									
								}catch{
									print(error)
									results = error.localizedDescription
								}
						}
					}
					
				}) {
					ZStack {
						Image(systemName: "play.fill")
							.frame(height: 36)
							.imageScale(.large)
							.foregroundColor(.accentColor)
							.font(.system(size: 36))
					}
				}
				Divider().frame(height: 1)
					.overlay(.gray)
					.padding()
				
				Text(results)
					.padding()
				
				Spacer()
			}//: VSTACK
			
			
			
		}//: VSTACK
		.padding()

	}

	struct ActivityIndicatorView: View {
		var tintColor: Color = .blue
		var scaleSize: CGFloat = 1.0
		
		var body: some View {
			ProgressView()
				.scaleEffect(scaleSize, anchor: .center)
				.progressViewStyle(CircularProgressViewStyle(tint: tintColor))
		}
	}
	
}

fileprivate extension View {
	@ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
		switch shouldHide {
			case true: self.hidden()
			case false: self
		}
	}
}

#Preview {
	ContentView()
}


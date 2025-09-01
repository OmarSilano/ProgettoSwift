//
//  ChatBotView.swift
//  WasteLess
//
//  Created by Studente on 10/07/25.
//

import SwiftUI

struct Message: Identifiable,Equatable {
    let id = UUID()
    let role: String // "user", "assistant", or "system"
    let content: String
}

struct ChatBotView: View {
    var apiKey: String {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["GROQ_API_KEY"] as? String {
            return key
        }
        return ""
    }

    @State private var prompt = ""
    @State private var messages: [Message] = [
        Message(role: "system", content: """
    Sei un assistente virtuale esperto e appassionato di fitness. Il tuo compito è aiutare gli utenti a migliorare il proprio allenamento, spiegare metodologie di training, fornire consigli su come gestire esercizi, riposi, tecniche, motivazione e abitudini legate all’attività fisica. 

    Se l’utente pone domande riguardanti ambiti più delicati come alimentazione, salute mentale, psicologia, disturbi alimentari, depressione o problematiche mediche, puoi rispondere in modo educato e professionale dando solo consigli generici, ma devi sempre ricordare che per questi temi è fondamentale rivolgersi a figure professionali qualificate (come medici, nutrizionisti o psicologi). 

    Non devi mai sostituirti a professionisti sanitari e non devi fornire diagnosi o piani personalizzati. Se l’argomento esce troppo dal contesto del fitness, puoi gentilmente dire: "Mi dispiace, posso offrire solo consigli generali legati al mondo del fitness. Ti consiglio di rivolgerti a un professionista per un supporto adeguato."

    Ricorda sempre di essere socievole, incoraggiante e chiaro: stai parlando con persone che potrebbero essere alle prime armi nel mondo del fitness.
    """),
        
        Message(role: "assistant", content: "Hi! I'm Atlas, your fitness assistant. I'm here to help you understand how to train better, discover new training methodologies, and give you helpful tips to stay motivated. Please tell me how I can help you today!")
    ]

    @State private var isLoading = false

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { msg in
                            HStack(alignment: .bottom) {
                                if msg.role == "user" {
                                    Spacer()
                                    Text(msg.content)
                                        .id(msg.id)
                                        .padding()
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(10)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                } else if msg.role == "assistant" {
                                    Image("atlas")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                        .alignmentGuide(.bottom) { d in d[.bottom] }
                                    
                                    Text(msg.content)
                                        .id(msg.id)
                                        .padding()
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(10)
                                        .frame(maxWidth: 250, alignment: .leading)
                                    Spacer()
                                }
                            }
                        }

                        if isLoading {
                            ProgressView("Atlas sta pensando...")
                        }
                    }
                    .padding()
                }
                .onChange(of: messages) {
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack {
                TextField("Scrivi un messaggio...", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Invia") {
                    sendPrompt()
                }
                .disabled(prompt.isEmpty || isLoading)
            }
            .padding()
        }
    }

    func sendPrompt() {
        let userMessage = Message(role: "user", content: prompt)
        messages.append(userMessage)
        prompt = ""

        let messagesPayload = messages.map { ["role": $0.role, "content": $0.content] }

        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let key = apiKey
        guard !key.isEmpty else {
            DispatchQueue.main.async {
                messages.append(Message(role: "assistant", content: "⚠️ Errore: API Key non trovata."))
            }
            return
        }
        request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "llama-3.3-70b-versatile",
            "messages": messagesPayload,
            "temperature": 0.7
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = httpBody

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, _, error in
            defer { isLoading = false }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                DispatchQueue.main.async {
                    messages.append(Message(role: "assistant", content: "⚠️ Errore nella risposta."))
                }
                return
            }

            DispatchQueue.main.async {
                messages.append(Message(role: "assistant", content: content.trimmingCharacters(in: .whitespacesAndNewlines)))
            }

        }.resume()
    }
}

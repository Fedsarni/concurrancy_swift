//
//  ContentView.swift
//  MCX_concurrency
//
//  Created by Federica Sarnataro on 25/03/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user : GitHubUser?
    @State private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // Timer
    @State private var githubUsernames: [GitHubUser] = [GitHubUser(login: "T0nyAbb", avatar_url: "", bio: "")] // Lista dei nomi utente GitHub
    
    var body: some View {
        VStack{
        
            Text("Get inspired by various GitHub profiles")
                .padding(.top, -200.0)
                .font(.title)
                .multilineTextAlignment(.center)
                .font(.system(size: 30))
                .bold()
                .foregroundColor(Color(red: 43/255, green: 91/255, blue: 75/255))
            
          
        VStack {
            
            AsyncImage(url: URL(string: user?.avatar_url ?? "")){image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                
            }placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120,height:120)
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title2)
                .padding()
                .foregroundColor(Color(red: 43/255, green: 91/255, blue: 75/255))
            Text(user?.bio ?? "No bio available")
                .padding(.horizontal)
                .onAppear {
                    fetchGitHubUsernames() // Ottieni la lista dei nomi utente GitHub quando appare la vista
                }
            
        }.padding()
        //.frame(maxWidth: .infinity)
            .background(Color(red: 255/255, green: 242/255, blue: 207/255))
            .cornerRadius(20)
            .shadow(radius: 5)
            .onReceive(timer) { _ in // Ricevi evento
                refreshUser() // Aggiorno ogni volta che scatta il timer
            }
        
       }

    }
    
    func refreshUser() {
        Task {
            do {
                user = try await getUser()
            } catch {
                print("Error fetching user:", error)
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        var log = [String]()
        
        
        for i in 0...githubUsernames.count-1{
            
            log.append(githubUsernames[i].login)
            
        }
        
        let randomUsername: String = log.randomElement()!// Scegli a caso
        
        print(randomUsername)
        let endpoint = "https://api.github.com/users/\(randomUsername)"
        
         
        guard let url = URL(string: endpoint) else { throw GHError.invalidURL }
        
        let(data , response) = try await URLSession.shared.data(from: url)
        
        if let response = response as? HTTPURLResponse , response.statusCode != 200 {
            print(response.statusCode)
            print(response)
            throw GHError.invalidResponse
        }
        
        guard let response = response as? HTTPURLResponse , response.statusCode == 200 else{
            throw GHError.invalidResponse
        }

        
        do{
            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
            
        }
    }
    
    func fetchGitHubUsernames() {
        guard let url = URL(string: "https://api.github.com/users") else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                githubUsernames = try decoder.decode([GitHubUser].self, from: data)
                print(githubUsernames)
            } catch {
                print("Error fetching GitHub usernames:", error)
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}

struct GitHubUser : Codable{
    let login: String
    let avatar_url: String
    let bio: String?
    
}

enum GHError : Error{
   case invalidURL
   case invalidResponse
   case invalidData
}





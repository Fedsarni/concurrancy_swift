//
//  ContentView.swift
//  MCX_concurrency
//
//  Created by Federica Sarnataro on 25/03/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user : GitHubUser?
    
    var body: some View {
        VStack {
            
            AsyncImage(url:URL(string: user?.userUrl ?? "")){image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                
            }placeholder: {
                Circle()
                .foregroundColor(.secondary)
            }
            .frame(width: 120,height:120)
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title2)
                .padding()
            Text(user?.bio ?? "Bio Placeholder")
                

        }
        .padding(.top, -250.0)
        .task{
            do{
                user = try await getUser()
            }catch GHError.invalidURL{
                print("invalid URL")
            }catch GHError.invalidResponse{
                print("invalid response")
            }catch GHError.invalidData{
                print("invalid data")
            }catch {
                print("unexpected error")
            }
        }
    }
    
    func getUser()async throws -> GitHubUser{
        let endpoint = "https://api.github.com/users/Fedsarni"
         
        guard let url = URL(string: endpoint)else {throw GHError.invalidURL}
        
        let(data , response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse , response.statusCode == 200 else{
            throw GHError.invalidResponse
        }
        
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        }catch{
            throw GHError.invalidData
            
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
    let userUrl: String
    let bio: String
    
}

enum GHError : Error{
   case invalidURL
   case invalidResponse
   case invalidData
}

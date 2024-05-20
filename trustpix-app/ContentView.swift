import SwiftUI
import Auth0

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: LoginView()) {
                    Text("Iniciar sesión")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                NavigationLink(destination: SignUpView()) {
                    Text("Registrarse")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("TrustPix")
        }
    }
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""

    var body: some View {
        VStack {
            TextField("Correo electrónico", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Contraseña", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                Auth0
                    .authentication()
                    .login(
                        usernameOrEmail: email,
                        password: password,
                        realmOrConnection: "Username-Password-Authentication",
                        audience: "https://trustpix.eu.auth0.com/userinfo",
                        scope: "openid profile email"
                    )
                    .start { result in
                        switch result {
                        case .success(let credentials):
                            message = "Login successful: \(credentials)"
                        case .failure(let error):
                            message = "Login failed: \(error.localizedDescription)"
                        }
                    }
            }) {
                Text("Iniciar sesión")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Text(message)
                .padding()
                .foregroundColor(.red)
        }
        .padding()
        .navigationTitle("Iniciar sesión")
    }
}

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var message = ""

    var body: some View {
        VStack {
            TextField("Correo electrónico", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Contraseña", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Nombre", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Apellido", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                signUp(email: email, password: password, firstName: firstName, lastName: lastName)
            }) {
                Text("Registrarse")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Text(message)
                .padding()
                .foregroundColor(.red)
        }
        .padding()
        .navigationTitle("Registrarse")
    }

    func signUp(email: String, password: String, firstName: String, lastName: String) {
        let url = URL(string: "https://trustpix.eu.auth0.com/dbconnections/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "client_id": "ue3T1NXKVAhQA5bPynsc5Uolq6dtt24O",
            "email": email,
            "password": password,
            "connection": "Username-Password-Authentication",
            "user_metadata": ["first_name": firstName, "last_name": lastName]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    message = "Sign up failed: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    message = "Sign up failed: No data received"
                }
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        if let error = jsonResponse["error"] as? String {
                            message = "Sign up failed: \(error)"
                        } else {
                            message = "User signed up successfully"
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    message = "Sign up failed: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


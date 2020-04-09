//
//  ContentView.swift
//  fireauth
//
//  Created by miguel tomairo on 4/9/20.
//  Copyright © 2020 rapser. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    
    var body: some View {
        
        VStack {
            
            if status {
                
                Home()
                
            }else {
                NavigationView {
                    FirstPage()
                }
            }
        }.onAppear {
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) { (_) in
                
                
                let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                
                self.status = status
                
            }
            
        }
    
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct FirstPage: View {
    
    @State var ccode = ""
    @State var no = ""
    @State var show = false
    @State var msg = ""
    @State var alert = false
    @State var ID = ""
    
    var body: some View {
        
        VStack(spacing: 20){
            
            Image("portada")
            
            Text("Verifica tu Número")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            Text("Por favor revisa tu nro celular para verificar tu cuenta")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, 12)
            
            HStack{
                
                TextField("+51", text: $ccode)
                    .keyboardType(.numberPad)
                    .frame(width: 45)
                .padding()
                .background(Color("Color"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                TextField("Número", text: $no)
                    .keyboardType(.numberPad)
                .padding()
                .background(Color("Color"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
            }.padding(.top, 15)
            

            NavigationLink(destination: SecondPage(show: $show, ID: self.$ID), isActive: $show) {
                
                Button(action: {
                    
                    PhoneAuthProvider.provider().verifyPhoneNumber("+"+self.ccode+self.no, uiDelegate: nil) { (id, err) in
                        
                        if err != nil {
                            self.msg = err!.localizedDescription
                            self.alert.toggle()
                            return
                        }
                        
                        self.ID = id!
                        self.show.toggle()
                    }
                    
                }) {
                    Text("Enviar")
                    .frame(width: UIScreen.main.bounds.width - 30, height: 50)
                    
                }.foregroundColor(.white)
                .background(Color.orange)
                .cornerRadius(10)
            }
            
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
        }.padding()
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
        }
        .onTapGesture {
            self.endEditing(true)
        }
    }
    

}

struct SecondPage: View {
    
    @State var code = ""
    @Binding var show : Bool
    @Binding var ID: String
    @State var alert = false
    @State var msg = ""
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            GeometryReader { _ in
                
                VStack(spacing: 20){
                    
                    Image("portada")
                    
                    Text("Código de verificación")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    
                    Text("Por favor ingresa tu código de verificación")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 12)

                    TextField("Código", text: self.$code)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 15)
                    

                    
                    Button(action: {
                        
                        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.code)
                        
                        Auth.auth().signIn(with: credential) { (result, err) in
                            
                            if err != nil {
                                self.msg = err!.localizedDescription
                                self.alert.toggle()
                                return
                            }
                            
                            UserDefaults.standard.set(true, forKey: "status")
                            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                        }
                        
                    }) {
                        Text("Verificar")
                            .frame(width: UIScreen.main.bounds.width - 30, height: 50)
                        
                    }.foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                    
                }
            }
            
            Button(action: {
                self.show.toggle()
            }) {
                
                Image(systemName: "chevron.left")
                    .font(.title)
            }.foregroundColor(.orange)
        }
        .padding()
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("OK")))
        }
        .onTapGesture {
            self.endEditing(true)
        }
    }
}

struct Home: View {
    
    var body: some View {
        
        VStack {
            Text("Principal")
            
            Button(action: {
                
                try! Auth.auth().signOut()
                
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)

                
            }) {
                Text("Logout")
            }
        }
    }
}

extension View {
    func endEditing(_ force: Bool) {
        UIApplication.shared.windows.forEach { $0.endEditing(force)}
    }
}

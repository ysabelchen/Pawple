//
//  ViewController.swift
//  Pawple
//
//  Created by 22ysabelc on 4/22/20.
//  Copyright © 2020 Ysabel Chen. All rights reserved.
//

import UIKit
import CLTypingLabel
import GoogleSignIn
import Firebase
import CryptoKit
import AuthenticationServices

class WelcomeViewController: UIViewController {
        
    fileprivate var currentNonce: String?
    
    @IBOutlet weak var welcomeText: CLTypingLabel!
    @IBOutlet weak var luckypawText: CLTypingLabel!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var appleSignInButton: ASAuthorizationAppleIDButton!
    
    @IBAction func signInWithGoogleAction(_ sender: Any) {
          GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func signInWithAppleAction(_ sender: Any) {
        performSignIn()
        print("self.view.window: \(self.view.window)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    @available(iOS 13, *)
    func performSignIn() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        print("currentNonce: \(currentNonce)")
        
        return request
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension WelcomeViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print ("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from date: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

            Auth.auth().signIn(with: credential) { (authDataResult, error) in
                if (error != nil) {
                    self.alert(title: "Error signing in", message: error?.localizedDescription)
                    return
                } else if let user = authDataResult?.user {
                    let uid = user.uid
                    print("uid: \(uid)")
                    var values = [String: Any]()
                    let databaseRef = Database.database().reference()
                    let userRef = databaseRef.child("users").child(uid)
                    values["photoURL"] = ""
                    if let name = user.displayName {
                        values["name"] = name
                        userRef.updateChildValues(values) { (error, _) in
                            if error != nil {
                                self.alert(title: "Error updating database", message: error?.localizedDescription)
                                return
                            }
                        }
                        print("name: \(name)")
                    }
                    if let email = user.email {
                        values["email"] = email
                        userRef.updateChildValues(values) { (error, _) in
                            if error != nil {
                                self.alert(title: "Error updating database", message: error?.localizedDescription)
                                return
                            }
                        }
                    }
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

extension WelcomeViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: Array<Character> =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
      }
      return random
    }

    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}

// MARK: - Google Sign In
extension WelcomeViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                alert(title: "The user has not signed in before or they have since signed out.", message: "")
            } else {
                alert(title: "Error signing in", message: error.localizedDescription)
            }
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (_, error) in
            if let error = error {
                let authError = error as NSError
                self.alert(title: "Error signing in", message: authError.localizedDescription)
                return
            }
            
            let user = Auth.auth().currentUser
            
            guard let uid = user?.uid else {
                return
            }
            
            var values = [String: Any]()
            if let photoURL = user?.photoURL {
                values["photoURL"] = photoURL.absoluteString
            }
            let databaseRef = Database.database().reference()
            let userRef = databaseRef.child("users").child(uid)
            if let name = user?.displayName, let email = user?.email {
                values["name"] = name
                values["email"] = email
                userRef.updateChildValues(values) { (error, _) in
                    if error != nil {
                        self.alert(title: "Error updating database", message: error?.localizedDescription)
                        return
                    }
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
}

//
//  ViewController.swift
//  NeedToMeasureDrink
//
//  Created by 백상휘 on 2020/03/16.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {

    @IBOutlet var loginProviderStackView: UIStackView!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var idTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidekeyboard()
        self.view.backgroundColor = UIColor.flatSkyBlueDark()
        idTextField.addTarget(self, action: #selector(moveTextFieldFocus(textfield:)), for: UIControl.Event.editingDidEndOnExit)
        passwordTextField.addTarget(self, action: #selector(textFieldFocusOut(textfield:)), for: UIControl.Event.editingDidEndOnExit)
        // Do any additional setup after loading the view.
        setupProviderLoginView()
    }
    
    @objc func moveTextFieldFocus(textfield: UITextField) {}
    
    @objc func textFieldFocusOut(textfield: UITextField) {}
    
}

extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(loginProviderStackViewButtonPress), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    @objc func loginProviderStackViewButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let requests = appleIDProvider.createRequest()
        requests.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [requests])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func performExistingAccountSetupFlows() {
        let requests = [ASAuthorizationAppleIDProvider().createRequest(), ASAuthorizationPasswordProvider().createRequest()]
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Create an account in your system
            let userIdentifier = appleIDCredential.user
            //let fullName = appleIDCredential.fullName
            //let email = appleIDCredential.email
            
            self.saveUserInKeychaing(userIdentifier)
            self.loginButton.setTitle("Sign out", for: .normal)
            self.loginButton.backgroundColor = #colorLiteral(red: 0.6624035239, green: 0, blue: 0.08404419571, alpha: 1)
        case let passwordCredential as ASPasswordCredential:
            //Sing in using an existing iCloud Keychain credential
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
        default:
            break
        }
    }
    
    private func saveUserInKeychaing(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.sanghwi.NeedToMeasureDrink", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain")
        }
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController {
    func hidekeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            textFieldFocusOut(textfield: textField)
        }else if textField == idTextField {
            moveTextFieldFocus(textfield: textField)
        }else{
            return false
        }
        return true
    }
}

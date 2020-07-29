//
//  ViewController.swift
//  NeedToMeasureDrink
//
//  Created by 백상휘 on 2020/03/16.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import AuthenticationServices
import RxSwift
import RxCocoa
import FBSDKLoginKit

class ViewController: UIViewController {
    var disposeBag = DisposeBag()
    var message = ""
    let alertViewController = UIAlertController()

    @IBOutlet var loginProviderStackView: UIStackView!
    @IBOutlet weak var FacebookLoginStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidekeyboard()
        self.view.backgroundColor = UIColor.flatSkyBlueDark()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //Apple login
        setupProviderLoginView()
        
        //Facebook login
        let facebookLoginBtn = FBLoginButton()
        FacebookLoginStackView.addArrangedSubview(facebookLoginBtn)
        if let token = AccessToken.current, !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            performSegue(withIdentifier: "showWhatYouDrink", sender: nil)
        }
        
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "showWhatYouDrink":
            return true
        default:
            return false
        }
    }
    
    @IBAction func testInAction(_ sender: UIButton) {
        performSegue(withIdentifier: "showWhatYouDrink", sender: nil)
    }
}

extension ViewController {
    
    func idCheck(from id: String) -> Bool {
        guard id != "" else { return false }
        
        if id.contains("@") && id.contains(".") {
            message = "이메일 형식에 맞지 않습니다."
            return true
        }
        
        return false
    }
    
    func pwCheck(from pw: String) -> Bool {
        guard pw != "" else { return false }
        
        let pwIntegerCount = pw.filter{(0...9).contains(Int(String($0)) ?? 10)}.count
        
        return pwIntegerCount>3
    }
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
            
            self.saveUserInKeychaing(userIdentifier)
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

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == passwordTextField {
//            textFieldFocusOut(textfield: textField)
//        }else if textField == idTextField {
//            moveTextFieldFocus(textfield: textField)
//        }else{
//            return false
//        }
        return false
    }
    
    func hidekeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func moveTextFieldFocus(textfield: UITextField) {}
    
    @objc func textFieldFocusOut(textfield: UITextField) {}
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
}

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

    @IBOutlet weak var facebookLoginView: UIView!
    @IBOutlet weak var appleLoginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Apple login
        setupProviderLoginView()
        
        //Facebook login
        let facebookLoginBtn = FBLoginButton()
        self.facebookLoginView.addSubview(facebookLoginBtn)
        
        facebookLoginBtn.translatesAutoresizingMaskIntoConstraints = false
        
        facebookLoginBtn.widthAnchor.constraint(equalTo: self.appleLoginView.widthAnchor).isActive = true
        facebookLoginBtn.heightAnchor.constraint(equalTo: self.appleLoginView.heightAnchor).isActive = true
        
        if let token = AccessToken.current, !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            performSegue(withIdentifier: "showWhatYouDrink", sender: nil)
        }
        
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    @IBAction func testInAction(_ sender: UIButton) {
        performSegue(withIdentifier: "showWhatYouDrink", sender: nil)
    }
}

extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(loginProviderStackViewButtonPress), for: .touchUpInside)
        self.appleLoginView.addSubview(authorizationButton)
        
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        
        authorizationButton.widthAnchor.constraint(equalTo: self.appleLoginView.widthAnchor).isActive = true
        authorizationButton.heightAnchor.constraint(equalTo: self.appleLoginView.heightAnchor).isActive = true
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

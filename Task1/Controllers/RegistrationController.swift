//
//  RegistrationController.swift
//  Task
//
//  Created by Harshit ‎ on 5/22/25.
//

import UIKit

protocol RegistrationControllerProtocol: AnyObject {
    func registerUser(with data: UserRegistrationData)
    func validateForm(_ data: UserRegistrationData) -> Bool
}

protocol RegistrationControllerDelegate: AnyObject {
    func registrationDidSucceed(userId: String, verificationCode: String)
    func registrationDidFail(with error: String)
    func validationDidFail(with error: String)
}

class RegistrationController: RegistrationControllerProtocol {
    
    weak var delegate: RegistrationControllerDelegate?
    private let apiService: APIServiceProtocol
    private let validationService: ValidationService
    
    init(apiService: APIServiceProtocol = APIService.shared,
         validationService: ValidationService = ValidationService.shared) {
        self.apiService = apiService
        self.validationService = validationService
    }
    
    func registerUser(with data: UserRegistrationData) {
        guard validateForm(data) else {
            return
        }
        
        let request = data.toRegistrationRequest()
        
        apiService.registerUser(request) { [weak self] result in
            switch result {
            case .success(let response):
                self?.handleRegistrationSuccess(response)
            case .failure(let error):
                self?.handleRegistrationFailure(error)
            }
        }
    }
    
    func validateForm(_ data: UserRegistrationData) -> Bool {
        let validationResults = validationService.validateRegistrationForm(data)
        if validationService.isFormValid(validationResults) {
            return true
        } else {
            if let errorMessage = validationService.getFirstError(validationResults) {
                delegate?.validationDidFail(with: errorMessage)
            }
            return false
        }
    }
    
    private func handleRegistrationSuccess(_ response: RegistrationResponse) {
        if response.success {
            // Extract userId and code from the correct locations
            let userId = String(response.data?.id ?? 0)
            let verificationCode = response.data?.code ?? ""
            
            print("Registration Success - UserId: \(userId), Code: \(verificationCode)")
            
            delegate?.registrationDidSucceed(userId: userId, verificationCode: verificationCode)
        } else {
            delegate?.registrationDidFail(with: response.message)
        }
    }
    
    private func handleRegistrationFailure(_ error: APIError) {
        delegate?.registrationDidFail(with: error.localizedDescription)
    }
}

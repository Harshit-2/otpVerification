//
//  File.swift
//  Task
//
//  Created by Harshit ‎ on 5/22/25.
//

import UIKit

// MARK: - OTP Controller Protocol

protocol OTPControllerProtocol: AnyObject {
    func verifyOTP(_ otp: String, userId: String)
    func validateOTP(_ otp: String) -> Bool
    func resendOTP(userId: String)
}

// MARK: - OTP Controller Delegate

protocol OTPControllerDelegate: AnyObject {
    func otpVerificationDidSucceed()
    func otpVerificationDidFail(with error: String)
    func otpValidationDidFail(with error: String)
    func otpResendDidSucceed()
    func otpResendDidFail(with error: String)
}

// MARK: - OTP Controller Implementation

class OTPController: OTPControllerProtocol {
    
    // MARK: - Properties
    
    weak var delegate: OTPControllerDelegate?
    private let apiService: APIServiceProtocol
    private let validationService: ValidationService
    
    // MARK: - Initialization
    
    init(apiService: APIServiceProtocol = APIService.shared,
         validationService: ValidationService = ValidationService.shared) {
        self.apiService = apiService
        self.validationService = validationService
    }
    
    // MARK: - Public Methods
    
    func verifyOTP(_ otp: String, userId: String) {
        // Validate OTP first
        guard validateOTP(otp) else {
            return
        }
        
        // Create request
        let request = OTPRequest(otp: otp, userId: userId)
        
        // Make API call
        apiService.verifyOTP(request) { [weak self] result in
            switch result {
            case .success(let response):
                self?.handleOTPVerificationSuccess(response)
            case .failure(let error):
                self?.handleOTPVerificationFailure(error)
            }
        }
    }
    
    func validateOTP(_ otp: String) -> Bool {
        let validationResult = validationService.validateOTP(otp)
        
        if validationResult.isValid {
            return true
        } else {
            if let errorMessage = validationResult.errorMessage {
                delegate?.otpValidationDidFail(with: errorMessage)
            }
            return false
        }
    }
    
    func resendOTP(userId: String) {
        // This would typically be another API call
        // For now, we'll simulate success
        // In a real implementation, you might have a resend-otp endpoint
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Simulate API call
            self?.delegate?.otpResendDidSucceed()
        }
    }
    
    // MARK: - Private Methods
    
    private func handleOTPVerificationSuccess(_ response: OTPResponse) {
        // Some APIs always return success = true, even for invalid OTPs
        // So we must check the message or specific data to confirm real success
        let message = response.message.lowercased()

        if message.contains("otp verified") {
            print("OTP verification success - \(response.message)")
            delegate?.otpVerificationDidSucceed()
        } else {
            print("OTP verification failed - \(response.message)")
            delegate?.otpVerificationDidFail(with: "Invalid OTP. Please try again.")
        }
    }
    
    private func handleOTPVerificationFailure(_ error: APIError) {
        delegate?.otpVerificationDidFail(with: error.localizedDescription)
    }
}

//
//  OTPVerificationViewController.swift
//  Task
//
//  Created by Harshit ‎ on 5/22/25.
//

import Foundation

// MARK: - Validation Service

class ValidationService {
    static let shared = ValidationService()
    
    private init() {}
    
    // MARK: - Email Validation
    
    func validateEmail(_ email: String) -> ValidationResult {
        guard !email.isEmpty else {
            return ValidationResult(isValid: false, errorMessage: "Email is required")
        }
        
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if emailPredicate.evaluate(with: email) {
            return ValidationResult(isValid: true, errorMessage: nil)
        } else {
            return ValidationResult(isValid: false, errorMessage: "Please enter a valid email address")
        }
    }
    
    // MARK: - Name Validation
    
    func validateName(_ name: String, fieldName: String) -> ValidationResult {
        guard !name.isEmpty else {
            return ValidationResult(isValid: false, errorMessage: "\(fieldName) is required")
        }
        
        guard name.count >= 2 else {
            return ValidationResult(isValid: false, errorMessage: "\(fieldName) must be at least 2 characters long")
        }
        
        let nameRegex = "^[a-zA-Z\\s]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        
        if namePredicate.evaluate(with: name) {
            return ValidationResult(isValid: true, errorMessage: nil)
        } else {
            return ValidationResult(isValid: false, errorMessage: "\(fieldName) should only contain letters and spaces")
        }
    }
    
    // MARK: - Password Validation
    
    func validatePassword(_ password: String) -> ValidationResult {
        guard !password.isEmpty else {
            return ValidationResult(isValid: false, errorMessage: "Password is required")
        }
        
        guard password.count >= 8 else {
            return ValidationResult(isValid: false, errorMessage: "Password must be at least 8 characters long")
        }
        
        // Check for at least one uppercase, one lowercase, one digit
        let uppercaseRegex = ".*[A-Z]+.*"
        let lowercaseRegex = ".*[a-z]+.*"
        let digitRegex = ".*[0-9]+.*"
        
        let hasUppercase = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password)
        let hasLowercase = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: password)
        let hasDigit = NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: password)
        
        if hasUppercase && hasLowercase && hasDigit {
            return ValidationResult(isValid: true, errorMessage: nil)
        } else {
            return ValidationResult(isValid: false, errorMessage: "Password must contain at least one uppercase letter, one lowercase letter, and one digit")
        }
    }
    
    // MARK: - Confirm Password Validation
    
    func validateConfirmPassword(_ confirmPassword: String, originalPassword: String) -> ValidationResult {
        guard !confirmPassword.isEmpty else {
            return ValidationResult(isValid: false, errorMessage: "Please confirm your password")
        }
        
        if confirmPassword == originalPassword {
            return ValidationResult(isValid: true, errorMessage: nil)
        } else {
            return ValidationResult(isValid: false, errorMessage: "Passwords do not match")
        }
    }
    
    // MARK: - Phone Validation
    
    func validatePhone(_ phone: String) -> ValidationResult {
        guard !phone.isEmpty else {
            return ValidationResult(isValid: false, errorMessage: "Phone number is required")
        }
        
        // Remove any non-digit characters for validation
        let digitsOnly = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard digitsOnly.count >= 8 && digitsOnly.count <= 15 else {
            return ValidationResult(isValid: false, errorMessage: "Phone number must be between 8 and 15 digits")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    // MARK: - OTP Validation
    
    func validateOTP(_ otp: String) -> ValidationResult {
        guard !otp.isEmpty else {
            return ValidationResult(isValid: false, errorMessage: "OTP is required")
        }
        
        let digitsOnly = otp.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard digitsOnly.count == 5 || digitsOnly.count == 6 else {
            return ValidationResult(isValid: false, errorMessage: "Please enter a valid OTP")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    // MARK: - Complete Form Validation
    
    func validateRegistrationForm(_ formData: UserRegistrationData) -> [ValidationResult] {
        var results: [ValidationResult] = []
        
        results.append(validateName(formData.firstName, fieldName: "First name"))
        results.append(validateName(formData.lastName, fieldName: "Last name"))
        results.append(validateEmail(formData.email))
        results.append(validatePassword(formData.password))
        results.append(validateConfirmPassword(formData.confirmPassword, originalPassword: formData.password))
        results.append(validatePhone(formData.phone))
        
        return results
    }
    
    func isFormValid(_ validationResults: [ValidationResult]) -> Bool {
        return validationResults.allSatisfy { $0.isValid }
    }
    
    func getFirstError(_ validationResults: [ValidationResult]) -> String? {
        return validationResults.first { !$0.isValid }?.errorMessage
    }
}

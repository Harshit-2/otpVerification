//
//  RegistrationModule.swift
//  Task
//
//  Created by Harshit ‎ on 5/22/25.
//

import UIKit

// MARK: - Registration Models
struct RegistrationRequest: Codable {
    let appVersion: String
    let deviceModel: String
    let deviceToken: String
    let deviceType: String
    let dob: String
    let email: String
    let firstName: String
    let gender: String
    let lastName: String
    let newsletterSubscribed: Int
    let osVersion: String
    let password: String
    let phone: String
    let phoneCode: String
    
    enum CodingKeys: String, CodingKey {
        case appVersion = "app_version"
        case deviceModel = "device_model"
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case dob
        case email
        case firstName = "first_name"
        case gender
        case lastName = "last_name"
        case newsletterSubscribed = "newsletter_subscribed"
        case osVersion = "os_version"
        case password
        case phone
        case phoneCode = "phone_code"
    }
}

struct RegistrationResponse: Codable {
    let success: Bool
    let status: Int?
    let message: String
    let data: RegistrationData?
}

struct RegistrationData: Codable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let gender: String?
    let dob: String?
    let email: String?
    let image: String?
    let phoneCode: String?
    let phone: String?
    let code: String?
    let isPhoneVerified: Int?
    let isEmailVerified: Int?
    let isSocialRegister: Int?
    let socialRegisterType: String?
    let deviceToken: String?
    let deviceType: String?
    let deviceModel: String?
    let appVersion: String?
    let osVersion: String?
    let pushEnabled: String?
    let newsletterSubscribed: Int?
    let createDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case gender
        case dob
        case email
        case image
        case phoneCode = "phone_code"
        case phone
        case code
        case isPhoneVerified = "is_phone_verified"
        case isEmailVerified = "is_email_verified"
        case isSocialRegister = "is_social_register"
        case socialRegisterType = "social_register_type"
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case deviceModel = "device_model"
        case appVersion = "app_version"
        case osVersion = "os_version"
        case pushEnabled = "push_enabled"
        case newsletterSubscribed = "newsletter_subscribed"
        case createDate = "create_date"
    }
}

// MARK: - OTP Models
struct OTPRequest: Codable {
    let otp: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case otp
        case userId = "user_id"
    }
}

struct OTPResponse: Codable {
    let success: Bool
    let message: String
    let data: OTPGenericData?
}

struct OTPGenericData: Codable {
    let id: String?
    let code: String?
}

struct OTPData: Codable {
    let verified: Bool
    let userId: String?
    
    enum CodingKeys: String, CodingKey {
        case verified
        case userId = "user_id"
    }
}

// MARK: - Validation Models
struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?
}

// MARK: - User Data Model
struct UserRegistrationData {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var phone: String = ""
    var phoneCode: String = "965"
    var dob: String = ""
    var gender: String = ""
    var newsletterSubscribed: Bool = false
    
    func toRegistrationRequest() -> RegistrationRequest {
        return RegistrationRequest(
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            deviceModel: UIDevice.current.model,
            deviceToken: "",
            deviceType: "I", // iOS
            dob: dob,
            email: email,
            firstName: firstName,
            gender: gender,
            lastName: lastName,
            newsletterSubscribed: newsletterSubscribed ? 1 : 0,
            osVersion: UIDevice.current.systemVersion,
            password: password,
            phone: phone,
            phoneCode: phoneCode
        )
    }
}

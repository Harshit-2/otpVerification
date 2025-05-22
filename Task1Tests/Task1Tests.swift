//
//  Task1Tests.swift
//  Task1Tests
//
//  Created by Harshit ‎ on 5/22/25.
//

import XCTest
@testable import Task1

// MARK: - Validation Service Tests

class ValidationServiceTests: XCTestCase {
    
    var validationService: ValidationService!
    
    override func setUp() {
        super.setUp()
        validationService = ValidationService.shared
    }
    
    override func tearDown() {
        validationService = nil
        super.tearDown()
    }
    
    // MARK: - Email Validation Tests
    
    func testValidEmailAddresses() {
        let validEmails = [
            "test@example.com",
            "user.name@domain.co.uk",
            "user+tag@example.org",
            "123@test.com"
        ]
        
        for email in validEmails {
            let result = validationService.validateEmail(email)
            XCTAssertTrue(result.isValid, "Email '\(email)' should be valid")
            XCTAssertNil(result.errorMessage)
        }
    }
    
    func testInvalidEmailAddresses() {
        let invalidEmails = [
            "",
            "invalid-email",
            "@domain.com",
            "user@",
            "user name@domain.com",
            "user@domain",
            "user@.com"
        ]
        
        for email in invalidEmails {
            let result = validationService.validateEmail(email)
            XCTAssertFalse(result.isValid, "Email '\(email)' should be invalid")
            XCTAssertNotNil(result.errorMessage)
        }
    }
    
    // MARK: - Name Validation Tests
    
    func testValidNames() {
        let validNames = [
            "John",
            "Mary Jane",
            "O'Connor",
            "Jean-Pierre"
        ]
        
        for name in validNames {
            let result = validationService.validateName(name, fieldName: "First name")
            XCTAssertTrue(result.isValid, "Name '\(name)' should be valid")
            XCTAssertNil(result.errorMessage)
        }
    }
    
    func testInvalidNames() {
        let invalidNames = [
            "",
            "A",
            "John123",
            "John@Doe"
        ]
        
        for name in invalidNames {
            let result = validationService.validateName(name, fieldName: "First name")
            XCTAssertFalse(result.isValid, "Name '\(name)' should be invalid")
            XCTAssertNotNil(result.errorMessage)
        }
    }
    
    // MARK: - Password Validation Tests
    
    func testValidPasswords() {
        let validPasswords = [
            "Password123",
            "MySecure1Pass",
            "Test1234"
        ]
        
        for password in validPasswords {
            let result = validationService.validatePassword(password)
            XCTAssertTrue(result.isValid, "Password '\(password)' should be valid")
            XCTAssertNil(result.errorMessage)
        }
    }
    
    func testInvalidPasswords() {
        let invalidPasswords = [
            "",
            "short",
            "password", // no uppercase or digit
            "PASSWORD123", // no lowercase
            "Password", // no digit
            "password123" // no uppercase
        ]
        
        for password in invalidPasswords {
            let result = validationService.validatePassword(password)
            XCTAssertFalse(result.isValid, "Password '\(password)' should be invalid")
            XCTAssertNotNil(result.errorMessage)
        }
    }
    
    // MARK: - Phone Validation Tests
    
    func testValidPhoneNumbers() {
        let validPhones = [
            "12345678",
            "1234567890123",
            "+1234567890"
        ]
        
        for phone in validPhones {
            let result = validationService.validatePhone(phone)
            XCTAssertTrue(result.isValid, "Phone '\(phone)' should be valid")
            XCTAssertNil(result.errorMessage)
        }
    }
    
    func testInvalidPhoneNumbers() {
        let invalidPhones = [
            "",
            "1234567", // too short
            "12345678901234567", // too long
            "abcdefgh"
        ]
        
        for phone in invalidPhones {
            let result = validationService.validatePhone(phone)
            XCTAssertFalse(result.isValid, "Phone '\(phone)' should be invalid")
            XCTAssertNotNil(result.errorMessage)
        }
    }
    
    // MARK: - OTP Validation Tests
    
    func testValidOTPs() {
        let validOTPs = ["12345", "567890"]
        
        for otp in validOTPs {
            let result = validationService.validateOTP(otp)
            XCTAssertTrue(result.isValid, "OTP '\(otp)' should be valid")
            XCTAssertNil(result.errorMessage)
        }
    }
    
    func testInvalidOTPs() {
        let invalidOTPs = ["", "123", "12345678", "abcde"]
        
        for otp in invalidOTPs {
            let result = validationService.validateOTP(otp)
            XCTAssertFalse(result.isValid, "OTP '\(otp)' should be invalid")
            XCTAssertNotNil(result.errorMessage)
        }
    }
}

// MARK: - API Service Tests

class APIServiceTests: XCTestCase {
    
    var apiService: APIService!
    
    override func setUp() {
        super.setUp()
        apiService = APIService.shared
    }
    
    override func tearDown() {
        apiService = nil
        super.tearDown()
    }
    
    func testRegistrationRequestEncoding() {
        let request = RegistrationRequest(
            appVersion: "1.0",
            deviceModel: "iPhone",
            deviceToken: "test-token",
            deviceType: "I",
            dob: "",
            email: "test@example.com",
            firstName: "John",
            gender: "",
            lastName: "Doe",
            newsletterSubscribed: 1,
            osVersion: "15.0",
            password: "Password123",
            phone: "1234567890",
            phoneCode: "965"
        )
        
        do {
            let data = try JSONEncoder().encode(request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            XCTAssertNotNil(json)
            XCTAssertEqual(json?["email"] as? String, "test@example.com")
            XCTAssertEqual(json?["first_name"] as? String, "John")
            XCTAssertEqual(json?["last_name"] as? String, "Doe")
        } catch {
            XCTFail("Failed to encode registration request: \(error)")
        }
    }
    
    func testOTPRequestEncoding() {
        let request = OTPRequest(otp: "12345", userId: "123")
        
        do {
            let data = try JSONEncoder().encode(request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            XCTAssertNotNil(json)
            XCTAssertEqual(json?["otp"] as? String, "12345")
            XCTAssertEqual(json?["user_id"] as? String, "123")
        } catch {
            XCTFail("Failed to encode OTP request: \(error)")
        }
    }
}

// MARK: - Registration Controller Tests

class RegistrationControllerTests: XCTestCase {
    
    var registrationController: RegistrationController!
    var mockAPIService: MockAPIService!
    var mockDelegate: MockRegistrationDelegate!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockDelegate = MockRegistrationDelegate()
        registrationController = RegistrationController(
            apiService: mockAPIService,
            validationService: ValidationService.shared
        )
        registrationController.delegate = mockDelegate
    }
    
    override func tearDown() {
        registrationController = nil
        mockAPIService = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testValidFormData() {
        var formData = UserRegistrationData()
        formData.firstName = "John"
        formData.lastName = "Doe"
        formData.email = "john.doe@example.com"
        formData.password = "Password123"
        formData.confirmPassword = "Password123"
        formData.phone = "1234567890"
        
        let isValid = registrationController.validateForm(formData)
        XCTAssertTrue(isValid)
        XCTAssertFalse(mockDelegate.validationDidFailCalled)
    }
    
    func testInvalidFormData() {
        var formData = UserRegistrationData()
        formData.firstName = "" // Invalid
        formData.lastName = "Doe"
        formData.email = "invalid-email"
        formData.password = "weak"
        formData.confirmPassword = "different"
        formData.phone = "123"
        
        let isValid = registrationController.validateForm(formData)
        XCTAssertFalse(isValid)
        XCTAssertTrue(mockDelegate.validationDidFailCalled)
        XCTAssertNotNil(mockDelegate.validationError)
    }
}

// MARK: - OTP Controller Tests

class OTPControllerTests: XCTestCase {
    
    var otpController: OTPController!
    var mockAPIService: MockAPIService!
    var mockDelegate: MockOTPDelegate!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockDelegate = MockOTPDelegate()
        otpController = OTPController(
            apiService: mockAPIService,
            validationService: ValidationService.shared
        )
        otpController.delegate = mockDelegate
    }
    
    override func tearDown() {
        otpController = nil
        mockAPIService = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testValidOTP() {
        let isValid = otpController.validateOTP("12345")
        XCTAssertTrue(isValid)
        XCTAssertFalse(mockDelegate.otpValidationDidFailCalled)
    }
    
    func testInvalidOTP() {
        let isValid = otpController.validateOTP("123")
        XCTAssertFalse(isValid)
        XCTAssertTrue(mockDelegate.otpValidationDidFailCalled)
        XCTAssertNotNil(mockDelegate.validationError)
    }
}

// MARK: - Mock Classes

class MockAPIService: APIServiceProtocol {
    var shouldSucceed = true
    var registrationResponse: RegistrationResponse?
    var otpResponse: OTPResponse?
    
    func registerUser(_ request: RegistrationRequest, completion: @escaping (Result<RegistrationResponse, APIError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                let response = self.registrationResponse ?? RegistrationResponse(
                    success: true,
                    message: "Success",
                    data: RegistrationData(userId: "123", verificationCode: "12345"),
                    code: "12345",
                    userId: "123"
                )
                completion(.success(response))
            } else {
                completion(.failure(.serverError("Mock error")))
            }
        }
    }
    
    func verifyOTP(_ request: OTPRequest, completion: @escaping (Result<OTPResponse, APIError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                let response = self.otpResponse ?? OTPResponse(
                    success: true,
                    message: "Verified",
                    data: OTPData(verified: true, userId: "123")
                )
                completion(.success(response))
            } else {
                completion(.failure(.serverError("Mock error")))
            }
        }
    }
}

class MockRegistrationDelegate: RegistrationControllerDelegate {
    var registrationDidSucceedCalled = false
    var registrationDidFailCalled = false
    var validationDidFailCalled = false
    var userId: String?
    var verificationCode: String?
    var registrationError: String?
    var validationError: String?
    
    func registrationDidSucceed(userId: String, verificationCode: String) {
        registrationDidSucceedCalled = true
        self.userId = userId
        self.verificationCode = verificationCode
    }
    
    func registrationDidFail(with error: String) {
        registrationDidFailCalled = true
        registrationError = error
    }
    
    func validationDidFail(with error: String) {
        validationDidFailCalled = true
        validationError = error
    }
}

class MockOTPDelegate: OTPControllerDelegate {
    var otpVerificationDidSucceedCalled = false
    var otpVerificationDidFailCalled = false
    var otpValidationDidFailCalled = false
    var otpResendDidSucceedCalled = false
    var otpResendDidFailCalled = false
    var verificationError: String?
    var validationError: String?
    var resendError: String?
    
    func otpVerificationDidSucceed() {
        otpVerificationDidSucceedCalled = true
    }
    
    func otpVerificationDidFail(with error: String) {
        otpVerificationDidFailCalled = true
        verificationError = error
    }
    
    func otpValidationDidFail(with error: String) {
        otpValidationDidFailCalled = true
        validationError = error
    }
    
    func otpResendDidSucceed() {
        otpResendDidSucceedCalled = true
    }
    
    func otpResendDidFail(with error: String) {
        otpResendDidFailCalled = true
        resendError = error
    }
}

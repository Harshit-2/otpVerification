//
//  OTPController.swift
//  Task
//
//  Created by Harshit ‎ on 5/22/25.
//

import UIKit

class OTPViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    
    @IBOutlet weak var otpStackView: UIStackView!
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var otpTextField5: UITextField!
    
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var timerLabel: UILabel!
    
    // MARK: - Properties
    
    var userId: String = ""
    var verificationCode: String = ""
    
    private var otpController: OTPControllerProtocol!
    private var otpTextFields: [UITextField] = []
    private var resendTimer: Timer?
    private var resendCountdown: Int = 60
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupUI()
        setupOTPTextFields()
        startResendTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        otpTextField1.becomeFirstResponder()
    }
    
    // MARK: - Setup Methods
    
    private func setupController() {
        otpController = OTPController()
        if let controller = otpController as? OTPController {
            controller.delegate = self
        }
    }
    
    private func setupUI() {
        // Configure navigation
        navigationItem.hidesBackButton = true
        
        // Configure title and subtitle
        titleLabel.text = "Verify Your Account"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        subtitleLabel.text = "Enter Verification Code"
        subtitleLabel.font = UIFont.systemFont(ofSize: 18)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        
        instructionLabel.text = "We've sent a 5-digit verification code to your email address"
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        instructionLabel.textColor = .tertiaryLabel
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        
        // Configure verify button
        verifyButton.setTitle("Verify", for: .normal)
        verifyButton.backgroundColor = UIColor.systemBlue
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 8
        verifyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Configure resend button
        resendButton.setTitle("Resend Code", for: .normal)
        resendButton.setTitleColor(UIColor.systemBlue, for: .normal)
        resendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        resendButton.isEnabled = false
        
        // Configure back button
        backButton.setTitle("← Back", for: .normal)
        backButton.setTitleColor(UIColor.systemBlue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        // Configure loading indicator
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        
        // Configure timer label
        timerLabel.font = UIFont.systemFont(ofSize: 14)
        timerLabel.textColor = .tertiaryLabel
        timerLabel.textAlignment = .center
    }
    
    private func setupOTPTextFields() {
        otpTextFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5]
        
        for (index, textField) in otpTextFields.enumerated() {
            textField.delegate = self
            textField.textAlignment = .center
            textField.font = UIFont.boldSystemFont(ofSize: 24)
            textField.keyboardType = .numberPad
            textField.layer.borderWidth = 2
            textField.layer.borderColor = UIColor.systemGray4.cgColor
            textField.layer.cornerRadius = 8
            textField.backgroundColor = UIColor.systemBackground
            textField.tag = index
            
            // Add target for text change
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Timer Methods
    
    private func startResendTimer() {
        resendCountdown = 60
        updateTimerLabel()
        resendButton.isEnabled = false
        
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateResendTimer()
        }
    }
    
    private func updateResendTimer() {
        resendCountdown -= 1
        updateTimerLabel()
        
        if resendCountdown <= 0 {
            stopResendTimer()
            resendButton.isEnabled = true
            timerLabel.text = ""
        }
    }
    
    private func stopResendTimer() {
        resendTimer?.invalidate()
        resendTimer = nil
    }
    
    private func updateTimerLabel() {
        timerLabel.text = "Resend code in \(resendCountdown)s"
    }
    
    // MARK: - Actions
    
    @IBAction func verifyButtonTapped(_ sender: UIButton) {
        let otp = getOTPFromTextFields()
        setLoading(true)
        otpController.verifyOTP(otp, userId: userId)
    }
    
    @IBAction func resendButtonTapped(_ sender: UIButton) {
        setLoading(true)
        otpController.resendOTP(userId: userId)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func getOTPFromTextFields() -> String {
        return otpTextFields.compactMap { $0.text }.joined()
    }
    
    private func setOTPToTextFields(_ otp: String) {
        let characters = Array(otp)
        for (index, textField) in otpTextFields.enumerated() {
            if index < characters.count {
                textField.text = String(characters[index])
            } else {
                textField.text = ""
            }
        }
    }
    
    private func clearOTPTextFields() {
        otpTextFields.forEach { $0.text = "" }
        otpTextField1.becomeFirstResponder()
    }
    
    private func setTextFieldActive(_ textField: UITextField) {
        // Reset all borders
        otpTextFields.forEach { tf in
            tf.layer.borderColor = UIColor.systemGray4.cgColor
        }
        
        // Highlight active field
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    private func setLoading(_ isLoading: Bool) {
        verifyButton.isEnabled = !isLoading
        resendButton.isEnabled = !isLoading && resendCountdown <= 0
        verifyButton.alpha = isLoading ? 0.6 : 1.0
        
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToWelcomeScreen() {
        // Navigate to main app or welcome screen
        // This would depend on your app's navigation structure
        let alert = UIAlertController(title: "Success!", message: "Your account has been verified successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            // Navigate to main app
            // For example:
            // self.navigationController?.setViewControllers([MainViewController()], animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        // Limit to single character
        if text.count > 1 {
            textField.text = String(text.first!)
        }
        
        // Move to next field if character entered
        if text.count == 1 {
            let nextTag = textField.tag + 1
            if nextTag < otpTextFields.count {
                otpTextFields[nextTag].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
                // Auto-verify if all fields are filled
                if getOTPFromTextFields().count == 5 {
                    verifyButtonTapped(verifyButton)
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Deinit
    
    deinit {
        stopResendTimer()
    }
}

// MARK: - UITextFieldDelegate

extension OTPViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTextFieldActive(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow digits
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        // Handle backspace
        if string.isEmpty {
            // Move to previous field if current is empty
            if textField.text?.isEmpty == true {
                let previousTag = textField.tag - 1
                if previousTag >= 0 {
                    otpTextFields[previousTag].becomeFirstResponder()
                }
            }
            return true
        }
        
        // Only allow single digit
        return allowedCharacters.isSuperset(of: characterSet) && string.count == 1
    }
}

// MARK: - OTPControllerDelegate

extension OTPViewController: OTPControllerDelegate {
    func otpVerificationDidSucceed() {
        setLoading(false)
        stopResendTimer()
        navigateToWelcomeScreen()
    }
    
    func otpVerificationDidFail(with error: String) {
        setLoading(false)
        showAlert(title: "Verification Failed", message: error)
        clearOTPTextFields()
    }
    
    func otpValidationDidFail(with error: String) {
        setLoading(false)
        showAlert(title: "Invalid OTP", message: error)
    }
    
    func otpResendDidSucceed() {
        setLoading(false)
        startResendTimer()
        showAlert(title: "Code Sent", message: "A new verification code has been sent to your email.")
        clearOTPTextFields()
    }
    
    func otpResendDidFail(with error: String) {
        setLoading(false)
        showAlert(title: "Resend Failed", message: error)
    }
}

//
//  RegistrationViewController.swift
//  Task
//
//  Created by Harshit ‎ on 5/22/25.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var showConfirmPasswordButton: UIButton!
    
    @IBOutlet weak var newsletterCheckbox: UIButton!
    @IBOutlet weak var newsletterLabel: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var registrationController: RegistrationControllerProtocol!
    private var formData = UserRegistrationData()
    private var isPasswordVisible = false
    private var isConfirmPasswordVisible = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupUI()
        setupTextFields()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup Methods
    
    private func setupController() {
        registrationController = RegistrationController()
        if let controller = registrationController as? RegistrationController {
            controller.delegate = self
        }
    }
    
    private func setupUI() {
        // Configure title and subtitle
        titleLabel.text = "Create Account"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = .label
        
        subtitleLabel.text = "Sign up to get started"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        
        // Configure register button
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = UIColor.systemBlue
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 8
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Configure login button
        loginButton.setTitle("Already have an account? Sign In", for: .normal)
        loginButton.setTitleColor(UIColor.systemBlue, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        // Configure newsletter checkbox
        updateNewsletterCheckbox()
        newsletterLabel.text = "Subscribe to newsletter"
        newsletterLabel.font = UIFont.systemFont(ofSize: 14)
        
        // Configure password visibility buttons
        showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        showConfirmPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        
        // Configure loading indicator
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
    }
    
    private func setupTextFields() {
        let textFields = [firstNameTextField, lastNameTextField, emailTextField,
                         phoneTextField, passwordTextField, confirmPasswordTextField]
        
        textFields.forEach { textField in
            textField?.borderStyle = .roundedRect
            textField?.font = UIFont.systemFont(ofSize: 16)
            textField?.delegate = self
        }
        
        // Configure placeholders
        firstNameTextField.placeholder = "First Name"
        lastNameTextField.placeholder = "Last Name"
        emailTextField.placeholder = "Email Address"
        phoneTextField.placeholder = "Phone Number"
        passwordTextField.placeholder = "Password"
        confirmPasswordTextField.placeholder = "Confirm Password"
        
        // Configure secure text entry
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        // Configure keyboard types
        emailTextField.keyboardType = .emailAddress
        phoneTextField.keyboardType = .phonePad
        
        // Configure autocorrection and capitalization
        firstNameTextField.autocapitalizationType = .words
        lastNameTextField.autocapitalizationType = .words
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        submitRegistration()
    }
    
    private func submitRegistration() {
        // Resign any active text field
        view.endEditing(true)

        // Mimic "Return" key behavior by navigating if fields are empty
        if firstNameTextField.text?.isEmpty == true {
            firstNameTextField.becomeFirstResponder()
            return
        } else if lastNameTextField.text?.isEmpty == true {
            lastNameTextField.becomeFirstResponder()
            return
        } else if emailTextField.text?.isEmpty == true {
            emailTextField.becomeFirstResponder()
            return
        } else if phoneTextField.text?.isEmpty == true {
            phoneTextField.becomeFirstResponder()
            return
        } else if passwordTextField.text?.isEmpty == true {
            passwordTextField.becomeFirstResponder()
            return
        } else if confirmPasswordTextField.text?.isEmpty == true {
            confirmPasswordTextField.becomeFirstResponder()
            return
        }

        // Now that all fields are filled, continue submission
        updateFormData()
        setLoading(true)
        registrationController.registerUser(with: formData)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Navigate to login screen
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showPasswordButtonTapped(_ sender: UIButton) {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        let imageName = isPasswordVisible ? "eye.slash" : "eye"
        showPasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func showConfirmPasswordButtonTapped(_ sender: UIButton) {
        isConfirmPasswordVisible.toggle()
        confirmPasswordTextField.isSecureTextEntry = !isConfirmPasswordVisible
        let imageName = isConfirmPasswordVisible ? "eye.slash" : "eye"
        showConfirmPasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func newsletterCheckboxTapped(_ sender: UIButton) {
        formData.newsletterSubscribed.toggle()
        updateNewsletterCheckbox()
    }
    
    // MARK: - Private Methods
    
    private func updateFormData() {
        formData.firstName = firstNameTextField.text ?? ""
        formData.lastName = lastNameTextField.text ?? ""
        formData.email = emailTextField.text ?? ""
        formData.phone = phoneTextField.text ?? ""
        formData.password = passwordTextField.text ?? ""
        formData.confirmPassword = confirmPasswordTextField.text ?? ""
    }
    
    private func updateNewsletterCheckbox() {
        let imageName = formData.newsletterSubscribed ? "checkmark.square.fill" : "square"
        newsletterCheckbox.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func setLoading(_ isLoading: Bool) {
        registerButton.isEnabled = !isLoading
        registerButton.alpha = isLoading ? 0.6 : 1.0
        
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
    
    private func navigateToOTPVerification(userId: String, verificationCode: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let otpVC = storyboard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController {
            otpVC.userId = userId
            otpVC.verificationCode = verificationCode
            navigationController?.pushViewController(otpVC, animated: true)
        }
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            phoneTextField.becomeFirstResponder()
        case phoneTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            submitRegistration()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - RegistrationControllerDelegate

extension RegistrationViewController: RegistrationControllerDelegate {
    func registrationDidSucceed(userId: String, verificationCode: String) {
        setLoading(false)
        navigateToOTPVerification(userId: userId, verificationCode: verificationCode)
    }
    
    func registrationDidFail(with error: String) {
        setLoading(false)
        showAlert(title: "Registration Failed", message: error)
    }
    
    func validationDidFail(with error: String) {
        setLoading(false)
        showAlert(title: "Validation Error", message: error)
    }
}

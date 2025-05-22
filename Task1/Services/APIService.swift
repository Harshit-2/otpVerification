//
//  APIServiceLayer.swift
//  Task
//
//  Created by Harshit ‎ on 5/22/25.
//

import Foundation
import UIKit

// MARK: - API Service Protocol

protocol APIServiceProtocol {
    func registerUser(_ request: RegistrationRequest, completion: @escaping (Result<RegistrationResponse, APIError>) -> Void)
    func verifyOTP(_ request: OTPRequest, completion: @escaping (Result<OTPResponse, APIError>) -> Void)
}

// MARK: - API Error

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

// MARK: - API Service Implementation

class APIService: APIServiceProtocol {
    static let shared = APIService()
    
    private let baseURL = "https://admin-cp.rimashaar.com/api/v1"
    private let session = URLSession.shared
    
    private init() {}
    
    func registerUser(_ request: RegistrationRequest, completion: @escaping (Result<RegistrationResponse, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/register-new?lang=en") else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url, body: request, responseType: RegistrationResponse.self, completion: completion)
    }
    
    func verifyOTP(_ request: OTPRequest, completion: @escaping (Result<OTPResponse, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/verify-code?lang=en") else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url, body: request, responseType: OTPResponse.self, completion: completion)
    }
    
    private func performRequest<T: Codable, R: Codable>(
        url: URL,
        body: T,
        responseType: R.Type,
        completion: @escaping (Result<R, APIError>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
            
            // Log request
            print("API Request URL: \(url)")
            print("API Request Body: \(String(data: jsonData, encoding: .utf8) ?? "Unable to print body")")
            
        } catch {
            completion(.failure(.decodingError(error)))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // Log full response body for debugging
                print("API Raw Response: \(String(data: data, encoding: .utf8) ?? "Unable to print response")")
                
                do {
                    let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        print("API Error Response: \(errorResponse.message)")
                        completion(.failure(.serverError(errorResponse.message)))
                    } else {
                        print("API Decoding Error: \(error.localizedDescription)")
                        completion(.failure(.decodingError(error)))
                    }
                }
            }
        }.resume()
    }
}


// MARK: - Generic Error Response

struct ErrorResponse: Codable {
    let success: Bool
    let message: String
}

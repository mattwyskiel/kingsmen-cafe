//
//  NetworkProvider.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 2/17/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

enum NetworkEnvironment {
    case dev
    case production
    case staging
}

final class NetworkProvider {

    static var environment: NetworkEnvironment {
        #if DEBUG
        #if targetEnvironment(simulator)
        // debugging on Simulator
        return .dev
        #else
        // testing on Device
        // use staging server
        return .staging
        #endif
        #else
        // production
        return .production
        #endif
    }

    private let router = Router<API>(debug: true)

    //var provider = MoyaProvider<API>(plugins: [NetworkLoggerPlugin(verbose: true)])

    typealias Result<T> = Swift.Result<T, NetworkError>

    func request<T: Codable>(_ target: API, _ completionHandler: @escaping (Result<T>) -> Void) {

        router.request(target) { (data, response, error) in
            DispatchQueue.main.async {
                if error != nil {
                    if error is EncodingError {
                        completionHandler(.failure(.encodingError(error! as! EncodingError)))
                    } else {
                        completionHandler(.failure(.urlSessionError(error!)))
                    }
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    completionHandler(.failure(.noResponse))
                    return
                }
                guard let data = data else {
                    completionHandler(.failure(.noData(response)))
                    return
                }

                do {
                    let filteredData = try self.filterNetworkResponse(response, data: data)

                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .custom(webServiceDateDecoder)
                    let model = try decoder.decode(T.self, from: filteredData)
                    completionHandler(.success(model))

                } catch let e as NetworkError {
                    completionHandler(.failure(e))
                } catch let e as DecodingError {
                    completionHandler(.failure(.decodingError(e)))
                } catch let e {
                    completionHandler(.failure(.otherError(e)))
                }
            }
        }
    }

    fileprivate func filterNetworkResponse(_ response: HTTPURLResponse, data: Data) throws -> Data {
        switch response.statusCode {
        case 200...399: return data
        case 400:
            do {
                let message = try JSONDecoder().decode(BackendMessage.self, from: data)
                throw NetworkError.badRequest(message)
            } catch let error as DecodingError {
                throw NetworkError.decodingError(error)
            }
        case 401:
            throw NetworkError.authenticationError
        case 500:
            do {
                let message = try JSONDecoder().decode(BackendMessage.self, from: data)
                throw NetworkError.serverError(message)
            } catch let error as DecodingError {
                throw NetworkError.decodingError(error)
            }
        default:
            throw NetworkError.unrecognizedServerResponse(response)
        }
    }

}

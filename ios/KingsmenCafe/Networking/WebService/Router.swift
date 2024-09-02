//
//  Router.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/5/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

class Router<Route: Requestable>: NetworkRouter {
    private var task: URLSessionTask?
    init(debug: Bool = false) {
        if debug {
            logger = NetworkLogger()
        } else {
            logger = nil
        }
    }

    var logger: NetworkLoggable?

    func request(_ route: Route, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        do {
            let request = try buildRequest(from: route)
            logger?.willBeginRequest(request)
            task = session.dataTask(with: request) { data, response, error in
                self.logger?.didReceiveResponse(data, response as? HTTPURLResponse, error)
                completion(data, response, error)
            }
        } catch {
            completion(nil, nil, error)
        }
        task?.resume()
    }

    fileprivate func buildRequest(from route: Route) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        request.httpMethod = route.httpMethod.rawValue

        do {
            switch route.task {
            case .plain:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case let .requestWithParameters(parameters):
                try configureParameters(parameters, for: &request)
            case let .requestWithData(data):
                addData(data, to: &request)
            }
            addAdditionalHeaders(route.headers, to: &request)
            return request
        } catch {
            throw error
        }
    }

    fileprivate func configureParameters(_ params: ParameterEncoding, for request: inout URLRequest) throws {
        do {
            switch params {
            case .json(let bodyParameters):
                try JSONParameterEncoder.encode(&request, with: bodyParameters)
            case .url(let urlParameters):
                try URLParameterEncoder.encode(&request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }

    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, to request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    fileprivate func addData(_ data: Data, to request: inout URLRequest) {
        request.httpBody = data
    }

    func cancel() {
        task?.cancel()
    }

}

//
//  NetworkService.swift
//  Chat
//
//  Created by Ujin on 8/1/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Moya
import ReactiveSwift
import class Alamofire.ServerTrustManager
import protocol Alamofire.ServerTrustEvaluating

final class Network: RequestRetrier {
    let reachability: ReachabilityManager
    var errors: Signal<DomainError, Never> {
        return errorsPipe.output
    }

    private let baseURL: URL
    private let session: Session
    private let plugins: [PluginType]
    private let authPlugin = AuthPlugin()
    private let errorsPipe = Signal<DomainError, Never>.pipe()
    
    // MARK: - Life cycle
    init(baseURL: URL) {
        let sessionConfiguration: () -> URLSessionConfiguration = {
            let config = URLSessionConfiguration.default
            return config
        }
        func createManager(withDisableEvaluation disableEvaluation: Bool = false) -> Session {
            let configuration = sessionConfiguration()
            configuration.timeoutIntervalForRequest = 30.0
            configuration.urlCache = URLCache(memoryCapacity: 100_000_000, diskCapacity: 300_000_000, diskPath: nil)
            return Session(configuration: configuration)
            
        }
        self.baseURL = baseURL
        self.session = createManager(withDisableEvaluation: true)
        self.plugins = [authPlugin, APIResponseErrorPlugin(), UploadTimeoutPlugin()]
        self.reachability = ReachabilityManager(host: baseURL.host)
    }
    
    // MARK: - Set providers
    func setAccessTokenProvider(_ accessTokenProvider: AccessTokenProvider) {
        authPlugin.accessTokenProvider = accessTokenProvider
    }
    
    func makeProvider<Target: RequestConvertible>() -> NetworkProvider<Target> {
        let provider = NetworkProvider<Target>(baseURL: baseURL,
                                               session: session,
                                               plugins: plugins,
                                               requestRetrier: self)
        return provider
    }
    
    // MARK: - Retry
    func should(retry request: RequestConvertible,
                with error: MoyaError,
                completion: @escaping (Bool, DispatchTimeInterval) -> Void) {
        let domainError = DomainError(error)
        errorsPipe.input.send(value: domainError)
        
        var shouldRefreshToken: Bool = false
        if error.response?.statusCode == 401 {
            shouldRefreshToken = true
        } else if case .underlying(let error, _) = error, let responseError = error as? APIResponseError {
            shouldRefreshToken = responseError.statusCode == 401 || responseError.errors.first?.statusCode == 400032
        }
        
        if shouldRefreshToken, let accessTokenProvider = authPlugin.accessTokenProvider {
            accessTokenProvider.refreshToken(else: error)
                .startWithResult { result in
                    switch result {
                    case .success:
                        completion(true, .seconds(0))
                    case .failure:
                        completion(false, .seconds(0))
                    }
            }
        } else {
            completion(false, .seconds(0))
        }
    }
}

    // MARK: - AuthPlugin
final class AuthPlugin: PluginType {
    fileprivate weak var accessTokenProvider: AccessTokenProvider?
    
    init(_ accessTokenProvider: AccessTokenProvider? = nil) {
        self.accessTokenProvider = accessTokenProvider
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let target = target as? RequestConvertible, target.needsAuthorization,
            let accessToken = accessTokenProvider?.accessToken.value?.tokenString else { return request }
        var updatedRequest = request
        updatedRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        return updatedRequest
    }
}

    // MARK: - APIResponseErrorPlugin
final class APIResponseErrorPlugin: PluginType {
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        guard case .success(let response) = result, 400 ..< 600 ~= response.statusCode else {
            return result
        }
        do {
            let responseError = try response.map(APIResponseError.self)
            let transformedError = transform(responseError, for: target)
            return .failure(MoyaError.underlying(transformedError, nil))
        } catch let error {
            return .failure(MoyaError.underlying(error, response))
        }
    }
    
    func transform(_ error: APIResponseError, for target: TargetType) -> Error {
        return error
    }
}

    // MARK: - UploadTimeoutPlugin
final class UploadTimeoutPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        switch target.task {
        case .uploadFile, .uploadMultipart, .uploadCompositeMultipart:
            var newRequest = request
            newRequest.timeoutInterval = 60 * 10
            return newRequest
        default:
            return request
        }
    }
}

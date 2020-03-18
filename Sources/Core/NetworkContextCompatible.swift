//
//  NetworkContextCompatible.swift
//  RxNetwork
//
//  Created by Apple on 2019/10/11.
//  Copyright © 2019 ZJaDe. All rights reserved.
//

import Foundation
import Alamofire

public typealias RNDataResponse<V> = AFDataResponse<V>
public typealias RNDownloadResponse<V> = AFDownloadResponse<V>

public protocol RNResponseCompatible {
    associatedtype Success
    associatedtype Failure: Error
    var request: URLRequest? {get}
    var response: HTTPURLResponse? {get}
    var metrics: URLSessionTaskMetrics? {get}
    var serializationDuration: TimeInterval {get}
    var result: Swift.Result<Success, Failure> {get}
}
extension DataResponse: RNResponseCompatible {
    //    var data: Data? {get}
}
extension RNDownloadResponse: RNResponseCompatible {
    //    public let fileURL: URL?
    //    public let resumeData: Data?
}

extension Result where Failure == NetworkError {
    func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Failure> {
        switch self {
        case let .success(value):
            do {
                return try .success(transform(value))
            } catch {
                return .failure(NetworkError.unknown(error))
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}

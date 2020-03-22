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
public protocol RNDataResponseCompatible: RNResponseCompatible {
    var data: Data? {get}
    func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> DataResponse<NewSuccess, Failure>
    func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> DataResponse<NewSuccess, Error>
    func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> DataResponse<Success, NewFailure>
    func tryMapError<NewFailure: Error>(_ transform: (Failure) throws -> NewFailure) -> DataResponse<Success, Error>
}
public protocol RNDownloadResponseCompatible: RNResponseCompatible {
    var fileURL: URL? {get}
    var resumeData: Data? {get}
    func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> DownloadResponse<NewSuccess, Failure>
    func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> DownloadResponse<NewSuccess, Error>
    func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> DownloadResponse<Success, NewFailure>
    func tryMapError<NewFailure: Error>(_ transform: (Failure) throws -> NewFailure) -> DownloadResponse<Success, Error>
}
extension DataResponse: RNDataResponseCompatible {}
extension DownloadResponse: RNDownloadResponseCompatible {}

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

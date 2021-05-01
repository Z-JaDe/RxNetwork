//
//  Request.swift
//  AppExtension
//
//  Created by ZJaDe on 2019/1/3.
//  Copyright © 2019 ZJaDe. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

// MARK: - Response
extension Request: ReactiveCompatible {}
extension Reactive where Base: DataRequest {
    public func response(queue: DispatchQueue = .main) -> Single<RNDataResponse<Data?>> {
        Single.create { observer in
            self.base.response(queue: queue, completionHandler: { (response) in
                observer(.success(response))
            })
            return Disposables.create()
        }
    }
    public func response<T: DataResponseSerializerProtocol>(queue: DispatchQueue = .main, responseSerializer: T) -> Single<RNDataResponse<T.SerializedObject>> {
        Single.create { observer in
            self.base.response(queue: queue, responseSerializer: responseSerializer, completionHandler: { (response) in
                observer(.success(response))
            })
            return Disposables.create()
        }
    }
}
extension Reactive where Base: DownloadRequest {
    public func response(queue: DispatchQueue = .main) -> Single<RNDownloadResponse<URL?>> {
        Single.create { observer in
            self.base.response(queue: queue, completionHandler: { (response) in
                observer(.success(response))
            })
            return Disposables.create()
        }
    }
    public func response<T: DownloadResponseSerializerProtocol>(queue: DispatchQueue = .main, responseSerializer: T) -> Single<RNDownloadResponse<T.SerializedObject>> {
        Single.create { observer in
            self.base.response(queue: queue, responseSerializer: responseSerializer, completionHandler: { (response) in
                observer(.success(response))
            })
            return Disposables.create()
        }
    }
    public func cancel() -> Single<Data?> {
        Single.create { observer in
            self.base.cancel { (resumeData) in
                observer(.success(resumeData))
            }
            return Disposables.create()
        }
    }
}
// MARK: - Response
extension ObservableType where Element: Request {
    private func flatMapNetwork<Source: ObservableConvertibleType>(_ selector: @escaping (Element) -> Source)
        -> Single<Source.Element> {
            flatMapLatest(selector).take(1).asSingle()
    }
}
extension ObservableType where Element: DataRequest {
    public func response(queue: DispatchQueue = .main) -> Single<RNDataResponse<Data?>> {
        flatMapNetwork { $0.rx.response(queue: queue) }
    }
    public func response<T: DataResponseSerializerProtocol>(queue: DispatchQueue = .main, responseSerializer: T) -> Single<RNDataResponse<T.SerializedObject>> {
        flatMapNetwork { $0.rx.response(queue: queue, responseSerializer: responseSerializer) }
    }
}
extension ObservableType where Element: DownloadRequest {
    public func response(queue: DispatchQueue = .main) -> Single<RNDownloadResponse<URL?>> {
        flatMapNetwork { $0.rx.response(queue: queue) }
    }
    public func response<T: DownloadResponseSerializerProtocol>(queue: DispatchQueue = .main, responseSerializer: T) -> Single<RNDownloadResponse<T.SerializedObject>> {
        flatMapNetwork { $0.rx.response(queue: queue, responseSerializer: responseSerializer) }
    }
    public func cancel() -> Single<Data?> {
        flatMapNetwork { $0.rx.cancel() }
    }
}
// MARK: - ResponseMap
let dataResponseSerializer = DataResponseSerializer()

extension Reactive where Base: DataRequest {
    public func responseMap<T: Decodable>(type: T.Type, atKeyPath keyPath: String? = nil) -> Single<RNDataResponse<T>> {
        response(queue: .main, responseSerializer: KeyPathDecodableResponseSerializer<T>(atKeyPath: keyPath))
    }
    public func responseData(queue: DispatchQueue = .main) -> Single<RNDataResponse<Data>> {
        response(queue: queue, responseSerializer: dataResponseSerializer)
    }
}
extension Reactive where Base: DownloadRequest {
    public func responseMap<T: Decodable>(type: T.Type, atKeyPath keyPath: String? = nil) -> Single<RNDownloadResponse<T>> {
        response(queue: .main, responseSerializer: KeyPathDecodableResponseSerializer<T>(atKeyPath: keyPath))
    }
    public func responseData(queue: DispatchQueue = .main) -> Single<RNDownloadResponse<Data>> {
        response(queue: queue, responseSerializer: dataResponseSerializer)
    }
}
extension ObservableType where Element: DataRequest {
    public func responseMap<T: Decodable>(type: T.Type, atKeyPath keyPath: String? = nil) -> Single<RNDataResponse<T>> {
        response(queue: .main, responseSerializer: KeyPathDecodableResponseSerializer<T>(atKeyPath: keyPath))
    }
    public func responseData(queue: DispatchQueue = .main) -> Single<RNDataResponse<Data>> {
        response(queue: queue, responseSerializer: dataResponseSerializer)
    }
}
extension ObservableType where Element: DownloadRequest {
    public func responseMap<T: Decodable>(type: T.Type, atKeyPath keyPath: String? = nil) -> Single<RNDownloadResponse<T>> {
        response(queue: .main, responseSerializer: KeyPathDecodableResponseSerializer<T>(atKeyPath: keyPath))
    }
    public func responseData(queue: DispatchQueue = .main) -> Single<RNDownloadResponse<Data>> {
        response(queue: queue, responseSerializer: dataResponseSerializer)
    }
}

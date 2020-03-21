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
    public func response(queue: DispatchQueue = .main) -> Observable<RNDataResponse<Data?>> {
        Observable.create { observer in
            self.base.response(queue: queue, completionHandler: { (response) in
                observer.onNext(response)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    public func response<T: DataResponseSerializerProtocol>(queue: DispatchQueue = .main, responseSerializer: T) -> Observable<RNDataResponse<T.SerializedObject>> {
        Observable.create { observer in
            self.base.response(queue: queue, responseSerializer: responseSerializer, completionHandler: { (response) in
                observer.onNext(response)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
}
extension Reactive where Base: DownloadRequest {
    public func response(queue: DispatchQueue = .main) -> Observable<RNDownloadResponse<URL?>> {
        Observable.create { observer in
            self.base.response(queue: queue, completionHandler: { (response) in
                observer.onNext(response)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    public func response<T: DownloadResponseSerializerProtocol>(queue: DispatchQueue = .main, responseSerializer: T) -> Observable<RNDownloadResponse<T.SerializedObject>> {
        Observable.create { observer in
            self.base.response(queue: queue, responseSerializer: responseSerializer, completionHandler: { (response) in
                observer.onNext(response)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    public func cancel() -> Observable<Data?> {
        Observable.create { observer in
            self.base.cancel { (resumeData) in
                observer.onNext(resumeData)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
// MARK: - Response
extension ObservableType where Element: Request {
    @inline(__always)
    private func flatMapNetwork<Source: ObservableConvertibleType>(_ selector: @escaping (Element) -> Source)
        -> Observable<Source.Element> {
            flatMapLatest(selector).take(1)
    }
}
extension ObservableType where Element: DataRequest {
    public func response(queue: DispatchQueue = .main) -> Observable<RNDataResponse<Data?>> {
        flatMapNetwork { $0.rx.response(queue: queue) }
    }
    public func response<T: DataResponseSerializerProtocol>(queue: DispatchQueue = .main, responseSerializer: T) -> Observable<RNDataResponse<T.SerializedObject>> {
        flatMapNetwork { $0.rx.response(queue: queue, responseSerializer: responseSerializer) }
    }
}
extension ObservableType where Element: DownloadRequest {
    public func response(queue: DispatchQueue = .main) -> Observable<RNDownloadResponse<URL?>> {
        flatMapNetwork { $0.rx.response(queue: queue) }
    }
    public func response<T: DownloadResponseSerializerProtocol>(queue: DispatchQueue = .main, responseSerializer: T) -> Observable<RNDownloadResponse<T.SerializedObject>> {
        flatMapNetwork { $0.rx.response(queue: queue, responseSerializer: responseSerializer) }
    }
    public func cancel() -> Observable<Data?> {
        flatMapNetwork { $0.rx.cancel() }
    }
}
// MARK: - ResponseMap
let dataResponseSerializer = DataResponseSerializer()

extension Reactive where Base: DataRequest {
    @inline(__always)
    public func responseMap<T: Decodable>(type: T.Type, atKeyPath keyPath: String? = nil) -> Observable<RNDataResponse<T>> {
        response(queue: .main, responseSerializer: KeyPathDecodableResponseSerializer<T>(atKeyPath: keyPath))
    }
    @inline(__always)
    public func responseData(queue: DispatchQueue = .main) -> Observable<RNDataResponse<Data>> {
        response(queue: queue, responseSerializer: dataResponseSerializer)
    }
}
extension Reactive where Base: DownloadRequest {
    @inline(__always)
    public func responseMap<T: Decodable>(type: T.Type, atKeyPath keyPath: String? = nil) -> Observable<RNDownloadResponse<T>> {
        response(queue: .main, responseSerializer: KeyPathDecodableResponseSerializer<T>(atKeyPath: keyPath))
    }
    @inline(__always)
    public func responseData(queue: DispatchQueue = .main) -> Observable<RNDownloadResponse<Data>> {
        response(queue: queue, responseSerializer: dataResponseSerializer)
    }
}
extension ObservableType where Element: DataRequest {
    @inline(__always)
    public func responseMap<T: Decodable>(type: T.Type, atKeyPath keyPath: String? = nil) -> Observable<RNDataResponse<T>> {
        response(queue: .main, responseSerializer: KeyPathDecodableResponseSerializer<T>(atKeyPath: keyPath))
    }
    @inline(__always)
    public func responseData(queue: DispatchQueue = .main) -> Observable<RNDataResponse<Data>> {
        response(queue: queue, responseSerializer: dataResponseSerializer)
    }
}
extension ObservableType where Element: DownloadRequest {
    @inline(__always)
    public func responseMap<T: Decodable>(type: T.Type, atKeyPath keyPath: String? = nil) -> Observable<RNDownloadResponse<T>> {
        response(queue: .main, responseSerializer: KeyPathDecodableResponseSerializer<T>(atKeyPath: keyPath))
    }
    @inline(__always)
    public func responseData(queue: DispatchQueue = .main) -> Observable<RNDownloadResponse<Data>> {
        response(queue: queue, responseSerializer: dataResponseSerializer)
    }
}

//
//  RxProgress.swift
//  AppExtension
//
//  Created by ZJaDe on 2019/1/3.
//  Copyright © 2019 ZJaDe. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
extension ObservableType where Element: Request {
    public func redirect(using handler: RedirectHandler) -> Observable<Element> {
        map { $0.redirect(using: handler) }
    }
    public func cacheResponse(using handler: CachedResponseHandler) -> Observable<Element> {
        map { $0.cacheResponse(using: handler) }
    }
    public func uploadProgress(queue: DispatchQueue = .main, closure: @escaping Element.ProgressHandler) -> Observable<Element> {
        map { $0.uploadProgress(queue: queue, closure: closure) }
    }
    public func downloadProgress(queue: DispatchQueue = .main, closure: @escaping Element.ProgressHandler) -> Observable<Element> {
        map { $0.downloadProgress(queue: queue, closure: closure) }
    }
}

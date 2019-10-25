//
//  TargetType.swift
//  AppExtension
//
//  Created by ZJaDe on 2019/1/3.
//  Copyright © 2019 ZJaDe. All rights reserved.
//

import Foundation
import Alamofire

public protocol TargetType: URLRequestConvertible {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get set }

    var encoding: ParameterEncoding { get }
}
extension TargetType {
    func _asURL() -> URL {
        let url: URL
        if let target = self as? URLConvertible, let _url = try? target.asURL() {
            url = _url
        } else {
            url = self.baseURL.appendingPathComponent(self.path)
        }
//        logInfo("请求地址: \(url)")
        return url
    }
    public func asURLRequest() throws -> URLRequest {
        let url = self._asURL()
        var urlRequest: URLRequest
        urlRequest = try URLRequest(url: url, method: self.method, headers: self.headers)
        urlRequest = try self.encoding.encode(urlRequest, with: self.parameters)
        return urlRequest
    }
}

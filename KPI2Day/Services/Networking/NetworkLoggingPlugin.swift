//
//  NetworkLoggingPlugin.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 07.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
// 

import Foundation
import Result
import Moya

/// Logs network activity (outgoing requests and incoming responses).
public final class NetworkLoggingPlugin: PluginType {
    fileprivate let separator = ", "
    fileprivate let terminator = "\n"
    fileprivate let cURLTerminator = "\\\n"
    fileprivate let output: (_ separator: String, _ terminator: String, _ items: Any...) -> Void
    fileprivate let requestDataFormatter: ((Data) -> (String))?
    fileprivate let responseDataFormatter: ((Data) -> (Data))?
    
    /// If true, also logs response body data.
    public let isVerbose: Bool
    public let cURL: Bool
    
    public init(verbose: Bool = false, cURL: Bool = false, output: ((_ separator: String, _ terminator: String, _ items: Any...) -> Void)? = nil, requestDataFormatter: ((Data) -> (String))? = nil, responseDataFormatter: ((Data) -> (Data))? = nil) {
        self.cURL = cURL
        self.isVerbose = verbose
        self.output = output ?? NetworkLoggingPlugin.reversedPrint
        self.requestDataFormatter = requestDataFormatter
        self.responseDataFormatter = responseDataFormatter
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        
        if let request = request as? CustomDebugStringConvertible, cURL {
            output(separator, terminator, request.debugDescription)
            return
        }
        outputItems(logNetworkRequest(request.request as URLRequest?))
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            outputItems(logNetworkResponse(response.response, data: response.data, target: target))
        } else {
            outputItems(logNetworkResponse(nil, data: nil, target: target))
        }
    }
    
    fileprivate func outputItems(_ items: String) {
        //        if isVerbose {
        //             output(separator, terminator, $0)
        //        } else {
        output(separator, terminator, items)
        //        }
    }
}

private extension NetworkLoggingPlugin {
    
    
    func format(identifier: String, message: String) -> String {
        return "\(identifier): \(message) \n"
    }
    
    func logNetworkRequest(_ request: URLRequest?) -> String {
        
        var output = ""
        
        if let httpMethod = request?.httpMethod {
            output += format(identifier: "HTTP Request Method", message: httpMethod)
        }
        
        output += format(identifier: "Request", message: request?.description ?? "(invalid request)")
        
        if let headers = request?.allHTTPHeaderFields {
            output += format(identifier: "Request Headers", message: headers.description)
        }
        
        if let bodyStream = request?.httpBodyStream {
            output += format(identifier: "Request Body Stream", message: bodyStream.description)
        }
        
        if let body = request?.httpBody, let stringOutput = requestDataFormatter?(body) ?? String(data: body, encoding: .utf8), isVerbose {
            output += format(identifier: "Request Body", message: stringOutput)
        }
        
        return output
    }
    
    func logNetworkResponse(_ response: HTTPURLResponse?, data: Data?, target: TargetType) -> String {
        guard let response = response else {
            return format(identifier: "Response", message: "⚠️ Received empty network response for \(target).")
        }
        
        var output = ""
        if 200..<400 ~= (response.statusCode) {
            output += "✅"
        } else {
            output += "🛑"
        }
        output += format(identifier: "Response", message: "Status Code: \(response.statusCode)  URL:\(response.url?.absoluteString ?? "")")
        
        if let data = data, let stringData = String(data: responseDataFormatter?(data) ?? data, encoding: String.Encoding.utf8), isVerbose {
            output += stringData
            output += "\n"
        }
        
        return output
    }
}

fileprivate extension NetworkLoggingPlugin {
    static func reversedPrint(_ separator: String, terminator: String, items: Any...) {
        for item in items {
            print(item, separator: separator, terminator: terminator)
        }
    }
}

func JSONResponseDataFormatter(data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data, options: [])
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}

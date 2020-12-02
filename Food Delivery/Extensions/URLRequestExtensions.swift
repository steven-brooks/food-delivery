//
//  URLRequestExtensions.swift
//  Food Delivery
//
//  Created by Steven Brooks on 11/30/20.
//

import Foundation

extension URLRequest {
	@discardableResult public mutating func authenticate(token: String) -> Self {
		guard var urlString = url?.absoluteString else { return self }
		
		if urlString.contains("?") {
			urlString += "&auth=\(token)"
		} else {
			urlString += "?auth=\(token)"
		}
		
		url = URL(string: urlString)
		
		return self
	}
}

extension URLComponents {
	@discardableResult public mutating func authenticate(token: String) -> Self {
		queryItems?.append(URLQueryItem(name: "auth", value: token))
		return self
	}
}

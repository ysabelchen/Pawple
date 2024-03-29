/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
import Foundation

class TokenManager {
    let userAccount = "accessToken"
    let expiryDate = "expiryDate"
    static let shared = TokenManager()

    let secureStore: SecureStore = {
        let accessTokenQueryable = GenericPasswordQueryable(service: "GitHubService")
        return SecureStore(secureStoreQueryable: accessTokenQueryable)
    }()

    func saveAccessToken(gitToken: GitHubAccessToken) {
        do {
            try secureStore.setValue(gitToken.accessToken, for: userAccount)
        } catch let exception {
            print("Error saving access token: \(exception)")
        }
    }

    func fetchAccessToken(completion: @escaping (String?) -> Void) {
        do {
            if (isTokenNotExpired) {
                let token = try secureStore.getValue(for: userAccount)
                completion(token)
            } else {
                APIServiceManager.shared.fetchAccessToken { (_, token) in
                    completion(token)
                }
            }
        } catch let exception {
            print("Error fetching access token: \(exception)")
        }
        completion(nil)
    }

    var isTokenNotExpired: Bool {
        let tokenExpirationTimestamp: String = TokenManager.shared.fetchTokenExpiration() ?? "0"
        if let doubleValue = Double(tokenExpirationTimestamp) {
            if doubleValue > Date.init().timeIntervalSince1970 {
                return true
            }
        }
        return false
    }

    func clearAccessToken() {
        do {
            return try secureStore.removeValue(for: userAccount)
        } catch let exception {
            print("Error clearing access token: \(exception)")
        }
    }

    func saveTokenExpiration(gitToken: GitHubAccessToken) {
        do {
            let expiresIn = Date.init(timeIntervalSinceNow: TimeInterval(gitToken.expiresIn)).timeIntervalSince1970
            try secureStore.setValue("\(expiresIn)", for: expiryDate)
        } catch let exception {
            print("Error saving access token: \(exception)")
        }
    }

    func fetchTokenExpiration() -> String? {
        do {
            return try secureStore.getValue(for: expiryDate)
        } catch let exception {
            print("Error fetching token expiry date: \(exception)")
        }
        return nil
    }
}

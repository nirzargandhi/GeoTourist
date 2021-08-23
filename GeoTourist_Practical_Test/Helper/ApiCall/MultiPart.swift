//
//  MultiPart.swift
//  MultiPartSwift
//
//  Created by Nirzar on 13/02/18.
//  Copyright © 2018 Nirzar. All rights reserved.
//

let multiPartFieldName = "fieldName"
let multiPartPathURLs = "pathURL"

class MultiPart: NSObject {
    
    var session: URLSession?
    
    func callPostWebService<T : Decodable>(_ apiUrl: String, parameters: [String: Any]?, filePathArr arrFilePath: [[String:Any]]?, model : T.Type, isLoader : Bool = true, isErrorToast : Bool = true, isAPIToken : Bool = false, completion: @escaping (_ success: Bool, _ object: AnyObject?)->()) {
        
        if isLoader {
            Utility().showLoader()
        }
        
        let boundary = generateBoundaryString()
        
        let request = NSMutableURLRequest(url: URL(string: apiUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        
        request.httpMethod = "POST"
        
        if isAPIToken, let strToken : String = KeychainWrapper.standard.string(forKey: UserDefault.kAPIToken) {
            request.addValue("Bearer " + strToken, forHTTPHeaderField: "Authorization")
        }
        
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let httpBody: Data? = createBody(withBoundary: boundary, parameters: parameters, paths: arrFilePath)
        session = URLSession.shared
        
        request.setValue("\(httpBody!.count)", forHTTPHeaderField:"Content-Length")
        
        let task = session?.uploadTask(with: request as URLRequest, from: httpBody, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            
            Utility().hideLoader()
            
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(convertedJsonIntoDict)
                }
                
                let dictResponse = try decoder.decode(GeneralResponseModal.self, from: data)
                
                let code = dictResponse.success ?? 0
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 && (dictResponse.message?.lowercased().contains("unauthorized") ?? false) {
                    mainThread {
                        logOutMethod()
                    }
                } else if code == 1 {
                    let dictResponsee = try decoder.decode(model, from: data)
                    mainThread {
                        completion(true, dictResponsee as AnyObject)
                    }
                } else if code == 401 {
                    mainThread {
                        logOutMethod()
                    }
                } else {
                    mainThread {
                        completion(false, dictResponse.message as AnyObject)
                    }
                }
                
            } catch let error as NSError {
                print("\n\n===========Error===========")
                print("Error Code: \(error._code)")
                print("Error Messsage: \(error.localizedDescription)")
                if let str = String(data: data, encoding: String.Encoding.utf8){
                    print("Print Server data:- " + str)
                }
                debugPrint(error)
                print("===========================\n\n")
                
                debugPrint(error)
                completion(false, error as AnyObject)
            }
            
        })
        task?.resume()
    }
    
    func createBody(withBoundary boundary: String, parameters: [String: Any]?, paths: [[String:Any]]?) -> Data {
        var httpBody = Data()
        
        if let parameters = parameters {
            for (parameterKey, parameterValue) in parameters {
                httpBody.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                httpBody.append("Content-Disposition: form-data; name=\"\(parameterKey)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                httpBody.append("\(parameterValue)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        if let paths = paths {
            
            for pathDic in paths {
                for path: String in pathDic[multiPartPathURLs] as! [String] {
                    let filename: String = URL(fileURLWithPath: path).lastPathComponent
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: path))
                        
                        let mimetype: String = mimeType(forPath: path)
                        httpBody.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                        httpBody.append("Content-Disposition: form-data; name=\"\(pathDic[multiPartFieldName] ?? "")\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
                        httpBody.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
                        httpBody.append(data)
                        httpBody.append("\r\n".data(using: String.Encoding.utf8)!)
                    } catch {
                        print("Unable to load data: \(error)")
                    }
                }
            }
        }
        httpBody.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        return httpBody
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    func mimeType(forPath path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}

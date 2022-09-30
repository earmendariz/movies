import Foundation
import UIKit

public class ApiRest{
    public static func call(request:String, method:String, parameters:[String:AnyHashable]?? = nil){
        let url = URL(string: Config.url_api_rest + request+"?api_key="+Config.themoviedb_api_key)!
                let session = URLSession.shared
                var request = URLRequest(url: url)
                request.httpMethod = method
                if(parameters != nil){
                    do {
                        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    guard error == nil else {return}
                    guard let data = data else {return}
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            print(json)
                            let defaults = UserDefaults.standard
                            defaults.setValue(json["request_token"], forKey: "request_token")
                            defaults.setValue(json["expires_at"], forKey: "expires_at")
                            }
                        } catch let error {
                        print(error.localizedDescription)
                                          }
                })
                task.resume()

    }
}

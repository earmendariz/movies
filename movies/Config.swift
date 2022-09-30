import Foundation

public class Config{
    public static let themoviedb_api_key = "192d0f27ea617539f835f853bf02667f"
    public static let url_api_rest = "https://api.themoviedb.org/3/"
    
    public static func getToken(){
        let url = URL(string: Config.url_api_rest + "authentication/token/new?api_key="+Config.themoviedb_api_key)!
                let session = URLSession.shared
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
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

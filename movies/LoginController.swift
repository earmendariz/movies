import UIKit

class LoginController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblError: UITextView!
    var success:Bool = false
    var response_json: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        if let username = defaults.string(forKey: "username"){
            txtUsername.text = defaults.string(forKey: "username")
            txtPassword.text = defaults.string(forKey: "password")
        }
        if let request_token = defaults.string(forKey: "request_token"){
            var expires_at = defaults.string(forKey: "expires_at")!
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ssZ"
            var date = dateFormatter.date(from:expires_at)!
            if(date < Date()){
                getToken()
            }
        } else {
            getToken()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func btnActionLogin(_ sender: Any) {
        self.lblError.text = ""
        let username:String = txtUsername.text!
        let password:String = txtPassword.text!
        if(username.isEmpty || password.isEmpty){
            showAlertOK(title: "Log In", message: "Username and Password requiered")
        } else {
            let loader = self.loader(message: "Loading...")
            let login = PostForLogIn()
            let defaults = UserDefaults.standard
            if let request_token = defaults.string(forKey: "request_token"){
                login.performRequest(loader:loader, username: username, password: password, request_token: request_token, completion:{data, error in
                    guard let data = data, error == nil else {
                        print(error ?? "Unknown error")
                        return
                    }
                    self.stopLoader(loader: loader)
                    DispatchQueue.main.async {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                //print(json)
                                if(json["success"] as! Int == 1){
                                    defaults.setValue(username, forKey: "username")
                                    defaults.setValue(password, forKey: "password")
                                    self.dismiss(animated: true, completion: { () -> Void in
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let vcMovies = storyboard.instantiateViewController(withIdentifier: "MoviesController") as! MoviesController
                                        vcMovies.modalPresentationStyle = .fullScreen
                                        self.present(vcMovies, animated: true, completion: nil)
                                       })
                                } else {
                                    self.lblError.text = json["status_message"] as! String
                                }
                                
                            }
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                })
            }
        }
    }
    
    func getToken(){
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

class PostForLogIn: UIAlertController {
    func performRequest(loader:UIAlertController, username:String, password:String, request_token:String, completion: @escaping (Data?, Error?) -> Void) {
        let parameters = ["username":username,"password":password,"request_token":request_token]
        let url = URL(string: Config.url_api_rest + "authentication/token/validate_with_login?api_key="+Config.themoviedb_api_key)!
        let session = Foundation.URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
}

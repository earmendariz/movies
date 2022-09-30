import Foundation
import UIKit


extension UIViewController{
    
    func showAlertOK(title:String ,message:String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
        return alert
    }
    
    func loader(message:String) -> UIAlertController{
        let alert = UIAlertController(title: nil, message:message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x:10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        return alert
    }
    
    func stopLoader(loader: UIAlertController){
        DispatchQueue.main.async {
            loader.dismiss(animated: true, completion: nil)
        }
    }
}

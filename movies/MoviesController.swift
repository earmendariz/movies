import UIKit

class MoviesController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    @IBOutlet weak var gridMoviesCollection: UICollectionView!
    
    private var ar_movies:Array<Results>? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getMovies(category: "popular")
    }
    
    private func setUpCollectionView() {
        gridMoviesCollection
                .register(UICollectionViewCell.self,
                 forCellWithReuseIdentifier: "itemMovie")
        gridMoviesCollection.delegate = self
        gridMoviesCollection.dataSource = self
         let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .vertical
         layout.minimumLineSpacing = 8
         layout.minimumInteritemSpacing = 4
        gridMoviesCollection
               .setCollectionViewLayout(layout, animated: true)
       }


    
    func getMovies(category:String){
        let loader = self.loader(message: "Loading...")
        let getmovies = GetForMovies()
        let defaults = UserDefaults.standard
        if let request_token = defaults.string(forKey: "request_token"){
            getmovies.performRequest(category:category, request_token: request_token, completion:{data, error in
                guard let data = data, error == nil else {
                    print(error ?? "Unknown error")
                    return
                }
                self.stopLoader(loader: loader)
                DispatchQueue.main.async {
                    do {
                        let decoder = JSONDecoder()
                        let objectList = try decoder.decode(Movies_Base.self, from: data)
                        self.ar_movies = objectList.results
                        self.gridMoviesCollection.reloadData()
                        
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            })
        }
    }
    
    @IBAction func btnActionNavBar(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let profileAction = UIAlertAction(title: "View Profile", style: .default) { (action) in
            
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vcProfile = storyboard.instantiateViewController(withIdentifier: "ProfileController") as! ProfileController
                vcProfile.modalPresentationStyle = .fullScreen
                self.present(vcProfile, animated: true, completion: nil)
              
        }
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
            
            let url = URL(string: Config.url_api_rest + "authentication/session?api_key="+Config.themoviedb_api_key)!
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil else {return}
                guard let data = data else {return}
                let domain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
            })
            task.resume()
            
            
            self.dismiss(animated: true, completion: { () -> Void in
                exit(-1)
            })
            
            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel")
        }
        actionSheet.addAction(profileAction)
        actionSheet.addAction(logoutAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ar_movies!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as? MovieCollectionViewCell {
            cell.lblTitle.text = ar_movies![indexPath.row].title
        }
        return UICollectionViewCell()
    }
    
    struct Movies_Base : Codable {
        let page : Int?
        let results : [Results]?
        let total_pages : Int?
        let total_results : Int?

        enum CodingKeys: String, CodingKey {

            case page = "page"
            case results = "results"
            case total_pages = "total_pages"
            case total_results = "total_results"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            page = try values.decodeIfPresent(Int.self, forKey: .page)
            results = try values.decodeIfPresent([Results].self, forKey: .results)
            total_pages = try values.decodeIfPresent(Int.self, forKey: .total_pages)
            total_results = try values.decodeIfPresent(Int.self, forKey: .total_results)
        }

    }
    
    struct Results : Codable {
        let adult : Bool?
        let backdrop_path : String?
        let genre_ids : [Int]?
        let id : Int?
        let original_language : String?
        let original_title : String?
        let overview : String?
        let popularity : Double?
        let poster_path : String?
        let release_date : String?
        let title : String?
        let video : Bool?
        let vote_average : Double?
        let vote_count : Int?

        enum CodingKeys: String, CodingKey {

            case adult = "adult"
            case backdrop_path = "backdrop_path"
            case genre_ids = "genre_ids"
            case id = "id"
            case original_language = "original_language"
            case original_title = "original_title"
            case overview = "overview"
            case popularity = "popularity"
            case poster_path = "poster_path"
            case release_date = "release_date"
            case title = "title"
            case video = "video"
            case vote_average = "vote_average"
            case vote_count = "vote_count"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            adult = try values.decodeIfPresent(Bool.self, forKey: .adult)
            backdrop_path = try values.decodeIfPresent(String.self, forKey: .backdrop_path)
            genre_ids = try values.decodeIfPresent([Int].self, forKey: .genre_ids)
            id = try values.decodeIfPresent(Int.self, forKey: .id)
            original_language = try values.decodeIfPresent(String.self, forKey: .original_language)
            original_title = try values.decodeIfPresent(String.self, forKey: .original_title)
            overview = try values.decodeIfPresent(String.self, forKey: .overview)
            popularity = try values.decodeIfPresent(Double.self, forKey: .popularity)
            poster_path = try values.decodeIfPresent(String.self, forKey: .poster_path)
            release_date = try values.decodeIfPresent(String.self, forKey: .release_date)
            title = try values.decodeIfPresent(String.self, forKey: .title)
            video = try values.decodeIfPresent(Bool.self, forKey: .video)
            vote_average = try values.decodeIfPresent(Double.self, forKey: .vote_average)
            vote_count = try values.decodeIfPresent(Int.self, forKey: .vote_count)
        }

    }

}

class GetForMovies: UIAlertController {
    func performRequest(category:String, request_token:String, completion: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: Config.url_api_rest + "movie/"+category+"?api_key="+Config.themoviedb_api_key)!
        let session = Foundation.URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            completion(data, nil)
            print(data)
        }
        task.resume()
    }
}

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblDescription: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

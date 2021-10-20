//  Created by Maksim Kalik

import UIKit

extension UIImage {

    /// Base User Interface Icon
    convenience init?(icon: BaseIcon) {
        self.init(named: icon.rawValue)
    }
}

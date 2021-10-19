//  Created by Maksim Kalik

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var okButtonTitle: String? = "Ok"
    var okHandler: ((UIAlertAction) -> Void)? = nil
    var cancelButtonTitle: String? = "Cancel"
    var cancelHandler: ((UIAlertAction) -> Void)? = nil
}

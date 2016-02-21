//
// Created by John Bobington on 31/01/2016.
// Copyright (c) 2016 __ORPHEE__. All rights reserved.
//

import UIKit

@IBDesignable
public class defaultHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet public var actionButton: UIButton?
    @IBOutlet public var titleLabel: UILabel?
    @IBInspectable public var identifier: String?
    override public var reuseIdentifier: String? {
        return self.identifier
    }

    override public func prepareForReuse() {
        print("reuse")
        super.prepareForReuse()
    }
}

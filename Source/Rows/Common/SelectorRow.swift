//
//  SelectorRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

open class PushSelectorCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func update() {
        super.update()
        accessoryType = .disclosureIndicator
        editingAccessoryType = accessoryType
        selectionStyle = row.isDisabled ? .none : .default
    }
}

/// Generic row type where a user must select a value among several options.
open class SelectorRow<T: Equatable, Cell: CellType, VCType: TypedRowControllerType>: OptionsRow<T, Cell>, PresenterRowType where Cell: BaseCell, Cell: TypedCellType, Cell.Value == T, VCType: UIViewController,  VCType.RowValue == T {
    
    /// Defines how the view controller will be presented, pushed, etc.
    open var presentationMode: PresentationMode<VCType>?
    
    /// Will be called before the presentation occurs.
    open var onPresentCallback : ((FormViewController, VCType)->())?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
    /**
     Extends `didSelect` method
     */
    open override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.createController(){
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.presentViewController(controller, row: self, presentingViewController: self.cell.formViewController()!)
        }
        else{
            presentationMode.presentViewController(nil, row: self, presentingViewController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    open override func prepareForSegue(_ segue: UIStoryboardSegue) {
        super.prepareForSegue(segue)
        guard let rowVC = segue.destination as? VCType else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.completionCallback = presentationMode?.completionHandler ?? rowVC.completionCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}

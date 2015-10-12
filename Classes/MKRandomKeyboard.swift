//
//  MKRandomKeyboard.swift
//  MKRandomKeyboard
//
//  Created by Minya Konka on 15/10/12.
//  Copyright © 2015年 Minya Konka. All rights reserved.
//

import UIKit

let version = 1.0

typealias TextInputCompleteBlock = () -> Void

// MARK: MKRandomKeyboard Class

/*
*
*/
class MKRandomKeyboard: UIView {
    
    // MARK: 内嵌枚举
    
    private enum TextInputType {
        
        case TextInput
        case TextField
        case TextView
    }

    // MARK: UI elements
    @IBOutlet var numberButtons: [UIButton]!
    @IBOutlet weak var extraButton: UIButton!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    // MARK: Private properties
    private var _numbers: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    private var _textInptuType: TextInputType = .TextInput
    
    // MARK: Public properties
    private weak var _textInput: UITextInput?
    var textInput: UITextInput? {
        get {
            return _textInput
        }
        
        set {
            if _textInput != nil {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidBeginEditingNotification, object: _textInput)
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidBeginEditingNotification, object: _textInput)
            }
            
            _textInput = newValue
            
            if _textInput != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "__handleTextInputTextDidBeginEditing:", name: UITextFieldTextDidBeginEditingNotification, object: _textInput)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "__handleTextInputTextDidBeginEditing:", name: UITextViewTextDidBeginEditingNotification, object: _textInput)
            }
            
            if _textInput is UITextField {
                
                _textInptuType = .TextField
                
            } else if _textInput is UITextView {
                
                _textInptuType = .TextView
                
            } else {
                
                _textInptuType = .TextInput
            }
        }
    }
    
    private var _extraTitle: String = ""
    var extraTitle: String {
        get {
            return _extraTitle
        }
        
        set {
            _extraTitle = newValue
            
            extraButton.setTitle(_extraTitle, forState: .Normal)
            extraButton.enabled = _extraTitle != ""
        }
    }
    
    var completeBlock: TextInputCompleteBlock?
    
    var random: Bool = true
    
    // MARK: Creator
    class func keyboard(frame: CGRect, textInput: UITextInput, complete: TextInputCompleteBlock?) -> MKRandomKeyboard? {
        
        let keyboard: MKRandomKeyboard? = NSBundle.mainBundle().loadNibNamed("MKRandomKeyboard", owner: nil, options: nil)[0] as? MKRandomKeyboard
        keyboard?.textInput = textInput
        keyboard?.extraTitle = ""
        keyboard?.completeBlock = complete
        
        return keyboard
    }
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 203.0 / 255.0, green: 205.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0).CGColor
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        heightConstraint.constant = 0.5
        widthConstraint.constant = 0.5
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        
        guard let textInput = _textInput else { return false }
        
        if textInput is UITextField {
            return (textInput as! UITextField).resignFirstResponder()
        } else if textInput is UITextView {
            return (textInput as! UITextView).resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: Button Event Handlers
    
    @IBAction func enter(sender: UIButton) {
        
        guard let textInput = _textInput else { return }
        
        let text = sender.currentTitle ?? ""
        
        switch _textInptuType {
            
        case .TextInput:
            if textInput.shouldChangeTextInRange!(textInput.selectedTextRange!, replacementText: text) {
                textInput.insertText(text)
            }
            
        case .TextField:
            let selectedRange: NSRange = __selectedRange(textInput)
            let textField = textInput as! UITextField
            
            guard let delegate = textField.delegate else {
                textInput.insertText(text)
                return
            }
            
            if delegate.textField!(textField, shouldChangeCharactersInRange: selectedRange, replacementString: text) {
                textInput.insertText(text)
            }
            
        case .TextView:
            let selectedRange: NSRange = __selectedRange(textInput)
            let textView = textInput as! UITextView
            
            guard let delegate = textView.delegate else {
                textView.insertText(text)
                return
            }
            
            if delegate.textView!(textView, shouldChangeTextInRange: selectedRange, replacementText: text) {
                textInput.insertText(text)
            }
        }
    }
    
    @IBAction func back(sender: UIButton) {
        
        guard let textInput = _textInput else { return }
        
        switch _textInptuType {
        case .TextInput:
            var textRange = textInput.selectedTextRange ?? UITextRange()
            
            if textRange.start.isEqual(textRange.end) {
                let newStart: UITextPosition = textInput.positionFromPosition(textRange.start, inDirection: .Left, offset: 1) ?? UITextPosition()
                textRange = textInput.textRangeFromPosition(newStart, toPosition: textRange.end) ?? UITextRange()
            }
            
            if textInput.shouldChangeTextInRange!(textRange, replacementText: "") {
                textInput.deleteBackward()
            }
            
        case .TextField:
            
            let textField = textInput as! UITextField
            
            guard let delegate = textField.delegate else {
                textInput.deleteBackward()
                return
            }
            
            var selectedRange: NSRange = __selectedRange(textInput)
            
            if selectedRange.length == 0 && selectedRange.location > 0 {
                selectedRange.location--
                selectedRange.length = 1
            }
            
            if delegate.textField!(textField, shouldChangeCharactersInRange: selectedRange, replacementString: "") {
                textInput.deleteBackward()
            }
            
        case .TextView:
            
            let textView = textInput as! UITextView
            guard let delegate = textView.delegate else {
                textInput.deleteBackward()
                return
            }
            
            var selectedRange: NSRange = __selectedRange(textInput)
            if selectedRange.length == 0 && selectedRange.location > 0 {
                selectedRange.location--
                selectedRange.length = 1
            }
            
            if delegate.textView!(textView, shouldChangeTextInRange: selectedRange, replacementText: "") {
                textInput.deleteBackward()
            }
        }
    }
    
    @IBAction func dismiss(sender: UIButton) {
        resignFirstResponder()
    }
    
    
    @IBAction func finish(sender: UIButton) {
        
        if _textInput is UITextField && (_textInput as! UITextField).text == "" { return }
        if _textInput is UITextView && (_textInput as! UITextView).text == "" { return }
        
        resignFirstResponder()
        
        if let block = completeBlock {
            block()
        }
    }
    
    // MARK: Private Methods
    
    /*
    
    */
    private func __updateNumberKeys() {
        
        guard random else { return }
        
        _numbers = _numbers.shuffle()
        
        for (index, value) in _numbers.enumerate() {
            
            numberButtons[index].setTitle(value, forState: .Normal)
        }
    }
    
    private func __selectedRange(textInput: UITextInput) -> NSRange {
        
        let textRange = textInput.selectedTextRange ?? UITextRange()
        
        let startOffset = textInput.offsetFromPosition(textInput.beginningOfDocument, toPosition: textRange.start)
        let endOffset = textInput.offsetFromPosition(textInput.beginningOfDocument, toPosition: textRange.end)
        
        return NSMakeRange(startOffset, endOffset - startOffset)
    }
    
    @objc private func __handleTextInputTextDidBeginEditing(notification: NSNotification) {
        
        __updateNumberKeys()
    }
}

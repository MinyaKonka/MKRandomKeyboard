//
//  ViewController.swift
//  MKRandomKeyboard
//
//  Created by Minya Konka on 15/10/12.
//  Copyright © 2015年 Minya Konka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let keyboard = MKRandomKeyboard.keyboard(CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 350.0), textInput: textField) { () -> Void in
            print("complete the text field input")
        }
        
        textField.inputView = keyboard
        
        let keyboard2 = MKRandomKeyboard.keyboard(CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 350.0), textInput: textView) { () -> Void in
            print("complete the text view input")
        }
        keyboard2?.extraTitle = "X"
        textView.inputView = keyboard2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


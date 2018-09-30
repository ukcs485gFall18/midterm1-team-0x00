/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class AccountViewController: UITableViewController {
  
  @IBOutlet weak var firstNameField: UITextField!
  @IBOutlet weak var middleInitialField: UITextField!
  @IBOutlet weak var lastNameField: UITextField!
  @IBOutlet weak var superVillianNameField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  
  //Added for additional Functionality
  @IBOutlet weak var expressionField: UITextField!
  @IBOutlet weak var expressionResult: UILabel!
  
    
  struct Storyboard {
    struct Identifiers {
      static let unwindSegueIdentifier = "UnwindSegue"
    }
  }
  
  lazy var textFields: [UITextField] = []
  var regexes: [NSRegularExpression?]!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // *** Added in Tutorial *** //
    textFields = [ firstNameField, middleInitialField, lastNameField, superVillianNameField, passwordField ]

    let patterns = [ "^[a-z]{1,10}$",
                     "^[a-z]$",
                     "^[a-z'\\-]{2,20}$",
                     "^[a-z0-9'.\\-\\s]{2,20}$",
                     "^(?=\\P{Ll}*\\p{Ll})(?=\\P{Lu}*\\p{Lu})(?=\\P{N}*\\p{N})(?=[\\p{L}\\p{N}]*[^\\p{L}\\p{N}])[\\s\\S]{8,}$" ]
    
    regexes = patterns.map {
      do {
        let regex = try NSRegularExpression(pattern: $0, options: .caseInsensitive)
        return regex
      } catch {
        #if targetEnvironment(simulator)
        fatalError("Error initializing regular expressions. Exiting.")
        #else
        return nil
        #endif
      }
    }
    // ***                   *** //
    
    //Added by Cody Leslie
    //Initialize anything needed for the expression checking
    expressionResult.text = "Please enter a simple math expression"
    //End of addition
}
  
  override func viewWillAppear(_ animated: Bool) {
    firstNameField.text = AccountManager.getFirstName()
    middleInitialField.text = AccountManager.getFMiddleInitial()
    lastNameField.text = AccountManager.getLastName()
    superVillianNameField.text = AccountManager.getSuperVillianName()
    passwordField.text = AccountManager.getPassword()
    
    super.viewWillAppear(animated)
  }
    
    //Added by Cody Leslie
    // If the button has been pressed, test the expression.
    // In further research, I discovered that it is impossible to model parenthetical operations with regular expressions.
    // As such, this only tests the basic operators +, -, *, /, and ^.
    // However, to add more complexity to compensate for this, it now accepts decimal values and sin() expressions.
    func validExpression(exp: String) -> Bool
    {
        let expressionPattern = "^(\\d+\\d*\\.?\\d*)|(sin\\(\\d+\\d*\\.?\\d*\\))([\\+-\\/\\*\\^]((\\d+\\d*\\.?\\d*)|sin\\(\\d+\\d*\\.?\\d*\\)))*$"
        let expressionRegEx = try! NSRegularExpression(pattern: expressionPattern)
        return validateWhole(test: exp, RegEx: expressionRegEx)
    }
    
    //Make sure the whole string matches
    func validateWhole(test: String, RegEx regex:NSRegularExpression) -> Bool
    {
        let range = NSRange(test.startIndex..., in: test)
        let matches = regex.matches(in: test, options: .reportProgress, range: range)
        for match in matches{
            let matchRange = match.range
            if matchRange.location != NSNotFound
            {
                if matchRange.upperBound == test.count
                {
                    return true
                }
            }
            
        }
        return false
    }
    
    //Modify label based on the result
    @IBAction func expTest(_ sender: Any) {
        let result:Bool
        if let input = expressionField.text
        {
            result = validExpression(exp: input)
        } else {
            //Set to false if no input
            result = true
        }
        if result {
            expressionResult.text = "Valid"
        } else {
            expressionResult.text = "Invalid"
        }
    }
    //End of addition
    
  @IBAction func saveTapped(_ sender: AnyObject) {
    if allTextFieldsAreValid() {
      AccountManager.setAccountWith(firstName: firstNameField.text,
                                    middleInitial: middleInitialField.text,
                                    lastName: lastNameField.text,
                                    superVillianName: superVillianNameField.text,
                                    password: passwordField.text)
      
      performSegue(withIdentifier: Storyboard.Identifiers.unwindSegueIdentifier, sender: self)
    } else {
      let alertController = UIAlertController(title: "Error!", message: "Could not save account details. Some text fields failed to validate.", preferredStyle: .alert)
      let dismissAction = UIAlertAction(title: "OK", style: .default)
      alertController.addAction(dismissAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func validate(string: String, withRegex regex: NSRegularExpression) -> Bool {
    
    // *** Added in Tutorial *** //
    let range = NSRange(string.startIndex..., in: string)
    let matchRange = regex.rangeOfFirstMatch(in: string, options: .reportProgress, range: range)
    return matchRange.location != NSNotFound
    // ***                   *** //
    
    }
  
  func validateTextField(_ textField: UITextField) {
    
    // *** Added in Tutorial *** //
    let index = textFields.index(of: textField)
    if index != nil {
        if let regex = regexes[index!] {
          if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
      
            let valid = validate(string: text, withRegex: regex)
            
            textField.textColor = valid ? .trueColor : .falseColor
          }
        }
    }
    // ***                   *** //
    
  }
  
  func allTextFieldsAreValid() -> Bool {
    for (index, textField) in textFields.enumerated() {
      if let regex = regexes[index] {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
          let valid = text.isEmpty || validate(string: text, withRegex: regex)
          
          if !valid {
            return false
          }
        }
      }
    }
    
    return true
  }
}

// MARK: - UITextFieldDelegate

extension AccountViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.textColor = .black
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    validateTextField(textField)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    validateTextField(textField)
    
    makeNextTextFieldFirstResponder(textField)
    
    return true
  }
  
  func makeNextTextFieldFirstResponder(_ textField: UITextField) {
    textField.resignFirstResponder()
    
    if var index = textFields.index(of: textField) {
      index += 1
      if index < textFields.count {
        textFields[index].becomeFirstResponder()
      }
    }
  }
}

// MARK: - UIColor helpers

extension UIColor {
  static var trueColor = UIColor(red: 0.1882, green: 0.6784, blue: 0.3882, alpha: 1.0)
  static var falseColor = UIColor(red: 0.7451, green: 0.2275, blue: 0.1922, alpha: 1.0)
}



//
//  ChatViewController.swift
//  TwitSplit
//
//  Created by Hieu Do on 10/2/17.
//  Copyright © 2017 Hieu Do. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var txtContent: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var constraintViewSendBottom: NSLayoutConstraint!
    
    var tapGesture:UITapGestureRecognizer!
    var arrData:NSMutableArray = NSMutableArray.init()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        styleView()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func styleView()
    {
        arrData = splitMessage("Please enter any string to check your results")
        
        txtContent.delegate = self
        self.btnSend.layer.cornerRadius = 3
        
        //table view style
        tableViewMain.dataSource = self
        tableViewMain.delegate = self
        tableViewMain.estimatedRowHeight = 60
        tableViewMain.rowHeight = UITableViewAutomaticDimension
        tableViewMain.backgroundColor = UIColor.white
        
        //Handle TapGesture
        tapGesture = UITapGestureRecognizer(target: self,
                                            action: #selector(self.hideKeyboard))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(noti:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(noti:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    /******************************* HANDLE KEYBOARD *******************************************************/
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(noti:Notification)
    {
        guard let userInfo = noti.userInfo as? [String:Any] else { return }

        guard let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        let keyboardSize = keyboard.cgRectValue.size
        let keyboardHeight = keyboardSize.height

        UIView.animate(withDuration: duration) {
            self.constraintViewSendBottom.constant = keyboardHeight
            self.tableViewMain.contentInset.bottom = keyboardHeight + 40
        }
        
        let indexPath = IndexPath(row: self.arrData.count - 1, section: 0)
        tableViewMain.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func keyboardWillHide(noti:Notification)
    {
        guard let userInfo = noti.userInfo as? [String:Any] else { return }
        guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.constraintViewSendBottom.constant = 0
            self.tableViewMain.contentInset.bottom = 0
        }
    }

    /******************************* EVENT BUTTON *******************************************************/

    @IBAction func btnSenderTap(_ sender: Any)
    {
        if self.txtContent.text != "" {
            let inputString = self.txtContent.text?.trimmingCharacters(in: .whitespaces)
            arrData = splitMessage(inputString!)
            tableViewMain.reloadData()
            self.txtContent.text = ""
        }
        else {
            let alert = UIAlertController(title: "Note", message: "Please enter a value before submitting!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /******************************* SPLIT MESSAGE *******************************************************/

    func splitMessage(_ strInput: String) -> NSMutableArray
    {
        let arrListTemp = NSMutableArray.init()
        let arrListResult = NSMutableArray.init()
        var count = 1

        if strInput.characters.count < 51 {
            arrListTemp.add(strInput)
        }
        else {
            let estimal = strInput.characters.count / 50
            var temp = strInput

            while temp.characters.count >= (50 - 2 - String(estimal).characters.count - String(count).characters.count) {
                
                var position = 49 - String(count).characters.count - 2 - String(estimal).characters.count
                for index in stride(from: position, through: 0, by: -1) {
                    if (temp[index] == " ") {
                        position = index
                        break
                    }
                }

                let item:String = temp[0 ..< position + 1]
                let index = temp.index(temp.startIndex, offsetBy: position)
                arrListTemp.add(item)

                temp = temp.substring(from: index)
                if(temp[0] == " ") {
                    let index = temp.index(temp.startIndex, offsetBy: 1)
                    temp = temp.substring(from: index)
                }
                
                count = count + 1
            }
            arrListTemp.add(temp)


        }
        
        for index in 0 ..< arrListTemp.count {
            arrListResult.add("\(index + 1)/\(count) \(arrListTemp[index])")
        }
        
        return arrListResult
    }
}

/******************************* EXTENSION *******************************************************/

extension ChatViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "senderCell", for: indexPath) as! ContentTableViewCell
        cell.lblText.text = arrData[indexPath.row] as? String

        return cell
    }
}

extension ChatViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField === txtContent {
            print(txtContent.text as Any)
        }
        
        return true
    }
}

extension String
{
    var length: Int
    {
        return self.characters.count
    }
    
    subscript (i: Int) -> Character
    {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String
    {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String
    {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

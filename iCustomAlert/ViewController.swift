//
//  ViewController.swift
//  iCustomAlert
//
//  Created by i9400506 on 2020/3/18.
//  Copyright © 2020 i9400506. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private weak var okAction : UIAlertAction?

    private weak var _redLayer: CALayer?
    
    private weak var alert: UIAlertController?
    
    @IBOutlet weak var textField: CustomTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.returnKeyType = .done
        self.textField.borderStyle = .bezel
        self.textField.font = UIFont(name: "a0", size: 24)
        self.textField.delegate = self
    }
    
    @IBAction func showAlert(_ sender: UIButton) {
        // Detect textField value change
        // 方法1. textField.delegate.textFieldDidChangeSelection > iOS 13後才能使用
        // 方法2 textField.addTarget > 不限iOS版本
        // 兩種方式直接修改text都不會觸發
        // 方法2 透過sendAction來達成目的
        
        self.textField.text = "你好嗎"
        self.textField.sendActions(for: .editingChanged)
        return
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addTextField { [unowned self] (textField) in
            // 設定textfield型態
            textField.placeholder = "身分證字號"
            textField.keyboardType = .asciiCapable // 只能輸入ascii, 這樣在插入複製就不會前後多空白(比較合理做法是使用下列方式)
            
            // 解決插入貼上時會前後多空白的問題
            if #available(iOS 11.0, *) {
                textField.smartInsertDeleteType = .no
            }
            
            // clearButtonMode
            // always - 有值就會出現(無論是否為firstResponse)
            // never - 永遠不出現(default)
            // whileEditing - 有值且為firstResponse(正在編輯)才出現
            // unlessEditing - 有值且非firstResponse才出現
            textField.clearButtonMode = .always
            
            // 設定textfile邊框格式 - 預設為none
            //textField.borderStyle = .bezel
            
            if #available(iOS 13.0, *) {
                // iOS 13開始在delegate新增textFieldDidChangeSelection方法，並在完成後會呼叫(故實在delegate上)
            } else {
                // iOS 13前的版本必須自行加入事件監控來處理
                textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            }
            
            textField.delegate = self
        }
        
        let title = NSMutableAttributedString(string: "請再次輸入您的身分證字號\n輸入完成請按下Enter", attributes: [.font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: UIColor.red])
        alert.setValue(title, forKey: "attributedTitle")

        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { [unowned self] (_) in
            if #available(iOS 13.0, *) {
                // iOS 13開始在delegate新增textFieldDidChangeSelection方法，並在完成後會呼叫(故實在delegate上)
            } else {
                // iOS 13前的版本必須自行加入事件監控 > 所以要remove
                alert.textFields?.first?.removeTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            }
        }
        let okAction = UIAlertAction(title: "確認", style: .default) { (action) in
            if #available(iOS 13.0, *) {
                // iOS 13開始在delegate新增textFieldDidChangeSelection方法，並在完成後會呼叫(故實在delegate上)
            } else {
                // iOS 13前的版本必須自行加入事件監控 > 所以要remove
                alert.textFields?.first?.removeTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            }
        }
        okAction.isEnabled = false
        self.okAction = okAction
        for action in [cancelAction, okAction] {
            alert.addAction(action)
        }
        self.alert = alert
        
//        // 檢核外框1 - 爬上層的view & 多個textfield有點醜
//        alert.textFields?.last?.superview?.layer.borderWidth = 1
//        alert.textFields?.last?.superview?.layer.borderColor = UIColor.red.cgColor
//        self.present(alert, animated: true, completion: nil)
        
//        // 檢核外框2 - 太窄且與輸入文字太靠近
//        alert.textFields?.last?.layer.borderWidth = 1
//        alert.textFields?.last?.layer.cornerRadius = 5
//        alert.textFields?.last?.layer.borderColor = UIColor.red.cgColor
//        self.present(alert, animated: true, completion: nil)
        
//        // 檢核外框3
//        // textfield的superview加入sublayer, 需設定layer frame, 故在completion才能取得元件大小 > layer會比原本小但要爬view
//        // 取sublayer的最後一筆就可以直接控制 or catch layer直接操作
//        self.present(alert, animated: true) {
//            if let borderView = alert.textFields?.last?.superview {
//                let redLayer = CALayer()
//                redLayer.borderWidth = 1
//                redLayer.cornerRadius = 5
//                redLayer.borderColor = UIColor.red.cgColor
//                redLayer.frame = CGRect(x: 3, y: 3, width: borderView.frame.width - 6, height: borderView.frame.height - 6)
//                borderView.layer.addSublayer(redLayer)
//            }
//        }
        
                // 檢核外框4
                // textfield加入sublayer, 需設定layer frame, 故在completion才能取得元件大小 > layer會比原本大但不用爬view
                // 輸入內容後會增加一層layer, 故會導致要控制外控showhide時, 沒辦法直接取最後一個sublayer控制(實際位置是sublayers.count - 2) or catch layer直接操作
        //        self.present(alert, animated: true) {
        //            if let textField = alert.textFields?.last {
        //                let redLayer = CALayer()
        //                redLayer.borderWidth = 1
        //                redLayer.cornerRadius = 5
        //                redLayer.borderColor = UIColor.red.cgColor
        //                redLayer.frame = CGRect(x: -3, y: -3, width: textField.frame.width + 6, height: textField.frame.height + 6)
        //                textField.layer.addSublayer(redLayer)
        //            }
        //        }
        // 檢核外框4 - catch layer
        self.present(alert, animated: true) {
            if let textField = alert.textFields?.last {
                let redLayer = CALayer()
                redLayer.borderWidth = 1
                redLayer.cornerRadius = 5
                redLayer.borderColor = UIColor.red.cgColor
                redLayer.frame = CGRect(x: -6, y: -6, width: textField.frame.width + 12, height: textField.frame.height + 12)
                textField.layer.addSublayer(redLayer)
                self._redLayer = redLayer
            }
        }
        
        // 結論:
        // 方法1在多個textfield時，邊框沒有四邊cornerRadius, 且需要爬view
        // 方法2太貼ui太貼textfield > 不考慮
        // 方法3和方法4都是新增sublayer > 需要在completion設定大小
        // 方法3需要爬view
        // 方法4會無法從最後一筆取得方框layer(catch或倒數第二筆)
        
        // 在不使用方法2的情況下, 剩下方法其實也都需要去爬view(方法4是要去tune與上層view的邊界)
        // 單個輸入 - 方法1
        // 多個輸入 - 方法3
        // textfield自己使用 - 方法4
        
    }
}

extension ViewController: UITextFieldDelegate {
    
    // MARK: firstResponse前
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return true
    }
    
    // MARK: firstResponse後
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("\(#function)")
    }
    
    // MARK: firstresponse離開前
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return true
    }
    
    // MARK: firstresponse離開後(iOS 10前會call這個方法)
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("\(#function)")
    }

    // MARK: firstresponse離開後(iOS 10後含10會call這個方法)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print("\(#function)")
    }
    
    // MARK: 輸入文字是否顯示(return ture 為需顯示且會觸發textFieldDidChangeSelection)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("\(#function)")
        // 異動後textfield新長度 = textField內的文字長度 + 新輸入的長度 - 刪除長度
        let newStrLeng = (textField.text?.count ?? 0) + string.count - range.length
        if newStrLeng > 10 {
            return false
        }
        return string.range(of: "^[a-zA-Z0-9]{0,10}$", options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    // MARK: 選取輸入內容(iOS 13才能使用)
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("\(#function)")
        let text = textField.text
        if let upperText = text?.uppercased(), text != upperText {
            textField.text = upperText
        }
    }
    
    // MARK: iOS 13以前必須自行加入監控事件來處理
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.textFieldDidChangeSelection(textField)
    }
    
    // MARK: 清除全部後會出現(return ture為清除所有內容且會觸發textFieldDidChangeSelection兩次)
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return true
    }

    // MARK: 按下return鍵(enter)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("\(#function)")
        let text = textField.text ?? ""
        let isOK = text.range(of: "^[a-zA-Z0-9]{10}$", options: .regularExpression, range: nil, locale: nil) != nil
        self.okAction?.isEnabled = isOK
        
//        // 檢核外框1
//        textField.superview?.layer.borderWidth = isOK ? 0 : 1
        
//        // 檢核外框2
//        textField.layer.borderWidth = isOK ? 0 : 1
        
        // 檢核外框3
//        textField.superview?.layer.sublayers?.last?.borderWidth = isOK ? 0 : 1

//        // 檢核外框4
//        if let sublayers = textField.layer.sublayers {
//            sublayers[sublayers.count - 2].borderWidth = isOK ? 0 : 1
//        }
        
//        // 檢核外框4 - catch layer
//        self._redLayer?.isHidden = isOK
        
        if let alert = self.alert {
            if isOK {
                alert.setValue(nil, forKey: "attributedMessage")
            } else {
                // common setting
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left

                // message
                let attrMessage = NSMutableAttributedString(string: "\n您所輸入的資料與此次欲受理資料有異，請再次確認授權資料！", attributes: [.font: UIFont.systemFont(ofSize: 14), .paragraphStyle: paragraphStyle])
                alert.setValue(attrMessage, forKey: "attributedMessage")
            }
        }
        return false
    }
}

//
//  InputManager.swift
//  iCustomAlert
//
//  Created by i9400506 on 2020/8/21.
//  Copyright © 2020 i9400506. All rights reserved.
//

import UIKit

class InputManager {
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.shouldChange), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    final func shouldChange(_ notification: Notification) {
        guard let textField = notification.object as? UITextField, textField.markedTextRange == nil else {
            return
        }
        
        textField.text = "abc"
    }
}


class CustomTextField: UITextField {
    
    private var proxyDelegate: TextFieldProxyDelegate?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setDelegate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setDelegate()
    }
    
    private func setDelegate() {
        let proxyDelegate = TextFieldProxyDelegate()
        self.proxyDelegate = proxyDelegate
        // iOS 13前的版本必須自行加入事件監控來處理
        self.addTarget(self, action: #selector(proxyDelegate.textFieldDidChange(_:)), for: .editingChanged)
        self.delegate = proxyDelegate
    }
}

class TextFieldProxyDelegate: NSObject, UITextFieldDelegate {
    
    // MARK: firstResponse前
    final func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return true
    }
    
    // MARK: firstResponse後
    final func textFieldDidBeginEditing(_ textField: UITextField) {
        print("\(#function)")
    }
    
    // MARK: firstresponse離開前
    final func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return true
    }
    
    // MARK: firstresponse離開後(iOS 10前會call這個方法)
    final func textFieldDidEndEditing(_ textField: UITextField) {
        print("\(#function)")
    }

    // MARK: firstresponse離開後(iOS 10後含10會call這個方法)
    final func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print("\(#function)")
    }
    
    // MARK: 輸入文字是否顯示(return ture 為需顯示且會觸發textFieldDidChangeSelection)
    final func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("\(#function)")
        // 異動後textfield新長度 = textField內的文字長度 + 新輸入的長度 - 刪除長度
        return true
    }
    
    // MARK: 選取輸入內容(iOS 13才能使用)
    final func textFieldDidChangeSelection(_ textField: UITextField) {
        print("\(#function)")
    }
    
    // MARK: iOS 13以前必須自行加入監控事件來處理
    @objc final func textFieldDidChange(_ textField: UITextField) {
        print("\(#function)")
        self.textFieldDidChangeSelection(textField)
    }
    
    // MARK: 清除全部後會出現(return ture為清除所有內容且會觸發textFieldDidChangeSelection兩次)
    final func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return true
    }

    // MARK: 按下return鍵(enter)
    final func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("\(#function)")
        return false
    }
}

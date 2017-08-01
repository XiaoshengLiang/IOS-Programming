//
//  ChatLogController.swift
//  Chatty
//
//  Created by LiangXiaosheng on 2017/4/22.
//  Copyright © 2017 LiangXiaosheng. All rights reserved.
//


import UIKit

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    
    var friend: Friend? {
        didSet {
            navigationItem.title = friend?.name
            
            messages = friend?.messages?.allObjects as? [Message]
            
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending}) // put all messages in order
        }
    }
    
    var messages: [Message]?
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(colorLiteralRed: 34, green: 139/255, blue: 34/255, alpha: 1)
        button.setTitleColor(titleColor, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    func handleSend() {
//        print(inputTextField.text)
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        
        let message = FriendsController.createMessageWithText(text: inputTextField.text!, friend: friend!, minsAgo: 0, context: context!, isSender: true)
        do{
            try context?.save()
            messages?.append(message)
            let item = messages!.count - 1
            let insertionIndexPath = NSIndexPath(item: item, section: 0)
            collectionView?.insertItems(at: [insertionIndexPath as IndexPath])
            collectionView?.scrollToItem(at: insertionIndexPath as IndexPath, at: .bottom, animated: true)
            inputTextField.text = nil
        }catch let err{
            print(err)
        }
    }
    
    var bottomConstraint: NSLayoutConstraint?
    
    func simulate() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        
        // insert message before the latest message
        let message = FriendsController.createMessageWithText(text: "Here is a message which is sent from simulator just one min ago.", friend: friend!, minsAgo: 1, context: context!)

            messages?.append(message)
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
            if let item  = messages?.index(of: message){
                let receivingIndexPath = NSIndexPath(item: item, section: 0)
                collectionView?.insertItems(at: [receivingIndexPath as IndexPath])
            }
       

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulator", style: .plain, target: self, action: #selector(simulate))
        
        tabBarController?.tabBar.isHidden = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        view.addSubview(messageInputContainerView)
        view.addConstrainsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstrainsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponents()
        
        // show and hide keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
           }
    
    func handleKeyboardNotification(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            
//            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
//            bottomConstraint?.constant = -keyboardFrame.height
        
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {self.view.layoutIfNeeded()}, completion: {(completed) in
                
                // once keyboard is showed, put the latest message on it.
                    let indexPath = IndexPath(item: (self.messages?.count)! - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)

            })
        
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    // components of input bar
    private func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstrainsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstrainsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstrainsWithFormat(format: "V:|[v0]|", views: sendButton)
        messageInputContainerView.addConstrainsWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstrainsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)
    }

    
    

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count{
            return count
        }
        return 0
    }
    
    // set the width of bubble
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        cell.messageTextView.text = messages?[indexPath.item].text
        
        if let message = messages?[indexPath.item], let messageText = message.text, let profileImageName =  messages?[indexPath.item].friend?.profileImageName{
            
            cell.profileImageView.image = UIImage(named: profileImageName)
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            if message.isSender{
                cell.messageTextView.frame = CGRect(x: view.frame.width-estimatedFrame.width-16-16, y: 0, width: estimatedFrame.width+16, height: estimatedFrame.height+10)
                cell.textBubbleView.frame = CGRect(x: view.frame.width-estimatedFrame.width-16-8-16, y: 0, width: estimatedFrame.width+16+8, height: estimatedFrame.height+20)
                
                cell.profileImageView.isHidden = true
                
                cell.textBubbleView.backgroundColor = UIColor(colorLiteralRed: 34, green: 139/255, blue: 34/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
                
            }else {
                cell.messageTextView.frame = CGRect(x: 48+8, y: 0, width: estimatedFrame.width+16, height: estimatedFrame.height+10)
                cell.textBubbleView.frame = CGRect(x: 48, y: 0, width: estimatedFrame.width+16+8, height: estimatedFrame.height+20)
                
                cell.profileImageView.isHidden = false
                
                cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                cell.messageTextView.textColor = UIColor.black

            }
        }
        return cell
    }
    
    // set the height of bubble
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let messageText = messages?[indexPath.item].text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height+20)

        }
        return CGSize(width: view.frame.width, height: 100)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
    
}

class ChatLogMessageCell: BaseCell {
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "sample messages"
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        addConstrainsWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstrainsWithFormat(format: "V:[v0(30)]|", views: profileImageView)
        
    }
}


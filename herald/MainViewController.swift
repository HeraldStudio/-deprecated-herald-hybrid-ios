//
//  MainViewController.swift
//  herald
//
//  Created by Tricster on 2018/8/30.
//  Copyright © 2018年 Tricster. All rights reserved.
//

import UIKit
import WebKit

class MainViewController:UIViewController, WKUIDelegate, WKScriptMessageHandler, UITabBarDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("i reveive message from web")
        print(message.name)
        print(message.body)
        let data = message.body as! NSDictionary
        if(message.name == "pushRoute"){
            print("starting", message.name)
            self.pushRoute(to: data["route"] as! String, for: data["title"] as! String)
        }
        if(message.name == "openURL"){
            let data = message.body as! NSDictionary
            print(data["url"] as! String)
            UIApplication.shared.open(URL(string: data["url"] as! String)!)
        }
        if(message.name == "logout"){
            let data = message.body as! NSDictionary
            print(data["log"] as! String)
            self.logout()
        }
        if(message.name == "toast"){
            let data = message.body as! NSDictionary
            self.toast(with: data["text"] as! String)
        }
        if(message.name == "clearCache"){
            self.clearCache()
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("one tabbar \(item)is selected")
        if(item.title == "主页"){
            print("go tp home tab")
            self.webView.evaluateJavaScript("window.goto('/home-tab')", completionHandler: nil)
        }
        else if(item.title == "活动"){
            print("go to activity page")
            //self.toast(with: "something")
            self.webView.evaluateJavaScript("window.goto('/activity-tab')", completionHandler: nil)
        }
        else if(item.title == "通知"){
            print("go to notification page")
            self.webView.evaluateJavaScript("window.goto('/notification-tab')", completionHandler: nil)
        }
        else if(item.title == "我的"){
            print("go to personal page")
            self.webView.evaluateJavaScript("window.goto('/personal-tab')", completionHandler: nil)
        }
    }
    
    
    //@IBOutlet weak var webView: WKWebView!
    var webView: WKWebView!
    var subWebView: WKWebView!
    @IBOutlet weak var tabbar: UITabBar!
    @IBOutlet weak var subTitle: UIImageView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var subNavBar: UIView!
    
    @IBOutlet weak var navBack: UIButton!
    @IBOutlet weak var navTitle: UILabel!
    
    @IBOutlet weak var toast: UIView!
    @IBOutlet weak var toastText: UILabel!
    
    
    @IBAction func gotoSub(_ sender: UIButton) {
        print("do somethinf")

        self.navBar.alpha = 1
        self.tabbar.alpha = 1
        //self.subTitle.text = "小猴偷米"
        UIView.animate(withDuration: 0.5, animations: {
            self.subWebView.frame.origin.x += self.subWebView.frame.width
            self.subNavBar.frame.origin.x += self.subNavBar.frame.width
        }, completion: { _ in
            self.subWebView.evaluateJavaScript("window.goto('/home-tab')", completionHandler: nil)
        })

    }
    
    func pushRoute(to route:String, for title:String){
        self.navTitle.text = title
        self.tabbar.alpha = 0
        self.subWebView.evaluateJavaScript("window.goto('\(route)')", completionHandler: nil)
        UIView.animate(withDuration: 0.5, animations: {
            self.subWebView.frame.origin.x -= self.subWebView.frame.width
            self.subNavBar.frame.origin.x -= self.subNavBar.frame.width
        }, completion: {_ in
            self.navBar.alpha = 0

        })
    }
    
    func toast(with text:String){
        //self.toast.frame.width = self.toastText.frame.width + 20
        //self.toastText.frame.width = self.toast.frame.width
        UIView.animate(withDuration: 0.5, animations: {
            self.toast.alpha = 0.8
            self.toastText.text = text
            self.view.bringSubview(toFront: self.toast)
        }, completion: {_ in
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                print("end timing")
                UIView.animate(withDuration: 0.5, animations: {
                    self.toast.alpha = 0
                }, completion:{ _ in
                    self.toastText.text = ""
                })
            })
            print("start timing")
        })
    }
    
    func logout(){
        UserDefaults.standard.removeObject(forKey: "token")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "loginController") as? LoginViewController else{
        print("not found ")
        return
        }
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func clearCache(){
        
    }
    
    @IBOutlet var myview: UIView!
    
    func createView(){
        let webConfiguration = WKWebViewConfiguration()
        let userContent = WKUserContentController()
        userContent.add(self, name: "pushRoute")
        userContent.add(self, name: "toast")
        userContent.add(self, name: "openURL")
        userContent.add(self, name: "logout")
        userContent.add(self, name: "clearCache")
        let token = UserDefaults.standard.string(forKey: "token")!
        //print(token)
        
        let injectToken = "window.heraldToken = '\(token)'"
        print(injectToken)
        
        let script = WKUserScript(source: injectToken, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContent.addUserScript(script)
        webConfiguration.userContentController = userContent
        self.webView = WKWebView(frame: CGRect(x: 0, y: self.navBar.frame.height+self.navBar.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height-self.navBar.frame.height-49) , configuration: webConfiguration)
        //self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.uiDelegate = self
        self.view.addSubview(self.webView)
    }
    
    func loadSubView(){
        let webConfiguration = WKWebViewConfiguration()
        let userContent = WKUserContentController()
        userContent.add(self, name: "pushRoute")
        userContent.add(self, name: "toast")
        userContent.add(self, name: "openURL")
        userContent.add(self, name: "logout")
        userContent.add(self, name: "clearCache")
        let token = UserDefaults.standard.string(forKey: "token")!
        print(token)
        
        let injectToken = "window.heraldToken = '\(token)'"
        print(injectToken)
        
        let script = WKUserScript(source: injectToken, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContent.addUserScript(script)
        webConfiguration.userContentController = userContent
        self.subWebView = WKWebView(frame: CGRect(x: 0, y: self.subNavBar.frame.height+self.subNavBar.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height) , configuration: webConfiguration)
        self.subWebView.uiDelegate = self
        view.addSubview(self.subWebView)
        
    }
    
    let tab_icons = ["home_tab_icon", "activity_tab_icon", "notification_tab_icon", "personal_tab_icon"]
    let tab_icons_selected = ["home_tab_icon_selected", "activity_tab_icon_selected", "notification_tab_icon_selected", "personal_tab_icon_selected"]
    
    func setTabBar(){
        for (index, item) in (self.tabbar.items?.enumerated())!{
            item.image = UIImage(named: tab_icons[index])
            item.selectedImage = UIImage(named: tab_icons_selected[index])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createView()
        self.loadSubView()
        //self.setTabBar()
        self.subWebView.load(URLRequest(url: URL(string: "http://hybrid.myseu.cn")!))
        self.subWebView.frame.origin.x = self.subWebView.frame.width
        self.subNavBar.frame.origin.x = self.subNavBar.frame.width
        self.tabbar.delegate = self
        self.view.addSubview(self.tabbar)
        self.toast.alpha = 0
        self.toast.layer.cornerRadius = 5
        self.toast.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let myURL = URL(string: "http://hybrid.myseu.cn")
        let myRequest = URLRequest(url: myURL!)
        self.webView.load(myRequest)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

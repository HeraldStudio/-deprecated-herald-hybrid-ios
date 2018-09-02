//
//  LoginViewController.swift
//  herald
//
//  Created by Tricster on 2018/8/28.
//  Copyright © 2018年 Tricster. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.Login()
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.password.isSecureTextEntry = true
        self.password.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        guard let _ = UserDefaults.standard.string(forKey: "token") else{
            
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondVC = storyboard.instantiateViewController(withIdentifier: "TabController") as? MainViewController else{
            print("not found ")
            return
        }
        print("go to home")
        self.present(secondVC, animated: true, completion: nil)
    }
    
    func requestWithJSONBody(urlString: String, parameters: [String: Any], completion: @escaping (Data) -> Void){
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        }catch let error{
            print(error)
        }
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        fetchedDataByDataTask(from: request, completion: completion)
    }
    private func fetchedDataByDataTask(from request: URLRequest, completion: @escaping (Data) -> Void){
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil{
                print(error as Any)
            }else{
                guard let data = data else{return}
                completion(data)
            }
        }
        task.resume()
    }
    func store(with token: String){
        print(token)
        UserDefaults.standard.set(token, forKey: "token")
        print("stored")
    }
    
    @IBOutlet weak var cardnum: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginFail: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var paras = ["cardnum": "", "password": "", "platform": "darwin"]
    let urlstring:String = "https://myseu.cn/ws3/auth"
    
    
    @IBAction func pressLogin(_ sender: UIButton) {
        self.Login()
    }
    
    func Login() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondVC = storyboard.instantiateViewController(withIdentifier: "TabController") as? MainViewController else{
            print("not found ")
            return
        }
        print("don't know what to do")
        guard let token = UserDefaults.standard.string(forKey: "token") else{
            if (self.cardnum.text == "" || self.password.text == ""){
                self.view.bringSubview(toFront: self.loginFail)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                    self.view.bringSubview(toFront: self.loginButton)
                })
                return
            }
            self.paras["cardnum"] = self.cardnum.text
            self.paras["password"] = self.password.text
            self.requestWithJSONBody(urlString: self.urlstring, parameters: self.paras, completion: { (result) in
                let data = try? JSONSerialization.jsonObject(with: result, options: .mutableContainers) as! NSDictionary
                DispatchQueue.main.async {
                    guard let token = data!["result"] else{
                        self.view.bringSubview(toFront: self.loginFail)
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                            self.view.bringSubview(toFront: self.loginButton)
                            self.password.text = ""
                        })
                        return
                    }
                    print(token)
                    self.store(with: token as! String)
                    self.present(secondVC, animated: true, completion: nil)
                }
            });
            return
        }
        print(token)
        print("ready to go")
        self.present(secondVC, animated: true, completion: nil)

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

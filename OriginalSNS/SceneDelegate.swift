//
//  SceneDelegate.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/04.
//

import UIKit
import NCMB
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //Firebase
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        
        window.makeKeyAndVisible()
        
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let welcomeViewController = storyboard.instantiateViewController(identifier: "WelcomeViewController")
        window.rootViewController = welcomeViewController
        
        
        //NCMB
        let ud = UserDefaults.standard
        let isLogin = ud.bool(forKey: "isLogin")
        if isLogin == true {
            //ログイン中だったら
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
            self.window?.rootViewController = rootViewController
            self.window?.backgroundColor = UIColor.white
            self.window?.makeKeyAndVisible()
        } else {
            //ログインしていなかったら
            let storyboard = UIStoryboard(name: "SignUp", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
            self.window?.rootViewController = rootViewController
            self.window?.backgroundColor = UIColor.white
            self.window?.makeKeyAndVisible()
            
            
                }
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


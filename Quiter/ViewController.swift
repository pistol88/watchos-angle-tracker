import UIKit
import WatchConnectivity
class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var iPhoneLabel: UILabel!
    var session : WCSession!;
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let msg = message["b"] as? String;
        self.iPhoneLabel.text = msg;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if(WCSession.isSupported()){
            self.session = WCSession.default;
            self.session.delegate = self;
            self.session.activate();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        session.sendMessage(["a" : "Hello"], replyHandler: nil, errorHandler: nil);
    }
}

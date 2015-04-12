//
//  ConnectionBySession.swift
//  ShotAlertForSwift
//
//  Created by 平塚 俊輔 on 2015/04/07.
//  Copyright (c) 2015年 &#24179;&#22618;&#12288;&#20426;&#36628;. All rights reserved.
//
public protocol ConnectionResultBySession{
    func showResult(resultMessage: String?) -> Void
    func handleErrorForConnection()
}



public class ConnectionBySession : NSObject,NSURLSessionDataDelegate{

    // 参考:
    // NSURLConnection ttp://stackoverflow.com/questions/24176362/ios-swift-and-nsurlconnection
    // Delegate, Protocol ttp://qiita.com/mochizukikotaro/items/a5bc60d92aa2d6fe52ca
    public var delegate : ConnectionResultBySession!

    // nilが入ってるなんてあり得ない！
    var urlStr : String
    public var data : NSMutableData? = nil

    var error:NSError?
    var status:Int?
    var session:NSURLSession!

    // コンストラクタ
    public init(urlStr: String) {
        self.data = NSMutableData()
        self.urlStr = urlStr
    }

    // アクセス
    public func doConnect() -> Void{
        println(urlStr)
        var url : NSURL = NSURL(string: urlStr)!

        //タイムアウトは15秒
        var config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 15
        //
        self.session = NSURLSession(configuration: config,
            delegate: self,
            delegateQueue: NSOperationQueue.mainQueue())

        var task:NSURLSessionDataTask = self.session.dataTaskWithURL(url)
        task.resume()
    }

    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void){
        println("request_start")

        if response.isKindOfClass(NSHTTPURLResponse){
            let httpURLResponse:NSHTTPURLResponse = response as NSHTTPURLResponse

            self.status = httpURLResponse.statusCode


            if self.status == 200{
                //println("success")

                let disposition:NSURLSessionResponseDisposition = NSURLSessionResponseDisposition.Allow
                completionHandler(disposition)
            }else{
                self.delegate.handleErrorForConnection()
            }
        }


    }
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask){
        println("didBecomeDownloadTask")
    }

    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData){

        //        let json : String = NSString(data: data, encoding: NSUTF8StringEncoding)!
        //        println(json)


        self.data!.appendData(data)
        self.delegate.showResult("success")



    }

    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?){
        println(error)
        if error != nil{
            //println("didCompleteWithError")
            self.delegate.handleErrorForConnection()
        }


    }
    public func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?){
        println(error)

        if error != nil{
            //println("didCompleteWithError")
            self.delegate.handleErrorForConnection()
        }
    }

    public func cancelConnect(){
        self.session.getTasksWithCompletionHandler
            {
                (dataTasks, uploadTasks, downloadTasks) -> Void in

                self.cancelTasksByUrl(dataTasks     as [NSURLSessionTask])

        }
    }

    private func cancelTasksByUrl(tasks: [NSURLSessionTask])
    {
        for task in tasks
        {
            task.cancel()
        }
    }
}

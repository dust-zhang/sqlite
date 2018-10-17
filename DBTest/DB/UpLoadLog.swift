//
//  UpLoadLog.swift
//  Driver_China
//
//  Created by dust.zhang on 2018/10/12.
//  Copyright © 2018年 bmkp. All rights reserved.
//

import Foundation

open class UpLoadLog {
    
    static let shareInstance = UpLoadLog()
    /// 轮询 timer
    private var pollingTimer: Timer?
    private var arrLog : NSMutableArray =  NSMutableArray()
    private var points: [[String: Any]] = []
    
    /*轮询上传日志
     interval: 时间间隔（秒）
     */
    func upLoadLog(interval : TimeInterval)
    {
        // 开启轮询
        pollingTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector:#selector(selectDbLog), userInfo: nil, repeats: true);
    }
    
    //暂停计时器
    private func suspendTime()
    {
        pollingTimer?.fireDate = Date.distantFuture
    }
    
    //重新开始计时器
    func reStartTime()
    {
        pollingTimer?.fireDate = Date.distantPast
    }
    
    //停止计时器
    private func stopTime()
    {
        pollingTimer?.invalidate()
    }
    
    @objc
    private func selectDbLog()
    {
        //先读取数据
        let sql = String.init(format: "select * from %@ limit 10", TABLE_NAME)
        arrLog = BMKPDbManager.shareInstance().select(sql)
        
        //如果存在数据，则上传到服务器
        if arrLog.count > 0
        {
            //遍历日志数据上传
            for index in 0..<arrLog.count
            {
                var model = LogModel()
                model = arrLog[index] as! LogModel
                guard let altitude = model.altitude,
                    let direction = model.direction ,
                    let time = model.time ,
                    let latitude = model.latitude ,
                    let longtitude = model.longtitude ,
                    let orderId = model.orderId ,
//                    let phoneTime = model.phoneTime ,
                    let speed = model.speed ,
                    let locType = model.locType
                else { return}
                
                let dicLog: [String: Any] = ["altitude"     : altitude,
                                             "direction"    : direction,
                                             "time"         : time,
                                             "latitude"     : latitude,
                                             "longtitude"   : longtitude,
                                             "orderId"      : orderId,
                                             "phoneTime"    : "0",
                                             "speed"        : speed,
                                             "locType"      : locType]
                
                
                points.append(dicLog)
               
            }
            //*********************************************
            //调用上传接口,上传成功则删除当前一条数据
            //*********************************************
            Request
                .batchSetPos(points: points)
                .send(retryCount:3)
                .success({ [weak self] _ in
                    //删除当前数据
                    print("----- 多点上传成功")
                    guard let arr = self?.arrLog else { return }
                    self?.deleteCurrentLog(arr: arr )
                }).failure { error in
                    print("----- 多点上传失败%@",error)
            }
            
            
        }
        else
        {
            //*********************************************
            //如果不存在数据，则暂停计时器
            //*********************************************
             suspendTime()
        }
    }
    /* 上传成功后删除数据
     model:要删除的数据model
     */
    private func deleteCurrentLog(arr : NSMutableArray)
    {
        for index in 0..<arrLog.count
        {
            var model = LogModel()
            model = arrLog[index] as! LogModel
            
            if !BMKPDbManager.shareInstance().deleteAllData(model.logId)
            {
                print("删除日志失败")
            }
        }
    }
}

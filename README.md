# sqlite
sqlite option

//初始化数据库
BMKPDatabase.initDb()


//开启上传日志定时器
UpLoadLog.shareInstance().upLoadLog(1)


//添加数据
BMKPDbManager.shareInstance().insert(model)


## 使用说明
#### 1. linux场景
- 下载本项目`git clone https://gitcode.net/qq_40933467/csust-bg-shell.git`
- 配置`info.conf`文件，敏感信息暂不提供。
- 针对特定linux发行版修改日志函数：log (或者直接注释函数内容)
- 针对特定linux发行版修改wifi重连函数：reconnWifi (或者直接注释函数内容)
- 后台运行参考命令: `nohup sh alwaysOnline.sh > log.out 2>&1 &` 

#### 2. 路由器场景
- 将路由器刷至第三方固件 (本项目测试环境为斐讯K2的Padavan固件
- 进入路由器管理后台启用ssh (padavan启用ssh参考: 高级设置-系统管理-服务-启用SSH服务
- 使用sftp将本脚本及配置文件上传至`/etc/storage`目录下
- 配置`info.conf`文件，敏感信息暂不提供。
- 新建文件`run.sh`内容为`nohup ash /etc/storage/alwaysOnline.sh > /dev/null 2>&1 &`
- 运行`run.sh`脚本即可保持路由器自动联网
- [可选] 配置自启动：
    - padavan设置参考: 高级设置-自定义设置-脚本-在路由器启动后执行
    - 在末尾添加`/etc/storage/run.sh`
    - 至此，每次路由器启动后都会自动运行此脚本

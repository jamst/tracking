## 为什么写这个gem
  *使用cookie来追踪用户行为数据

## 安装使用
 ### 最佳版本要求：安装ruby 2.4.0 ; Rails 5.0.4 ; mysql ; git ; rvm
   * database.yml 配置from统计报表的数据源
   * bundle install
   * rake db:create
   * rake db:seed (默认账号: 107422244@qq.com 密码: 11111111)
   * rails s
   ```

 ### mac安装fluent
  https://docs.fluentd.org/v0.12/articles/install-by-dmg
  ```
  查看配置文件：
  /etc/td-agent/td-agent.conf
  ```
  日志文件：
  /var/log/td-agent/td-agent.log
  ```
  开启：
  sudo launchctl load /Library/LaunchDaemons/td-agent.plist
  ```
  关闭：
  sudo launchctl unload /Library/LaunchDaemons/td-agent.plist
  ```

 ### Linux下安装：
  http://www.cnblogs.com/hymenz/p/3670918.html
  redhat上运行如下命令即可。
  curl -L http://toolbelt.treasuredata.com/sh/install-redhat.sh | sh
  启动相关的服务/etc/init.d/td-agent start  
  ```

 ### 然后通过webHDFS接口，写入到hdfs文件系统中。
  http://shineforever.blog.51cto.com/1429204/1599771/ 
  ```



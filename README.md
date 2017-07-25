## 为什么写这个gem
  *使用cookie来追踪用户行为数据

## 安装使用
 ### 最佳版本要求：安装ruby 2.4.0 ; Rails 5.0.4 ; mysql ; git ; rvm
   * database.yml 配置from统计报表的数据源
   * bundle install
   * rake db:create
   * rake db:seed (默认账号: 107422244@qq.com 密码: 11111111)
   * rails s

 ### mac安装fluent
 ```ruby
  https://docs.fluentd.org/v0.12/articles/install-by-dmg
 ```
  *查看配置文件：
  ```ruby
  /etc/td-agent/td-agent.conf
  ```
  *日志文件：
  ```ruby
  /var/log/td-agent/td-agent.log
  ```
  *开启：
  ```ruby
  sudo launchctl load /Library/LaunchDaemons/td-agent.plist
  ```
  *关闭：
  ```ruby
  sudo launchctl unload /Library/LaunchDaemons/td-agent.plist
  ```
 ### Linux下安装：
 ```ruby
  http://www.cnblogs.com/hymenz/p/3670918.html
 ```

 ### 然后通过webHDFS接口，写入到hdfs文件系统中。
 ```ruby
  http://shineforever.blog.51cto.com/1429204/1599771/ 
 ```



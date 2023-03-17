
# 参考教程 https://www.jianshu.com/p/17676d34dd35


#########################################################################################################################
# 安装flink

# mac下通过brew就能安装
brew install apache-flink

# 查看flink 版本
flink --version

# brew安装的flink会放在 /usr/local/Cellar/apache-flink/
# 实际安装的是1.16.1版本，于是安装目录就是：/usr/local/Cellar/apache-flink/1.16.1
cd /usr/local/Cellar/apache-flink/1.16.1

# 配置flink参数
vi libexec/conf/flink-conf.yaml

# 修改flink-conf.yaml
<< EOF
taskmanager.numberOfTaskSlots: 1
rest.bind-address: 0.0.0.0
EOF

# 启动flink
./libexec/bin/start-cluster.sh
# 程序首次启动，mac会弹出防火墙提示，选择允许即可

# 停止flink（仅做记录，暂时先不要执行stop）
./libexec/bin/stop-cluster.sh

# 打开页面 http://localhost:8081/ 可以看到flink管理台


#########################################################################################################################
# 打包并运行JAR文件


# 根据教程创建程序，然后使用maven打包
mvn clean package -Dmaven.test.skip=true
# 生成的jar文件路径：/Users/yanyanjin/Study/FlinkStudy/FlinkQuickstartDemo1/target/FlinkQuickstartDemo1-1.0-SNAPSHOT.jar
# 这个jar文件中有几个main方法，运行的时候选择即可
#	SocketTextStreamWordCount.java
# 	StreamingJob.java
# 	BatchJob.java


# 开启9000端口监听给 SocketTextStreamWordCount.java 使用
nc -l 9000
# nc程序首次启动，mac又会弹出防火墙提示，选择允许即可
# nc 命令若在前台执行，则当前的命令行窗口就不能再使用了，需要切换一个新的命令行窗口继续执行命令


# 回到 /usr/local/Cellar/apache-flink/1.16.1 目录，在确保前面已经开启了 ./libexec/bin/start-cluster.sh 的前提下，运行
# 即把jar包提交给flink，并制定其中的main方法所在类（com.sethjin.SocketTextStreamWordCount）
bin/flink run -c com.sethjin.SocketTextStreamWordCount /Users/yanyanjin/Study/FlinkStudy/FlinkQuickstartDemo1/target/FlinkQuickstartDemo1-1.0-SNAPSHOT.jar 127.0.0.1 9000
# 这个命令一旦启动，命令若在前台运行，则当前窗口也不能再使用了
# 目前已有两个程序窗口在执行： nc（我称作”nc窗口“） + bin/flink run（我称作”flink run窗口“）


# 再打开一个新的窗口，或是用sublime等文本编辑器也可以，查看flink的log文件夹中的最新的文件，在我的电脑上就是
cat /usr/local/Cellar/apache-flink/1.16.1/libexec/log/flink-yanyanjin-taskexecutor-0-localhost.out
# 此时，可以尝试在”nc窗口“再输入一些词汇，然后再cat这个flink-yanyanjin-taskexecutor-0-localhost.out 文件，会看到文件内容在更新

# /usr/local/Cellar/apache-flink/1.16.1/libexec/log/flink-yanyanjin-taskexecutor-0-localhost.out 文件中文本内容形如：
<< EOF
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by org.jboss.netty.util.internal.ByteBufferUtil (file:/var/folders/sw/twhkn_f11xl2620jxcxb4wcm0000gn/T/flink-rpc-akka_9c9f3240-4ed7-4158-9f89-7076b6f534c9.jar) to method java.nio.DirectByteBuffer.cleaner()
WARNING: Please consider reporting this to the maintainers of org.jboss.netty.util.internal.ByteBufferUtil
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
(hello,1)
(hello,2)
(hello,3)
(hehe,1)
(your,1)
(world,1)
(hello,4)
(hello,5)
(hello,6)
(hahaha,1)
EOF

# 查看 localhost:8081，会看到当前一直存在一个”Running Jobs“

# 这时候，如果用Ctrl+C强制结束 ”nc窗口“，则切换回”flink run窗口“时会看到：”flink run窗口“中的程序也结束了
# 此时查看 localhost:8081，则会看到已经没有了"Running Jobs"，而是多了一个"Completed Jobs"
# 当前命令行应该是停留在”flink run窗口“，且flink run程序已结束，实验完毕，可以停止flink服务了
./libexec/bin/stop-cluster.sh

# flink服务停止，实验结束
















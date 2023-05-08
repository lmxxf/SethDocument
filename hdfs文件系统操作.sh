# 使用docker启动hadoop学习环境
# 文档 https://gitee.com/hadoop-bigdata/docker-compose-hadoop
git clone https://gitee.com/hadoop-bigdata/docker-compose-hadoop.git
cd docker-compose-hadoop/hadoop
# 开始部署
# 这里-f docker-compose.yaml可以省略，如果文件名不是docker-compose.yaml就不能省略，-d 后台执行
docker-compose -f docker-compose.yaml up -d
# 查看部署状态
docker-compose -f docker-compose.yaml ps



# 向hadoop-hdfs-nn上拷贝东西
# hadoop-hdfs-nn上运行，打开namenode权限
sudo mkdir -p /home/hadoop
sudo su - hadoop
export JAVA_HOME="/opt/apache/jdk1.8.0_212"
cd /opt/apache/hadoop
bin/hdfs dfs -chmod 777 /
# 在宿主机上拷贝文件
docker cp /Users/yanyanjin/Downloads/zipkin-server-2.9.4-exec.jar hadoop-hdfs-nn:/opt/apache/hadoop/seth-test





################################################################################################################################################
# 文件系统格式化
bin/hdfs namenode -format

# 显示当前hdfs文件系统信息
hdfs dfsadmin -report


# 查看 HDFS 根目录下的内容：
hdfs dfs -ls /

# 查看指定目录下的内容
hdfs dfs -ls /user/<your-username>


# 创建目录
hdfs dfs -mkdir /user/<your-username>/new-directory

# 上传本地文件到 HDFS
hdfs dfs -put local-file.txt /user/<your-username>/remote-directory/

# 从 HDFS 下载文件到本地
hdfs dfs -get /user/<your-username>/remote-directory/remote-file.txt local-file.txt

# 删除 HDFS 上的文件或目录
hdfs dfs -rm -r /user/<your-username>/remote-directory


# 查看 HDFS 上的文件内容
hdfs dfs -cat /user/<your-username>/remote-directory/remote-file.txt

# 查看 HDFS 的使用情况和剩余空间
hdfs dfsadmin -report








# 参考文章 
# https://blog.csdn.net/weixin_47491957/article/details/124239566
# https://juejin.cn/post/7067827047921352741

# 基于centos安装
# 安装epel-release
yum install -y epel-release
# 基本工具
yum install -y net-tools
yum install -y vim
# 编辑普通用户使用root的权限
vim /etc/sudoers
# 安装java环境
# rpm -qa  | grep -i java | xargs -n1 rpm -e --nodeps
# https://segmentfault.com/a/1190000039693252
yum install -y java-1.8.0-openjdk
java -version
find / -name 'java'

# 在已配置好的机器上直接clone三台主机
# 修改主机名和ip地址
# 主机名（master+slave1+slave2)
vi /etc/hostname
# 配置ip地址（可选）
vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
<<EOF
BOOTPROTO="static"
IPADDR=192.168.10.100
GATEWAY=192.168.10.2
DNS1=192.168.10.2
EOF

# 登录到 master/slave1/slave2
# 全都关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

# 登录到 master/slave1/slave2
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
ssh-copy-id root@master
ssh-copy-id root@slave1
ssh-copy-id root@slave2
# 重启 slave1/slave2之后，master应该可以无密码登录slave1/slave2

# hadoop
# 登录到 master
mkdir -p /opt/module
cd /opt/module

# 可以使用代理服务器
# export https_proxy=http://SethDeMacbook2023:7890 http_proxy=http://SethDeMacbook2023:7890 all_proxy=socks5://SethDeMacbook2023:7890

wget https://archive.apache.org/dist/hadoop/common/hadoop-3.1.3/hadoop-3.1.3.tar.gz
tar -zxvf hadoop-3.1.3.tar.gz -C /opt/module/
# 登录到 slave1, slave2
mkdir -p /opt/module
# 登录到 master
scp hadoop-3.1.3.tar.gz root@slave1:/opt/module
scp hadoop-3.1.3.tar.gz root@slave2:/opt/module


# 登录到 master
vi /root/.bash_profile
# 加入脚本
<<EOF
export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64"

HADOOP_HOME=/opt/module/hadoop-3.1.3
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export HADOOP_CLASSPATH=`hadoop classpath`
EOF

cd /opt/module/hadoop-3.1.3/etc/hadoop/
vi core-site.xml

<<EOF
<!-- namenode地址端口-->
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://master:8020</value>
</property>
<!-- 数据存储目录-->
<property>
    <name>hadoop.data.dir</name>
    <value>/opt/module/hadoop-3.1.3/data</value>
</property>
<property>
    <name>hadoop.proxyuser.root.hosts</name>
    <value>*</value>
</property>
<property>
    <name>hadoop.proxyuser.root.groups</name>
    <value>*</value>
</property>
EOF

vi hdfs-site.xml

<<EOF
<!-- nn web端访问地址-->
<property>
  <name>dfs.namenode.http-address</name>
  <value>master:9870</value>
</property>
<property>
  <name>dfs.namenode.name.dir</name>
  <value>file://${hadoop.data.dir}/name</value>
</property>
<property>
  <name>dfs.datanode.data.dir</name>
  <value>file://${hadoop.data.dir}/data</value>
</property>
<!--主节点的元数据备份地址-->
<property>
  <name>dfs.namenode.checkpoint.dir</name>
  <value>file://${hadoop.data.dir}/namesecondary</value>
</property>
  <property>
  <name>dfs.client.datanode-restart.timeout</name>
  <value>30</value>
</property>
<property>
  <name>dfs.namenode.secondary.http-address</name>
  <value>slave2:9868</value>
</property>
EOF

vi yarn-site.xml
<<EOF
<!-- 指定MR走shuffle -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
  <!-- 指定ResourceManager的地址-->
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>slave1</value>
    </property>
  <!-- 环境变量的继承 -->
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
<value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
    </property>
  <!-- yarn容器允许分配的最大最小内存 -->
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>512</value>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>4096</value>
    </property>
    <!-- yarn容器允许管理的物理内存大小 -->
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>4096</value>
    </property>
    <!-- 关闭yarn对虚拟内存的限制检查 -->
    <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
    </property>
EOF

vi mapred-site.xml

<<EOF
	<!-- 指定MapReduce程序运行在Yarn上 -->
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
EOF

vi /opt/module/hadoop-3.1.3/etc/hadoop/hadoop-env.sh
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64


vi /opt/module/hadoop-3.1.3/etc/hadoop/workers

<<EOF
master
slave1
slave2
EOF

# 两个文件都改(最后确保在master上必须改过)
vi /opt/module/hadoop-3.1.3/sbin/start-dfs.sh
vi /opt/module/hadoop-3.1.3/sbin/stop-dfs.sh

<<EOF
HDFS_DATANODE_USER=root 
HADOOP_SECURE_DN_USER=hdfs 
HDFS_NAMENODE_USER=root 
HDFS_SECONDARYNAMENODE_USER=root
EOF

# 两个文件都改(最后确保在slave1上必须改)
vi /opt/module/hadoop-3.1.3/sbin/start-yarn.sh
vi /opt/module/hadoop-3.1.3/sbin/stop-yarn.sh

<<EOF
YARN_RESOURCEMANAGER_USER=root
HADOOP_SECURE_DN_USER=yarn
YARN_NODEMANAGER_USER=root
EOF


# 将maste上的hadoop拷贝到slave1/slave2
cd /opt/module
scp -r hadoop-3.1.3/ root@slave1:/opt/module
scp -r hadoop-3.1.3/ root@slave2:/opt/module

# cd /opt/module/hadoop-3.1.3 
# scp -r sbin/ root@slave1:/opt/module/hadoop-3.1.3/ 
# scp -r sbin/ root@slave2:/opt/module/hadoop-3.1.3/ 

# cd /opt/module/hadoop-3.1.3/etc/
# scp -r hadoop/ root@slave1:/opt/module/hadoop-3.1.3/etc/ 
# scp -r hadoop/ root@slave2:/opt/module/hadoop-3.1.3/etc/ 

# 首次启动格式化namenode（仅master上）
cd /opt/module/hadoop-3.1.3/
bin/hdfs namenode -format

# 登录到 master：在master上启动 hdfs
cd /opt/module/hadoop-3.1.3/
sbin/start-dfs.sh

# 登录到 slave1：在slave1上启动 yarn
cd /opt/module/hadoop-3.1.3/
sbin/start-yarn.sh

# 检查 hdfs 和 yarn 是否正常
# hdfs为 http://master:8020
# slave1:9866 (192.168.31.183:9866)	http://slave1:9864	0s	6m	49.98 GB 0	8 KB (0%)	3.1.3
# slave2:9866 (192.168.31.118:9866)	http://slave2:9864	0s	0m	49.98 GB 0	8 KB (0%)	3.1.3

# yarn为 http://slave1::8088
# /default-rack	RUNNING	slave2:40383	slave2:8042	Sun Mar 26 19:17:24 +0800 2023		0		0 B	4 GB	0	8	3.1.3
# /default-rack	RUNNING	master:41650	master:8042	Sun Mar 26 19:16:43 +0800 2023		0		0 B	4 GB	0	8	3.1.3
# /default-rack	RUNNING	slave1:46747	slave1:8042	Sun Mar 26 19:17:01 +0800 2023		0		0 B	4 GB	0	8	3.1.3



# 开始配置 flink（仅在 master 上执行）
cd /opt/module
wget https://dlcdn.apache.org/flink/flink-1.15.4/flink-1.15.4-bin-scala_2.12.tgz
tar zxvf flink-1.15.4-bin-scala_2.12.tgz
mv flink-1.15.4 flink-1.15.4-yarn
cd flink-1.15.4-yarn

vi conf/flink-conf.yaml
<<EOF
jobmanager.memory.process.size: 1024m
taskmanager.memory.process.size: 2048m
taskmanager.numberOfTaskSlots: 2
parallelism.default: 1
EOF

vi conf/workers
<<EOF
master
slave1
slave2
EOF

bin/yarn-session.sh -nm test


# 最后查看 master/slave1/slave2 上的java进程
# 更多解释：https://lvxueyang.vip/post/286e9c8d.html

# hdfs: 主NameNode - 从DataNode（主备SecondaryNameNode）
# Yarn资源: 主ResourceManager - 从NodeManager
# Yarn调度: YarnSessionClusterEntrypoint - YarnTaskExecutorRunner
# Flink: FlinkYarnSessionCli


# @master jps
<<EOF
3599 NameNode
3801 DataNode
5979 NodeManager
10783 YarnTaskExecutorRunner
10366 FlinkYarnSessionCli
10973 Jps
EOF

# @Slave1 jps
<<EOF
1823 DataNode
2172 ResourceManager
2907 NodeManager
5038 YarnSessionClusterEntrypoint
5354 Jps
EOF

# @Slave2 jps
<<EOF
1900 DataNode
2255 NodeManager
2006 SecondaryNameNode
13896 YarnTaskExecutorRunner
14045 Jps
EOF




















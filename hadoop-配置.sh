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
export https_proxy=http://SethDeMacbook2023:7890 http_proxy=http://SethDeMacbook2023:7890 all_proxy=socks5://SethDeMacbook2023:7890

wget https://archive.apache.org/dist/hadoop/common/hadoop-3.1.3/hadoop-3.1.3.tar.gz
tar -zxvf hadoop-3.1.3.tar.gz -C /opt/module/
# 登录到 slave1, slave2
mkdir -p /opt/module
# 登录到 master
scp hadoop-3.1.3.tar.gz root@slave1:/opt/module
scp hadoop-3.1.3.tar.gz root@slave2:/opt/module


# 登录到 master
vim /root/.bash_profile
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

# 两个文件都改
vi /opt/module/hadoop-3.1.3/sbin/start-dfs.sh
vi /opt/module/hadoop-3.1.3/sbin/stop-dfs.sh

<<EOF
HDFS_DATANODE_USER=root 
HADOOP_SECURE_DN_USER=hdfs 
HDFS_NAMENODE_USER=root 
HDFS_SECONDARYNAMENODE_USER=root
EOF

# 两个文件都改
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
# yarn为 http://slave1::8088




























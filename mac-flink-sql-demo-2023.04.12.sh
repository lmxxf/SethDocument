# 启动flink
cd /usr/local/Cellar/apache-flink/1.16.1
./libexec/bin/start-cluster.sh


# 启动flink-sql-client
./libexec/bin/sql-client.sh embedded


# 在提示符中输入
<<EOF
CREATE TEMPORARY TABLE input (
  id INT,
  name STRING,
  age INT
) WITH (
  'connector' = 'filesystem',
  'path' = 'file:///Users/yanyanjin/Study/FlinkStudy/FlinkQuickstartDemo1/src/main/resources/input.csv',
  'format' = 'csv'
);
EOF


# 输入SELECT后，表格信息将展示在一个类似于只读的文字编辑器中
<<EOF
SELECT id, name, age + 1 as age_plus_one FROM input;
EOF

# 或其它语句
<<EOF
SELECT id, name, age
FROM input
WHERE age > 25;
EOF
<<EOF
SELECT age, COUNT(*) as person_count
FROM input
GROUP BY age;
EOF


# csv文件
# 路径为: /Users/yanyanjin/Study/FlinkStudy/FlinkQuickstartDemo1/src/main/resources/input.csv
# 内容为:
<<EOF
1,Alice,30
2,Bob,28
3,Charlie,22
EOF

# 最后退出sql-client
<<EOF
EXIT;
# 或者
QUIT;
EOF
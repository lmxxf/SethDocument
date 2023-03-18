
# 教程 https://colobu.com/2019/09/27/install-Kafka-on-Mac/

# 安装 kafka + zookeeper
brew install kafka

# brew会自动安装其依赖”Fetching dependencies for kafka: glib and zookeeper“
# 故不需要再执行 `brew install zookeeper`

vi /usr/local/etc/kafka/server.properties

# 编辑 server.properties，只需要加入listeners这一行（默认状态下是注没有的）
<< EOF
listeners = PLAINTEXT://localhost:9092
EOF

# 将zookeeper和kafka以服务的形式启动
<< EOF
brew services start zookeeper
brew services start kafka
EOF

# mac会弹出提示，表示有新任务加入到启动项，此时，查看 `设置 --> 通用 --> 登录项`，会看到：
# /usr/local/Cellar/kafka/3.4.0/bin/kafka-server-start 和 /usr/local/Cellar/zookeeper/3.8.1/bin/zkServer 已加入到启动项中
# 因此，若不想让这两个程序长期运行，可以采用临时启动的方式运行这两个程序
<< EOF
zkServer start
kafka-server-start /usr/local/etc/kafka/server.properties
EOF
# zookeeper不会占据当前命令行窗口，但是kafka程序会占据命令行窗口前台运行，这时就需要切换一个新的窗口
# zookeeper占据

# 由于kafka 3.0之后，以不再依赖zookeper（内置），故只需要启动kafka本身即可
# 参考资料：https://cloud.tencent.com/developer/article/1892086
kafka-server-start /usr/local/etc/kafka/server.properties


# 教程中的执行kafka的命令中 `--zookeeper`参数已经deprecated了，最新版kafka（3.4.0）使用`--bootstrap-server`
# 参考资料：https://stackoverflow.com/questions/53428903/zookeeper-is-not-a-recognized-option-when-executing-kafka-console-consumer-sh
# 教程中的这个命令执行将会出错：
# kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test


# kafka测试
# 1. 创建名为 "SethTestTopicA" 的kafka-topic
kafka-topics --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic SethTestTopicA
# 若执行成功则提示 "Created topic SethTestTopicA."

# 2. 启动在"SethTestTopicA"的topic消费命令
kafka-console-consumer --bootstrap-server localhost:9092 --topic SethTestTopicA --from-beginning
# 此时命令行窗口会进入等待状态（称为"consumer窗口"）。继续输入命令需要切换到新的窗口

# 3. 启动在"SethTestTopicA"的topic生产命令
kafka-console-producer --broker-list localhost:9092 --topic SethTestTopicA
# 此时命令行窗口会进入等待状态（称为"producer窗口"），此窗口用户等待用户输入文字。继续输入命令需要切换到新的窗口

# 这时存在两个窗口："producer窗口" 和 "consumer窗口"
# 若在"producer窗口"输入
<< EOF
>aaa bbb
>ccc ddd
>
EOF
# 则立刻会在"consumer窗口"输出
<< EOF
aaa bbb
ccc ddd

EOF

# Ctrl+C 结束掉 "producer窗口" 和 "consumer窗口"，实验完毕






#########################################################################################################
# 额外测试：通过WordCount的kafaka streams程序，读取 SethTestTopicA(生产端Topic) 中输入的词汇，做WordCount统计，然后输出到 WordCountOutput(消费端Topic)

# 生产端 （SethTestTopicA）
kafka-console-producer --broker-list localhost:9092 --topic SethTestTopicA

# 消费端（WordCountOutput）
kafka-console-consumer --bootstrap-server localhost:9092 --topic WordCountOutput --from-beginning --property print.key=true --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer

# 生产端 (SethTestTopicA) --> 消费端（WordCountOutput）转换的 Kafka Streams 程序（统计字符数）
<< EOF
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.*;

import java.util.Arrays;
import java.util.Properties;

public class KafkaStreamsDemo {

    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "word-count");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        StreamsBuilder builder = new StreamsBuilder();
        KStream<String, String> source = builder.stream("SethTestTopicA");
        source.foreach((key, value) ->
                System.out.println("input: key=" + key + ", value=" + value)
        );

        KTable<String, Long> counts = source
                .flatMapValues(value ->
                        Arrays.asList(value.toLowerCase().split("\\W+"))
                )
                .groupBy((key, value) ->
                        value
                )
                .count(
                        Materialized.as("word-counts")
                );
        counts.toStream().foreach((key, value) ->
                System.out.println("output: key=" + key + ", value=" + value)
        );
        counts.toStream().to("WordCountOutput", Produced.with(Serdes.String(), Serdes.Long()));

        KafkaStreams streams = new KafkaStreams(builder.build(), props);
        streams.start();
    }
}
EOF

# 在生产端输入
<<EOF
>ddd eee zzz
>hello my kafka
>ddd eee
EOF

# 则会看到在消费端输出（中间等待了很久，在我的mac上，大概20秒后，才输出）
<<EOF
ddd	8
eee	2
zzz	4
hello	6
my	2
kafka	1
ddd	9
eee	3
EOF








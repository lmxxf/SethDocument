
# 直接在idea里以local方式执行这段flink程序，即统计 SethTestTopicA 这个topic中的输入，然后输出到另一个名为 FlinkWordCountOutput 的topic
<<EOF
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.java.functions.KeySelector;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaConsumer;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaProducer;
import org.apache.flink.streaming.util.serialization.SimpleStringSchema;
import org.apache.flink.util.Collector;
import java.util.Properties;

public class KafkaWordCount {
    public static void main(String[] args) throws Exception {
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // 设置 Kafka 消费者的配置
        Properties consumerProps = new Properties();
        consumerProps.setProperty("bootstrap.servers", "localhost:9092");
        consumerProps.setProperty("group.id", "flink-group");

        // 设置 Kafka 生产者的配置
        Properties producerProps = new Properties();
        producerProps.setProperty("bootstrap.servers", "localhost:9092");

        // 从 Kafka 中读取数据
        FlinkKafkaConsumer<String> kafkaConsumer = new FlinkKafkaConsumer<>("SethTestTopicA", new SimpleStringSchema(), consumerProps);
        DataStream<String> dataStream = env.addSource(kafkaConsumer);

        // 计算单词出现次数
        DataStream<Tuple2<String, Integer>> wordCountStream = dataStream
                .flatMap(new FlatMapFunction<String, Tuple2<String, Integer>>() {
                    @Override
                    public void flatMap(String value, Collector<Tuple2<String, Integer>> out) throws Exception {
                        String[] words = value.toLowerCase().split("\\W+");
                        for (String word : words) {
                            if (word.length() > 0) {
                                out.collect(new Tuple2<>(word, 1));
                            }
                        }
                    }
                })
                .keyBy((KeySelector<Tuple2<String, Integer>, String>) value ->
                        value.f0
                )
                .sum(1);

        // 将结果写入到 Kafka 中
        FlinkKafkaProducer<String> kafkaProducer = new FlinkKafkaProducer<>("FlinkWordCountOutput", new SimpleStringSchema(), producerProps);
        wordCountStream.map(tuple -> tuple.f0 + ": " + tuple.f1).addSink(kafkaProducer);

        env.execute("Word Count Job");
    }
}
EOF


# 创建输出topic
kafka-topics --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic FlinkWordCountOutput


# 在terminal中消费 "输出topic"
kafka-console-consumer --bootstrap-server localhost:9092 --topic FlinkWordCountOutput --from-beginning



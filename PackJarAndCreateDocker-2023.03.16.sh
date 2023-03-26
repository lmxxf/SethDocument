
# 打包前必须针对springboot加入maven插件spring-boot-maven-plugin加入到build/plugins里面
# 这个工程名叫 "spring-dao-lession-61-1.0-SNAPSHOT"
<< EOF
<build>
	<plugins>
		<plugin>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-maven-plugin</artifactId>
			<!--这里写上main方法所在类的路径-->
			<configuration>
			<mainClass>com.sethjin.MyApplication</mainClass>
			</configuration>
		</plugin>
	</plugins>
</build>
EOF


# mac上必须安装maven
brew install maven

# 打包出jar文件
mvn clean package


# 配置Dockerfile
<< EOF
FROM openjdk:11
ADD spring-dao-lession-61-1.0-SNAPSHOT.jar /docker-test.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/docker-test.jar"]
EOF

# 把Jar和Dockerfile一起放在同一目录下，
docker build -t java-app .


# 运行docker
docker run -p 127.0.0.1:8080:8080 java-app


# 访问浏览器的 localhost:8080


FROM        debian:buster
RUN         apt-get update \
            && apt-get install -y default-jre \
            && apt-get clean \
            && rm -fr /var/lib/apt/lists/*

COPY        jenkins-cli.jar /

ENTRYPOINT  ["java", "-jar", "/jenkins-cli.jar"]

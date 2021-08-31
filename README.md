# spring-boot-helloworld-for-k8s

[![Build Status](https://app.travis-ci.com/cybermaniax/spring-boot-helloworld-for-k8s.svg?branch=main)](https://app.travis-ci.com/cybermaniax/spring-boot-helloworld-for-k8s)

Sample solution containing: 
* Spring boot
  * Enabled Prometeus endpoint
  * Expose liveness and readiness
  * Change management port
* Dockerfile
  * User layered jar
  * Container base on _gcr.io/distroless/java_

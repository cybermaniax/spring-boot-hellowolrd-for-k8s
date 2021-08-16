package pl.coi.gov.demo.demohelloworld

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication


@SpringBootApplication
class DemoHelloworldApplication

fun main(args: Array<String>) {
	runApplication<DemoHelloworldApplication>(*args)
}

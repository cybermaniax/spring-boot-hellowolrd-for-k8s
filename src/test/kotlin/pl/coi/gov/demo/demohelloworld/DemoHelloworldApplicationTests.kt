package pl.coi.gov.demo.demohelloworld

import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class DemoHelloworldApplicationTests {

	@Autowired
	lateinit var component:HelloWorldHandler

	@Test
	fun msg() {
		assertTrue(component.helloWorld(mapOf( "t" to "t")).contains("Hello World!"))
	}

}

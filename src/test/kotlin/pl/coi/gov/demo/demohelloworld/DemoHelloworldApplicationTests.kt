package pl.coi.gov.demo.demohelloworld

import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class DemoHelloworldApplicationTests {

	@Autowired
	lateinit var component:HelloWorldHandler

	@Test
	fun msg() {
		assertEquals("Hello World!",
			component.helloWorld(mapOf( "t" to "t")))
	}

}

package pl.coi.gov.demo.demohelloworld

import mu.KotlinLogging
import org.springframework.beans.factory.annotation.Value
import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RestController

private val logger = KotlinLogging.logger {}
/**
 *  @author Grzegorz Hałajko <ghalajko@gmail.com>
 */
@RestController
class HelloWorldHandler {

    @Value("\${helloworld.msg}")
    lateinit var msg:String

    @GetMapping(path = ["/test"], produces = [MediaType.TEXT_PLAIN_VALUE])
    fun helloWorld(@RequestHeader headers:Map<String, String>): String {
        logger.info( "msg={} , header={}", msg , headers)
        return msg;
    }
}

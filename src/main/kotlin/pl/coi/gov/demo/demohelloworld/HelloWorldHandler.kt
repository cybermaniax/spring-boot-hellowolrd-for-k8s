package pl.coi.gov.demo.demohelloworld

import mu.KotlinLogging
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.cloud.sleuth.Span
import org.springframework.cloud.sleuth.Tracer
import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RestController
import kotlin.random.Random

private val logger = KotlinLogging.logger {}
/**
 *  @author Grzegorz Hałajko <ghalajko@gmail.com>
 */
@RestController
class HelloWorldHandler {

    @Value("\${helloworld.msg}")
    lateinit var msg:String

    @Autowired(required = false)
    lateinit var tracer:Tracer

    @GetMapping(path = ["/test"], produces = [MediaType.TEXT_PLAIN_VALUE])
    fun helloWorld(@RequestHeader headers:Map<String, String>): String {
        var span: Span? = null
        if (::tracer.isInitialized){
            span = tracer.nextSpan().start()
        }

        var message = "${msg} : ${Random.nextInt()}";
        Thread.sleep(Random.nextLong(100,1000));
        logger.info( "msg={} , header={}", message , headers)

        span?.tag("msg", message)?.end()
        return message;
    }
}

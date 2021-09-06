package pl.coi.gov.demo.demohelloworld

import mu.KotlinLogging
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.cloud.sleuth.annotation.NewSpan
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.core.PreparedStatementSetter
import org.springframework.jdbc.core.RowCallbackHandler
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.sql.PreparedStatement

private val logger = KotlinLogging.logger {}

@RestController
class CountryHandler {

    @Autowired
    lateinit var jdbcTemplate: JdbcTemplate

    @NewSpan
    @GetMapping(path = ["/test/country/{id}"], produces = [MediaType.TEXT_PLAIN_VALUE])
    fun get(@PathVariable("id") id:Int): ResponseEntity<String> {
        logger.info("GET {}", id)
        var exist:Boolean = false
        var value:String = ""
        jdbcTemplate.query("SELECT name FROM country WHERE id = ?", PreparedStatementSetter(){
            it.setInt(1, id)
        } , RowCallbackHandler(){
            value = it.getString(1)
            exist = true
        })

        if(exist)
            return ResponseEntity.ok(value)
        else
            return ResponseEntity.notFound().build()
    }

    @NewSpan
    @GetMapping(path = ["/test/country"], produces = [MediaType.TEXT_PLAIN_VALUE])
    fun list(): ResponseEntity<StringBuilder> {
        logger.info("list")
        var exist:Boolean = false
        var value:StringBuilder = StringBuilder()
        jdbcTemplate.query("SELECT id,name FROM country", RowCallbackHandler(){
            value.append(it.getString(1)).append(',')
            value.append(it.getString(2)).append(',')
            value.append('\n')
            exist = true
        })

        if(exist)
            return ResponseEntity.ok(value)
        else
            return ResponseEntity.notFound().build()
    }

    @NewSpan
    @PostMapping(path = ["/test/country"], produces = [MediaType.TEXT_PLAIN_VALUE])
    fun post(@RequestParam("name") name:String): ResponseEntity<Void> {
        logger.info("post {}", name)

        jdbcTemplate.update("INSERT INTO country(name) VALUES (?)", PreparedStatementSetter(){
            it.setString(1, name)
        })

        return ResponseEntity.status(HttpStatus.CREATED).build()
    }
}
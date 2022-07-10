package br.com.tokunaga.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppController {

    @GetMapping(value = "/app")
    public String send() {
        return "Hi";
    }
}
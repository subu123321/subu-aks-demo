package com.example;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class GreetingTest {

    @Test
    void defaultGreeting() {
        assertEquals("Hello, World!", Greeting.message(null));
        assertEquals("Hello, World!", Greeting.message("  "));
    }

    @Test
    void namedGreeting() {
        assertEquals("Hello, AKS!", Greeting.message(" AKS "));
    }
}

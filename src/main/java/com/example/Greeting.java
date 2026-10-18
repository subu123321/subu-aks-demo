package com.example;

public class Greeting {

    private Greeting() {
    }

    public static String message(String name) {
        if (name == null || name.isBlank()) {
            return "Hello, World!";
        }
        return "Hello, " + name.trim() + "!";
    }
}

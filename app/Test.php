<?php

class Test {
    public function foo(): string {
        return 123; // ❌ invalid return type (int returned, string expected)
    }
}

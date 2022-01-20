<?php

namespace App;

class Git
{
    static function directory(string $path): string
    {
        return __DIR__ . '/../' . $path;
    }
}

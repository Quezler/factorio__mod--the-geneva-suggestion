<?php

namespace App;

class InfoJson
{
    public static function setVersion($file, $version)
    {
        $contents = json_decode(file_get_contents($file));
        $contents->version = $version;
        file_put_contents($file, json_encode($contents, JSON_PRETTY_PRINT));
    }
}

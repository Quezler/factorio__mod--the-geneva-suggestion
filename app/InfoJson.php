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

    public static function optional_dependencies($file)
    {
        return collect(json_decode(file_get_contents($file))->dependencies)
            ->filter(function ($dependency) {
                return str_starts_with($dependency, '? ');
            })
            ->map(function ($dependency) {
                $bits = explode(' ', $dependency);
                return $bits[1] ?? $bits[0];
            })
            ->sort()
            ->toArray()
        ;
    }
}

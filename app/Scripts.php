<?php

namespace App;

use Symfony\Component\Finder\Finder;

class Scripts
{
    public static function optimize(string $staging)
    {
        foreach ((new Finder())->in("{$staging}/scripts")->files() as $lua) {
            $contents = file_get_contents($lua);

            preg_match_all('/defines\.([a-z_\.]+)/', $contents, $matches);
            $defines = collect($matches[0])->sortByDesc(function($string) {
                return strlen($string);
            })->unique();

            $prepend = [];

            foreach ($defines as $define) {
                $const = str_replace('.', '__', strtoupper($define));
                $prepend[] = "local {$const} = $define";
                $contents = str_replace($define, $const, $contents);
            }

            file_put_contents($lua, implode(' ', $prepend) . ' ' . $contents);
        }
    }
}

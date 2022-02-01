<?php

namespace App;

use Symfony\Component\Finder\Finder;

class Patches
{
    public static function compile(string $staging)
    {
        foreach ((new Finder)->in('patches')->files() as $lua) {
            $lines = explode(PHP_EOL, file_get_contents($lua));

            $append_to = null;
            foreach ($lines as $line) {
                if(preg_match('/--\s(.*\.lua)/', $line)) {
                    $append_to = preg_replace('/--\s(.*\.lua)/', '$1', $line);
                    continue;
                }

                if($append_to) {
                    file_put_contents("{$staging}/{$append_to}", "$line\n", FILE_APPEND);
                    continue;
                }
            }
        }
    }
}

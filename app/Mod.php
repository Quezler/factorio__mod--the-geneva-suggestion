<?php

namespace App;

use Symfony\Component\Finder\Finder;

class Mod
{
    /**
     * @var string
     */
    public $name;

    public function __construct(string $name)
    {
        $this->name = $name;
    }

    public function build(string $version): string
    {
        $name = $this->name . '_' . $version;
        $staging = Git::directory('./build/' . $this->name . '_' . $version);

        if (is_dir($staging)) exec(sprintf('rm -r %s', $staging));
        exec(sprintf('cp -R %s %s', Git::directory('./zip'), $staging));

        InfoJson::setVersion("{$staging}/info.json", $version);
        Patches::compile($staging);
        Scripts::optimize($staging);

        if(file_exists($old_zip = "{$staging}.zip")) unlink($old_zip);
        exec(sprintf('(cd %s && zip -r %s %s)', Git::directory('./build'), "$name.zip", $name));

        exec(sprintf('rm -r %s', $staging));

        return $name;
    }

    public function optional_dependencies(): array
    {
        $mods = [];
        foreach ((new Finder)->in(['zip', 'patches'])->files()->contains('mods[') as $lua) {
            preg_match_all('/mods\["(.+)"]/U', file_get_contents($lua), $matches);
            foreach ($matches[1] as $match) {
                $mods[$match] = true;
            }
        }
        $mods = array_keys($mods);
        sort($mods);
        return $mods;
    }
}

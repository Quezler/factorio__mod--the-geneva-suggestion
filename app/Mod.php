<?php

namespace App;

use GuzzleHttp\Client;

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
        exec(sprintf('cp -R %s %s', Git::directory('./src'), $staging));

        InfoJson::setVersion("{$staging}/info.json", $version);

        exec(sprintf('(cd %s && zip -r %s %s)', Git::directory('./build'), "$name.zip", $name));
        exec(sprintf('rm -r %s', $staging));

        return "$staging.zip";
    }
}

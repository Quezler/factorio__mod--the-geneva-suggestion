<?php

namespace App;

class Mod
{
    /**
     * @var string
     */
    private $name;

    public function __construct(string $name)
    {
        $this->name = $name;
    }

    public static function version(): string
    {
        return '1.0.0';
    }

    public function build(): string
    {
        $name = $this->name . '_' . self::version();
        $staging = Git::directory('./build/' . $this->name . '_' . self::version());

        if (is_dir($staging)) {
            // manually unzipped the mod?
            exec(sprintf('rm -r %s', $staging));
        }

        exec(sprintf('cp -R %s %s', Git::directory('./src'), $staging));
        exec(sprintf('(cd %s && zip -r %s %s)', Git::directory('./build'), "$name.zip", $name));

        exec(sprintf('rm -r %s', $staging));

        return "$staging.zip";
    }
}

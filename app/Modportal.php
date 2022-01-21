<?php

namespace App;

use GuzzleHttp\Client;
use PHLAK\SemVer\Version;

class Modportal
{
    private Client $guzzle;
    private array $fulls = [];

    public function __construct()
    {
        $this->guzzle = new Client();
    }

    public function full(Mod $mod)
    {
        return $this->fulls[$mod->name] ?? $this->fulls[$mod->name] = json_decode($this->guzzle->get("https://mods.factorio.com/api/mods/{$mod->name}/full")->getBody()->getContents());
    }

    public function version(Mod $mod): Version
    {
        return new Version($this->full($mod)->releases[0]->version);
    }
}

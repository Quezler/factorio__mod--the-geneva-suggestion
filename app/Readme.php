<?php

namespace App;

use Illuminate\Support\Arr;
use Symfony\Component\Finder\Finder;

class Readme
{
    public static function updateFeatures()
    {
        $features = [];

        foreach ((new Finder)->in('patches')->files() as $lua) {
            $lines = explode(PHP_EOL, file_get_contents($lua));
            dump($lua->getFilename());

            foreach ($lines as $line) {
                preg_match('/-- @feature (.*)/', $line, $feature);
                if (sizeof($feature) > 0) {
                    $breadcrumbs = $lua->getRelativePath() == "" ? ["*"] : explode('/', $lua->getRelativePath());

                    $siblings = Arr::get($features, $key = implode(' + ', $breadcrumbs), []);
                    $siblings[] = $feature[1];
                    Arr::set($features, $key, $siblings);
                }
            }
        }

        $features = collect($features)->sortKeys()->toArray();

        dump($features);

        $markdown = [];
        $markdown[] = '';
        $markdown[] = 'These optional features are active when each +\'d mod is loaded:';
        $markdown[] = '';
        foreach ($features as $modcombo => $lines) {
            $markdown[] = "### {$modcombo}";
            foreach ($lines as $line) {
                $markdown[] = "- $line";
            }
            $markdown[] = '';
        }

        $md = file_get_contents(Git::directory('README.md'));
        $md = preg_replace('/(.*##\sFeatures\n)(.*)(\n##\s.*)/msU', '$1'. implode(PHP_EOL, $markdown) .'$3', $md);
        file_put_contents(Git::directory('README.md'), $md);
    }
}

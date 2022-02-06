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
            foreach ($lines as $line) {
                preg_match('/-- @feature (.*)/', $line, $feature);
                if (sizeof($feature) > 0) {
                    $breadcrumbs = $lua->getRelativePath() == "" ? ["*"] : explode('/', $lua->getRelativePath());

                    $siblings = Arr::get($features, $key = implode(' + ', $breadcrumbs), []);
                    $siblings[] = 'data: '. $feature[1];
                    Arr::set($features, $key, $siblings);
                }
            }
        }

        foreach ((new Finder)->in('zip/scripts')->files() as $lua) {
            $lines = explode(PHP_EOL, file_get_contents($lua));
            foreach ($lines as $line) {
                preg_match('/-- @feature (.*)/', $line, $feature);
                if (sizeof($feature) > 0) {
                    $features['*'][] = 'script: '.$feature[1];
                }
            }
        }

        preg_match_all('/commands\.add_command\("([a-z-]+)", "- (.*)."/U', file_get_contents(Git::directory('zip/control.lua')), $commands);
        foreach ($commands[1] as $i => $command) {
            $features['*'][] = "command: {$command} (". strtolower($commands[2][$i]) .")";
        }

        $features = collect($features)->sortKeys()->toArray();


        $markdown = [];
        $markdown[] = '';
        $markdown[] = 'These optional features are active when each +\'d mod is loaded:';
        $markdown[] = '';
        foreach ($features as $modcombo => $lines) {
            if ($modcombo == "*") $modcombo = "(always)";
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

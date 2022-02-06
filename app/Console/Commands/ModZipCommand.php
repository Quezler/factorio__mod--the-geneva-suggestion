<?php

namespace App\Console\Commands;

use App\Git;
use App\InfoJson;
use App\Mod;
use App\Modportal;
use App\Readme;
use LogicException;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ModZipCommand extends Command
{
    protected static $defaultName = 'mod:zip';

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $portal = new Modportal();
        $mod = new Mod('the-geneva-suggestion');

        {
            $a = $mod->optional_dependencies();
            $b = InfoJson::optional_dependencies(Git::directory('./zip/info.json'));

            if(count($diff = array_diff($a, $b))) {
                throw new LogicException("'? ' missing for these mods: " . implode(', ', $diff));
            }

            if(count($diff = array_diff($b, $a))) {
                throw new LogicException("'? ' useless for these mods: " . implode(', ', $diff));
            }
        }

        $version = $portal->version($mod);

        $name_version = $mod->build($version->incrementPatch());
        $zip = Git::directory("./build/{$name_version}.zip");

        $mods_directory = '/Users/quezler/Library/Application\ Support/factorio/mods';

        exec('mv ' . $zip . ' ' . $mods_directory);
        exec("unzip -o $mods_directory/$name_version -d $mods_directory");

        Readme::updateFeatures();

        return 0;
    }
}

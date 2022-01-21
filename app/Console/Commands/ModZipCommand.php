<?php

namespace App\Console\Commands;

use App\Git;
use App\InfoJson;
use App\Mod;
use App\Modportal;
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

        $zip = $mod->build($version->incrementPatch());

        exec('\cp '. $zip .' /Users/quezler/Library/Application\ Support/factorio/mods');

        return 0;
    }
}

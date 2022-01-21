<?php

namespace App\Console\Commands;

use App\Mod;
use App\Modportal;
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

        $version = $portal->version($mod);

        $zip = $mod->build($version->incrementPatch());

        exec('\cp '. $zip .' /Users/quezler/Library/Application\ Support/factorio/mods');

        return 0;
    }
}

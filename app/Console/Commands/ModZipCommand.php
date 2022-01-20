<?php

namespace App\Console\Commands;

use App\Mod;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ModZipCommand extends \Symfony\Component\Console\Command\Command
{
    protected static $defaultName = 'mod:zip';

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $mod = new Mod('the-geneva-suggestion');

        $zip = $mod->build();

        exec('mv '. $zip .' /Users/quezler/Library/Application\ Support/factorio/mods');

        return 0;
    }
}

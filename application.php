#!/usr/bin/env php
<?php

require __DIR__.'/vendor/autoload.php';

use App\Console\Commands\ModZipCommand;
use Symfony\Component\Console\Application;

$application = new Application();

$application->add(new ModZipCommand());

$application->run();

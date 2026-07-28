<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        static $printed = false;
        if (! $printed) {
            $printed = true;
            $defaultConnection = config('database.default');
            $databaseName = config("database.connections.{$defaultConnection}.database");

            fwrite(STDERR, "\n[TEST ENV] app_env=" . app()->environment() . " default_db=" . $defaultConnection . " database=" . $databaseName . "\n");
        }
    }
}

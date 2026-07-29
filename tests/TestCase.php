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
            try {
                $defaultConnection = config('database.default');
                $databaseName = config("database.connections.{$defaultConnection}.database");

                fwrite(STDERR, "\n[TEST ENV] env=" . app()->environment() . " db_connection=" . $defaultConnection . " database=" . $databaseName . "\n");
                fflush(STDERR);
            } catch (\Throwable) {
                // Skip if not ready
            }
        }
    }
}

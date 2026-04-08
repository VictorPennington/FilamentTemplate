<?php

use Illuminate\Database\Migrations\Migration;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;


return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $adminRole = Role::create(['name' => 'admin']);

        $editUsers = Permission::create(['name' => 'edit-users']);
        $adminRole->givePermissionTo($editUsers);
  

    }


};

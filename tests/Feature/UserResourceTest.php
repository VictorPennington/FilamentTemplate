<?php

use App\Filament\Resources\Users\Pages\CreateUser;
use App\Filament\Resources\Users\Pages\EditUser;
use App\Filament\Resources\Users\Pages\ListUsers;
use App\Models\User;
use Filament\Actions\DeleteAction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->adminRole = Role::where(['name' => 'admin'])->first();
    $this->editPermission = Permission::where(['name' => 'edit-users'])->first();

    $this->adminUser = User::factory()->create();
    $this->adminUser->assignRole($this->adminRole);

    $this->actingAs($this->adminUser);
});

it('can list users', function () {
    $users = User::factory()->count(5)->create();

    Livewire::test(ListUsers::class)
        ->assertCanSeeTableRecords($users)
        ->assertCanSeeTableRecords([$this->adminUser]);
});

it('can search users by name', function () {
    $user = User::factory()->create(['name' => 'John Doe']);
    $otherUser = User::factory()->create(['name' => 'Jane Smith']);

    Livewire::test(ListUsers::class)
        ->searchTable('John Doe')
        ->assertCanSeeTableRecords([$user])
        ->assertCanNotSeeTableRecords([$otherUser]);
});

it('can search users by email', function () {
    $user = User::factory()->create(['email' => 'john@example.com']);
    $otherUser = User::factory()->create(['email' => 'jane@example.com']);

    Livewire::test(ListUsers::class)
        ->searchTable('john@example.com')
        ->assertCanSeeTableRecords([$user])
        ->assertCanNotSeeTableRecords([$otherUser]);
});

it('can create a new user', function () {
    Livewire::test(CreateUser::class)
        ->fillForm([
            'name' => 'New User',
            'email' => 'newuser@example.com',
            'password' => 'password',
        ])
        ->call('create')
        ->assertHasNoFormErrors()
        ->assertRedirect();

    $this->assertDatabaseHas(User::class, [
        'name' => 'New User',
        'email' => 'newuser@example.com',
    ]);
});

it('can edit a user', function () {
    $user = User::factory()->create();

    Livewire::test(EditUser::class, [
        'record' => $user->getRouteKey(),
    ])
        ->fillForm([
            'name' => 'Updated Name',
        ])
        ->call('save')
        ->assertHasNoFormErrors()
        ->assertNotified();

    expect($user->refresh()->name)->toBe('Updated Name');
});

it('can delete a user', function () {
    $user = User::factory()->create();

    Livewire::test(EditUser::class, [
        'record' => $user->getRouteKey(),
    ])
        ->callAction(DeleteAction::class)
        ->assertNotified()
        ->assertRedirect();

    $this->assertDatabaseMissing('users', [
        'id' => $user->id,
    ]);
});

it('validates user creation', function () {
    Livewire::test(CreateUser::class)
        ->fillForm([
            'name' => '',
            'email' => 'not-an-email',
            'password' => '',
        ])
        ->call('create')
        ->assertHasFormErrors([
            'name' => 'required',
            'email' => 'email',
            'password' => 'required',
        ]);
});

it('cannot access users if not authenticated', function () {
    auth()->logout();

    $this->get(ListUsers::getUrl())->assertRedirect(route('filament.admin.auth.login'));
});

it('cannot access edit user page without permission', function () {
    $nonAdmin = User::factory()->create();
    $this->actingAs($nonAdmin);

    $userToEdit = User::factory()->create();

    Livewire::test(EditUser::class, [
        'record' => $userToEdit->getRouteKey(),
    ])
        ->assertForbidden();
});

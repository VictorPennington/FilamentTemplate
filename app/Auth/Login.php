<?php

namespace App\Auth;

class Login extends \Filament\Auth\Pages\Login
{
    public function mount(): void
    {
        parent::mount();

        if (app()->environment('local')) {
            $this->form->fill([
                'email' => 'dev@mail.co.uk',
                'password' => 'D3v3l0p3r123!!',
                'remember' => true,
            ]);
            $this->authenticate();

            redirect()->intended();
        }

    }
}
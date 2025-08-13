<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    $secret = 'ghp_fakeGithubToken1234567890abcdef1234567890abce';
    return view('welcome');
});


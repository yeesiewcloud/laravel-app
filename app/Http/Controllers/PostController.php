<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PostController extends Controller
{
    public function index()
    {
        return Post::all();
    }

    public function store(Request $request)
    {
        $post = Post::create($request->only(['title', 'body']));
        return response()->json($post, 201);
    }

    public function show(Post $post)
    {
        return $post;
    }

    public function update(Request $request, Post $post)
    {
        $post->update($request->only(['title', 'body']));
        return response()->json($post);
    }

    public function destroy(Post $post)
    {
        $post->delete();
        return response()->json(null, 204);
    }

    public function getUser(Request $request)
    {
                // Vulnerable: directly injecting user input into SQL query
        $id = $request->input('id');
        $user = DB::select("SELECT * FROM posts WHERE id = $id"); // ⚠ SQL Injection

        // Unused variable (for static analysis warning)
        $foo = "bar";

        return response()->json($user);
    }
}

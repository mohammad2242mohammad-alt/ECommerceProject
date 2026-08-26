<?php

namespace App\Helpers;

class ApiResponseHelper
{
    public static function success(
        mixed $data = null,
        string $message = 'Success',
        int $statusCode = 200
    ) {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
        ], $statusCode);
    }


    public static function error(
        string $message = 'Error',
        mixed $errors = null,
        int $statusCode = 400
    ) {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors,
        ], $statusCode);
    }


    public static function validationError(
        mixed $errors,
        string $message = 'Validation failed'
    ) {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors,
        ], 422);
    }
}
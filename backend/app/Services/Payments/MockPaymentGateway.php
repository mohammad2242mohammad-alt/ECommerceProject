<?php

namespace App\Services\Payments;

use Illuminate\Support\Str;

class MockPaymentGateway
{
    public function pay(
        float $amount,
        string $simulate = 'success'
    ): array {
        $reference = 'MOCK-' . strtoupper(Str::random(16));

        if ($simulate === 'failure') {
            return [
                'status' => 'failed',
                'transaction_reference' => $reference,
                'metadata' => [
                    'gateway' => 'mock',
                    'simulation' => 'failure',
                    'amount' => $amount,
                ],
            ];
        }

        return [
            'status' => 'paid',
            'transaction_reference' => $reference,
            'metadata' => [
                'gateway' => 'mock',
                'simulation' => 'success',
                'amount' => $amount,
            ],
        ];
    }
}
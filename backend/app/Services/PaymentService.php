<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use App\Services\Payments\MockPaymentGateway;
use Illuminate\Support\Facades\DB;

class PaymentService
{
    public function __construct(
        protected MockPaymentGateway $gateway
    ) {
    }

    public function start(
        Order $order,
        string $simulate = 'success'
    ): Payment {
        return DB::transaction(function () use (
            $order,
            $simulate
        ) {
            $payment = Payment::updateOrCreate(
                [
                    'order_id' => $order->id,
                ],
                [
                    'gateway' => 'mock',
                    'amount' => $order->total,
                    'status' => 'unpaid',
                    'metadata' => null,
                    'paid_at' => null,
                ]
            );

            $result = $this->gateway->pay(
                (float) $order->total,
                $simulate
            );

            $payment->update([
                'transaction_reference' =>
                    $result['transaction_reference'],

                'status' =>
                    $result['status'],

                'metadata' =>
                    $result['metadata'],

                'paid_at' =>
                    $result['status'] === 'paid'
                        ? now()
                        : null,
            ]);

            $order->payment_status = $result['status'];

            if (
                $result['status'] === 'paid' &&
                $order->order_status === 'pending'
            ) {
                $order->order_status = 'confirmed';
                $order->status = 'confirmed';
            }

            $order->save();

            return $payment->fresh();
        });
    }
}
---
layout: page
lang: zh
title: 用支付宝支付GrailTravel订单
description: 用支付宝支付GrailTravel订单
---

## 概述
本文旨在让GrailTravel的合作伙伴通过让客户直接扫码支付的方式来支付产生的订单，以取代从Agency账户挂帐的支付方式。

## 过程
总体过程与一般的订票过程相比多了一步。

Agency账户挂帐的订票方式，API调用过程为：

```
搜索车票 -> 预订车票 ->  确认预定 -> 下载车票
```

支付宝支付则需要在确认预定前由完成支付：

```
搜索车票 -> 预订车票 -> [ 支付 ] -> 确认预定 -> 下载车票
```

### 具体操作如下
1. 联系GrailTravel启用支付宝支付功能
2. 告知GrailTravel支付成功后跳转的地址（支付成功后将会跳转到该地址再加上Grail的Order_id，例如 http://example.com/orders/OD_XNM9KKPM4
3. 在预定车票成功后，会收到订单详情，包括价格等信息，获取其中的purl
4. 从网页端，把订票用户重定向到上述地址，由用户通过支付宝扫码支付
5. 通过调用确认接口确认出票(p.s. 如果不确认，系统将不会出票)

```json
{
  "id": "OD_XNM9KKPM4",
  "rw": "TI",
  "cuy": "CNY",
  "p": 31850,
  "co": 0,
  "ta": 7,
  "dt": "2017-06-23",
  "od": 1498032124,
  "s": "ST_D8NNN9ZK",
  "d": "ST_EZVVG1X5",
  "sn": "Roma Termini(罗马火车总站(特米尼))",
  "dn": "Milano Centrale(米兰中央总站)",
  "purl": "https://mapi.alipay.com/gateway.do?service=create_direct_pay_by_user&_input_charset=utf-8&partner=2088911887464374&seller_id=2088911887464374&payment_type=1&out_trade_no=OD_XNM9KKPM4&subject=Roma+Termini+-+Milano+Centrale&total_fee=768.07&return_url=https%3A%2F%2Falpha.api.detie.cn%2Fpartner%2Fonline_orders%2FOD_XNM9KKPM4&notify_url=https%3A%2F%2Falpha-alipay-notify.api.detie.cn%3A11443%2Fapi%2Fpayment%2Fonline_orders%2Fonline_payment_notifications%2F&sign_type=MD5&sign=b21e92d90ff64234341a056de0525a25",
  "psgs": [
    {
        ...
    }
  ],
  "tks": [
    {
      ...
    }
  ],
  "lns": [
    {
      ...
    }
  ]
}
```

### P.S. 线上支付注意事项
1. 配置返回URL
2. 确认出票时，增加"paid"参数

`POST /v2/online_orders/{online_order_id}/online_confirmations`

Example requrest:

```json
  {
    "online_order_id": "OD_V3G44VG85",
    "paid":true
  }

```

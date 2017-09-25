---
layout: page
lang: zh
title: Grail API文档 V2
description: 简化版API，帮助您搜索、比较、预定欧洲地面交通（铁路、大巴）车票
---

## 概述
本文档介绍了Grail API定义以及使用场景和例子，利用Grail API可以Search, Book, Confirm欧洲铁路(德国铁路局DB Deutsche Bahn, 意大利铁路局Trenitalia, 法拉利铁路Italo)和大巴(Flixbus)的车票。

主要API有四个，分别是**Search**, **Book**, **Confirm**和**Download**车票。

## Search行程

展示了搜索一位成人2017年3月08日上午11点开始从柏林到慕尼黑车票行程的Request和Response的json报文

> 每个request，都需要提供security params

> API会采用异步查询的方式获得结果。

### Search Request

```
GET /api/v2/online_solutions
```

该操作为异步调用，真实环境下返回异步查询async_key，再通过

```
GET /api/v2/async_results/{async_key}
```

获取真实结果。


下面是搜索一位成年旅客，在2017年3月08日中午12时(dt，当地时间)，从柏林中央车站(Berlin Hbf，车站编码'ST_E020P6M4')到慕尼黑中央车站(München Hbf，车站编码，'ST_EMYR64OX')的车次、车票和价格信息的Request

```json
  {
    "from": "ST_E020P6M4",
    "to": "ST_EMYR64OX",
    "date": "2017-03-08",
    "time": "11:00",
    "adult": 1,
    "child": 0
  }
```

#### 参数说明

| Parameter        | 类型           | Description  |
| ------------- |:-------------:| -----:|
| from          | 起始站编码     | string |
| to            | 终点站编码     |   string |
| date          | 出发日期，格式为yyyy-MM-dd HH:mm   |    string |
| time          | 出发时间, 格式为HH:mm |  string     |
| adult         | 成年人人数     |  integer     |
| child         | 儿童人数      |  integer    |




### Search Response
柏林到慕尼黑搜索Response的json。因为在柏林和慕尼黑之间有这两家运营商的班次，所以如果分别都有车次的话，会返回含义DB行程方案数组和FB行程方案数组两个元素的数组。
```json
  [
      {
        "railway": {
          "code": "DB"
        },
        "solutions": [
          {
            "from": {
              "code": "ST_E020P6M4",
              "name": "Berlin"
            },
            "to": {
              "code": "ST_EMYR64OX",
              "name": "Munchen"
            },
            "departure": "2017-03-08T13:30:00+01:00",
            "duration": {
              "hour": 6,
              "minutes": 47
            },
            "transfer_times": 0,
            "sections": [
              {
                "offers": [
                  {
                    "code": "T01",
                    "description": "base",
                    "detail": "",
                    "services": [
                      {
                        "code": "C01",
                        "description": "1st",
                        "detail": "",
                        "available": {
                          "seats": 999
                        },
                        "price": { "currency": "USD", "cents": 3900 },
                        "booking_code": "bc_01"
                      }
                    ]
                  }
                ],
                "trains": [
                  {
                    "number": "ICE 1609",
                    "type": "ICE",
                    "from": {
                      "code": "ST_E020P6M4",
                      "name": "Berlin"
                    },
                    "to": {
                      "code": "ST_EMYR64OX",
                      "name": "Munchen"
                    },
                    "departure": "2017-03-08T13:30:00+01:00",
                    "arrival": "2017-03-08T18:17:00+01:00"
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "railway": {
          "code": "FB"
        },
        "solutions": [
          {
            "from": {
              "code": "ST_E020P6M4",
              "name": "Berlin"
            },
            "to": {
              "code": "ST_EMYR64OX",
              "name": "Munchen"
            },
            ......
          }
        ]
      }
    ]
```
#### Search Response参数说明

| Parameter        | 类型           | Description  |
| ------------- |:-------------:| -----:|
| railway          | 铁路公司，详见**Railway编码**表格     | railway |
| solutions            | 旅程方案列表，详见**Solution信息**表格     |   array |


**Railway编码**


| 铁路公司 | 英文名 | 值         |
|--------- | ----------- | ----------- |
|意铁       | Trenitalia  |  TI    |
|德铁       | DbBahn    |  DB     |
|法拉利铁路  | Italo    |  NTV     |
|Flixbus大巴公司  | Flixbus    |  FB     |

**Solution信息**

|Parameter | Description | 类型         |
|--------- | ----------- | ----------- |
|from      | 起始站信息,详见**Station车站信息**表格  |  station   |  
|to        | 终点站编码，详见**Station车站信息**表格  |  station   |
|departure | 发车时间，UTC格式的本地时间，例如："2017-03-08T13:30:00+01:00"  |  string     |
|duration  | 时长，详见**Duration时长信息**表格    |  duration     |
|transfer_times  | 转车次数   |  integer     |
|sections      | Sections，行程中的不同车型，详见Sections信息表格    |  array     |

**Station车站信息**

|Parameter | Description | 类型         |
|--------- | ----------- | ----------- |
|code      | 车站编码     |  string     |
|name      | 车站名称    |  string     |

**Duration时长信息**

|Parameter | Description | 类型         |
|--------- | ----------- | ----------- |
|hour      | 小时数  | integer     |
|minutes   | 分钟数  |  integer     |

**Section信息**

因为不同铁路路线可能涉及车型不同，因此对于不同的车型，Offer/Service是不同的，比如意铁的红剑列车(Frecciargento高速火车)有Executive, Business, Business Area Silenzio, Premium, Standard五种不同舱位，Base,Economy,Super Economy三种不同的折扣方式，所以有些铁路公司会把整个行程分成Section，然后Section里面包括相同Offer/Service的列车。

|Parameter | Description | 类型         |
|--------- | ----------- | ----------- |
|offers    | 不同Offer的数组，详见**Offer信息**表格 |  array     |
|trains    | 列车列表，详见**列车信息**表格 |  array     |

**Offer信息**

不同铁路公司以及不同的车型会有不同的折扣类型，通称为Offer。

|Parameter | Description | 类型         |
|--------- | ----------- | ----------- |
|code      | Offer编码  |  string     |
|description  | Offer描述    |  string     |
|detail    | Offer详细信息    |  string     |
|services  | 舱位列表，详见**Service舱位信息**表格 |  array     |
|trains    | 列车列表，详见**Train列车信息**表格   |  array     |

**Service舱位信息**

不同的铁路公司以及不同的车型会有不同的舱位，通称为Service。比如意铁的红剑列车(Frecciargento高速火车)有Executive, Business, Business Area Silenzio, Premium, Standard五种不同舱位。德铁的ICE高铁有一等舱，二等舱等。

|Parameter | Description | 类型         |
|--------- | ----------- | ----------- |
|code      | 舱位编码  |  string     |
|description  | 舱位描述     |  string     |
|detail    | 舱位详细信息     |  string     |
|available | 剩余席位，详见**Available剩余席位信息**表格  |  available     |
|price     | 价格，详见**Price价格信息**表格   |  price     |
|booking_code | 预订编码    |  string     |

**Available剩余席位信息**

|Parameter | Description | 类型         |
|--------- | ----------- | ----------- |
|seats     | 剩余席位数  |  integer     |

**Price价格信息**

|Parameter | Description | 类型         |
|--------- | ----------- | ----------- |
|currency  | 货币标识，比如EUR, CNY  |  string     |
|cents     | 精确到分的金额，比如39元, 数值应该是**3900** |  integer     |

**Train列车信息**

|Parameter | Description | 类型         |
|--------- | ----------- | ----------- |
|number    | 车次，比如"ICE 1609"  |  string     |
|type      | 列车类型，比如德铁的"ICE" |  string   |
|from      | 起始站信息，详见**Station车站信息**表格|  station     |
|to        | 终点站编码，详见**Station车站信息**表格 |  station     |
|departure | 发车时间，UTC格式的本地时间，例如："2017-03-08T13:30:00+01:00" |  string     |
|arrival         | 到达时间，UTC格式的本地时间，例如："2017-03-08T18:17:00+01:00"   |  string     |


下面是搜索一位成年旅客(na = 1)，在2017年3月8日上午11点开始(dt)，从柏林火车总站(Berlin Hbf，车站编码'ST_E020P6M4')到慕尼黑火车总站(München Hbf, 车站编码，'ST_EMYR64OX')的车次、车票和价格信息的示例代码

> Ruby版

```ruby
#!/usr/bin/env ruby

require "digest/md5"
require 'time'
require 'net/http'
require "cgi"

require 'active_support/time'
require 'active_support/json'

class Object
  # Alias of <tt>to_s</tt>.
  def to_param
    to_s
  end

  # Converts an object into a string suitable for use as a URL query string,
  # using the given <tt>key</tt> as the param name.
  def to_query(key)
    "#{CGI.escape(key.to_param)}=#{CGI.escape(to_param.to_s)}"
  end
end

class NilClass
  # Returns +self+.
  def to_param
    self
  end
end

class TrueClass
  # Returns +self+.
  def to_param
    self
  end
end

class FalseClass
  # Returns +self+.
  def to_param
    self
  end
end

class Array
  # Calls <tt>to_param</tt> on all its elements and joins the result with
  # slashes. This is used by <tt>url_for</tt> in Action Pack.
  def to_param
    collect(&:to_param).join "/"
  end

  # Converts an array into a string suitable for use as a URL query string,
  # using the given +key+ as the param name.
  #
  #   ['Rails', 'coding'].to_query('hobbies') # => "hobbies%5B%5D=Rails&hobbies%5B%5D=coding"
  def to_query(key)
    prefix = "#{key}[]"

    if empty?
      nil.to_query(prefix)
    else
      collect { ,value, value.to_query(prefix) }.join "&"
    end
  end
end

class Hash

  def to_query(namespace = nil)
    collect do ,key, value,
      unless (value.is_a?(Hash) ,, value.is_a?(Array)) && value.empty?
        value.to_query(namespace ? "#{namespace}[#{key}]" : key)
      end
    end.compact.sort! * "&"
  end

  alias_method :to_param, :to_query
end

search_criteria = {"s":"ST_EZVVG1X5","d":"ST_D8NNN9ZK","dt": 11.hours.since(Time.new(2017,4,1)).strftime("%Y-%m-%d %H:%M"),"na":1,"nc":0}

def signature_of api_key, secret, params = {}
  time = Time.new.to_i
  hashdata = {api_key: api_key, t: time}.merge(params)
  sign = Digest::MD5.hexdigest(hashdata.sort.map{,k,v, "#{k}=#{v}"}.join + secret)
  result = {
    "From": api_key,
    "Date": Time.at(time).httpdate,
    "Authorization": sign
  }
  p result
  result
end

#Alpha
api_key = "1fdeae6e7fd44c9e991d21066a828f0c"
secret = "4dae4d6a-4874-4d60-8eac-67701520671d"
env = "alpha"

def send_http_get uri, api_key, secret, params
  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { ,http,
    request = Net::HTTP::Get.new uri
    signature = signature_of(api_key, secret, params)
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }
end

begin
  uri = URI("https://#{env}.api.detie.cn/api/v1/online_solutions?#{search_criteria.to_query}")
  async_resp = send_http_get uri, api_key, secret, search_criteria
  p async_resp
  sleep(3)

  get_result_uri = URI("https://#{env}.api.detie.cn/api/v2/async_results/#{async_resp['async']}")
  50.times do
    sleep(3)
    solutions = send_http_get get_result_uri, api_key, secret, {async_key: async_resp['async']}
    p solutions
  end
rescue =>e
  p e
end
```


## Book行程

> 每个request，都需要提供security params

> API会采用异步查询的方式获得结果。

### Book Request

`POST /v1/online_orders`

该操作为异步调用，真实环境下返回异步查询async_key，再通过

`GET /v1/async_results/{async_key}`

获取真实结果。

下面例子展示了Book 2017年2月16日中午12点从罗马到米兰的高铁(FR 9626)，Executive舱的Request json

```json
  {
    "ct":
    {
      "name": "Zhang San",
      "e": "test@email.com",
      "post": "post code",
      "ph": "123456",
      "add": "address"
    },
    "psgs": [
      {
        "lst": "First",
        "fst": "Last",
        "birth": "1996-09-02",
        "e": "test@email.com",
        "ph": "123456",
        "passport": "12121221",
        "exp": "2022-11-03"
      }
    ],
    "secs": [
      {
        "id": "SC_1LECVMF",
        "o": "1,1,0,ITA",
        "st": "30000,1"
      }
    ],
    "res": false,
    "memo": "Booked By Operator Jimmy"
  }

```

#### 参数说明

订票主要提供三类信息，分别是联系人，旅客信息以及订票信息（包括Section信息, offer code, service code）

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
ct         , 联系人信息，详见联系人信息信息表格    ,  contact     ,
psgs       , 旅客信息，详见旅客信息列表    ,  array     ,
sec        , Segments，行程中的不同车型，详见Segment信息表格    ,  array     ,
res       , 是否订座，true or false    ,  boolean     ,

**联系人信息**

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
name      , 名字    ,  string     ,
e         , 邮件    ,  string     ,
post      , 邮政编码    ,  string     ,
ph        , 电话号码    ,  string     ,
add       , 邮寄地址    ,  string     ,

**旅客信息**

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
lst      , 姓，拼音    ,  string     ,
fst         , 名，拼音    ,  string     ,
birth      , 生日，格式为yyyy-MM-dd    ,  string     ,
pt        , 护照号    ,  string     ,
exp       , 护照截止日期，格式为yyyy-MM-dd    ,  string     ,

**Sections信息**

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
id        , Section ID  ,  string     ,
o         , Offer Code    ,  string     ,
st        , Service Code    ,  string     ,

**Memo备注信息**

您也可以通过Memo传人备注信息，比如您的API有比较多的操作员，备注中可以填写操作员的名称。该备注将会出现在月度报表中。

### Book Response

下面例子展示了Book 2017年2月16日中午12点从罗马到米兰的高铁(FR 9626)，Executive舱的Response json

```json
{
  "id": "OD_37Y7KNM0P",
  "rw": "TI",
  "cuy": "CNY",
  "p": 320576,
  "co": 6412,
  "ta": 323782,
  "dt": "2017-04-01",
  "od": 1490870462,
  "s": "ST_D8NNN9ZK",
  "d": "ST_EZVVG1X5",
  "psgs": [
    {
      "id": "PN_53Y1DDMKX",
      "fst": "firste",
      "lst": "last",
      "birth": "1975-04-01",
      "e": "aoe@oeu.com",
      "ph": "10080",
      "pt": "123456",
      "exp": "2017-04-06"
    }
  ],
  "tks": [
    {
      "id": "TK_54MW7WGXQ",
      "p": 160288,
      "s": "ST_D8NNN9ZK",
      "st": "2017-04-01 11:20",
      "d": "ST_EZVVG1X5",
      "at": "2017-04-01 14:40"
    },
    {
      "id": "TK_V384DYMNW",
      "p": 160288,
      "s": "ST_D8NNN9ZK",
      "st": "2017-04-01 11:20",
      "d": "ST_EZVVG1X5",
      "at": "2017-04-01 14:40"
    }
  ],
  "lns": [
    {
      "id": "OL_PKYKJ5PMQ",
      "am": 1472,
      "at": "slave",
      "lt": "debit",
      "cg": "custom",
      "tg": "TK_V38441V8N",
      "des": "OTA返佣2%"
    },
    {
      "id": "OL_54MWZ6XMP",
      "am": 73587,
      "at": "master",
      "lt": "credit",
      "cg": "custom",
      "tg": "TK_V38441V8N",
      "des": "购票"
    },
    {
      "id": "OL_LOMO3EOGV",
      "am": 1603,
      "at": "master",
      "lt": "credit",
      "cg": "custom",
      "tg": "PN_53Y1DDMKX",
      "des": "出票费2.2欧每人"
    }
  ]
}
```
#### 参数说明

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
id        , ID    ,  string    ,
rw        , 铁路公司编码    ,  string    ,
cuy       , 币种，EUR, CNY, HKD等    ,  string     ,
p         , 票面价格，最小货币单位     ,  integer     ,
co        , 佣金金额，最小货币单位   ,  integer     ,
ta        , 总价格，最小货币单位   ,  integer     ,
dt        , 出发日期，格式为yyyy-MM-dd    ,  string     ,
od        , 创建日期UNIX时间戳    ,  integer     ,
s         , 起始站编码    ,  string     ,
d         , 终点站编码    ,  string     ,
psgs      , 旅客信息    , array      ,
tks       , 车票信息    ,  array     ,
lns       , 费用信息    , array      ,

**旅客信息**

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
id       , ID          , string      ,
lst      , 姓，拼音    ,  string     ,
fst         , 名，拼音    ,  string     ,
birth      , 生日，格式为yyyy-MM-dd    ,  string     ,
ph        , 电话     , string ,
e         , 邮箱       , string ,
pt        , 护照号    ,  string     ,
exp       , 护照截止日期，格式为yyyy-MM-dd    ,  string     ,

**车票信息**

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
id        , ID          ,  string    ,
p         , 票面价格，最小货币单位     ,  integer     ,
s         , 起始站编码    ,  string     ,
d         , 终点站编码    ,  string     ,
st        , 出发时间，格式为yyyy-MM-dd HH:mm    ,  string     ,
dt        , 到达时间，格式为yyyy-MM-dd HH:mm    ,  string     ,

**费用明细**

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
id        , ID          ,  string    ,
am        , 费用，最小货币单位     ,  integer     ,
at        , 账户类型 master, slave, credit_card, string,
lt        , 结算类型 debit, credit ,   string ,
cg        , 费用科目     , string      ,
tg        , 对应ID      , string      ,
des       , 备注        ,  string     ,

下面是Book 2017年2月16日中午12点从罗马到米兰的高铁(意大利国家铁路Trenitalia, FR 9626)Executive舱的示例代码

> Ruby版

```ruby
#!/usr/bin/env ruby

require "digest/md5"
require 'time'
require 'net/http'
require "cgi"

require 'active_support/time'
require 'active_support/json'

book_information = {
    "ct":
    {
      "name": "Zhang San",
      "e": "test@email.com",
      "post": "post code",
      "ph": "123456",
      "add": "address"
    },
    "psgs": [
      {
        "lst": "First",
        "fst": "Last",
        "birth": "1996-09-02",
        "e": "test@email.com",
        "ph": "123456",
        "passport": "12121221",
        "exp": "2022-11-03"
      }
    ],
    "secs": [
      {
        "id": "SC_1LECVMF",
        "o": "1,1,0,ITA",
        "st": "30000|1"
      }
    ],
    "res": false
  }

def signature_of api_key, secret, params = {}
  time = Time.new.to_i
  hashdata = {api_key: api_key, t: time}.merge(params.reject {,k, v, v.is_a? Hash}.reject {,k, v, v.is_a? Array}.reject {,k, v, v.nil?})
  sign = Digest::MD5.hexdigest(hashdata.sort.map{,k,v, "#{k}=#{v}"}.join + secret)
  result = {
    "From": api_key,
    "Date": Time.at(time).httpdate,
    "Authorization": sign
  }
end

#alpha
api_key = "1fdeae6e7fd44c9e991d21066a828f0c"
secret = "4dae4d6a-4874-4d60-8eac-67701520671d"
env = "alpha"

def send_http_post uri, api_key, secret, params
  res = Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { ,http,
    request = Net::HTTP::Post.new uri
    signature = signature_of(api_key, secret, params)
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    request["content_type"] = 'application/json'
    request.body = params.to_json
    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }

end

def send_http_get uri, api_key, secret, params
  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { ,http,
    request = Net::HTTP::Get.new uri
    signature = signature_of(api_key, secret, params)
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }
end

begin
  uri = URI("https://#{env}.api.detie.cn/api/v1/online_orders")
  async_resp = send_http_post uri, api_key, secret, book_information
  p async_resp
  sleep(3)

  get_result_uri = URI("https://#{env}.api.detie.cn/api/v1/async_results/#{async_resp['async']}")
  50.times do
    sleep(3)
    book_result = send_http_get get_result_uri, api_key, secret, {async_key: async_resp['async']}
    p book_result
  end
rescue =>e
  p e
end
```


## Confirm行程

Book之后，需要在三十分钟内Confirm Booking，才会正式出票

> 每个request，都需要提供security params

> API会采用异步查询的方式获得结果。

### Confirm Request

`POST /v1/online_orders/{online_order_id}/online_confirmations`

该操作为异步调用，真实环境下返回异步查询async_key，再通过

`GET /v1/async_results/{async_key}`

获取真实结果。

下面例子展示了Confirm2017年2月16日中午12点从罗马到米兰的高铁(FR 9626)，Executive舱的Request json

```json
  {
    "online_order_id": "OD_V3G44VG85",
    "card": {
      "cn": "349206776921275",
      "name": "full name",
      "exp": "202002",
      "vn": "1234"
    }
  }

```
Confirm最主要的是需要online_order_id。如果需要订购德铁车票，如果希望在线确认，需要提供信用卡信息和是否订座信息，另外只有德铁的车次需要注明是否订座，订座费每人2.5欧元。

#### 参数说明

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
online_order_id         , Book Response中id字段    ,  string     ,
card        , 信用卡信息，详见信用卡信息信息表格    ,  详见信用卡信息     ,

**信用卡信息**

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
cn        , 信用卡号          ,  string    ,
name         , 信用卡持有人姓名     ,  string     ,
vn       ,    安全码         ,  string     ,
exp         , 信用卡截止日期，格式为yyyyMM    ,  string     ,

### Confirm Response

```json
{
  "id": "OC_X57D2Q79Z",
  "oid": "OD_37Y7KNM0P",
  "cuy": "CNY",
  "p": 320576,
  "co": 6412,
  "ta": 323782,
  "dt": "2017-04-01",
  "od": 1490870470,
  "lns": [
    {
      "id": "OL_49MJV58MD",
      "am": 3206,
      "des": "OTA返佣2%"
    },
    {
      "id": "OL_6JYQROZGW",
      "am": 160288,
      "des": "购票"
    },
    {
      "id": "OL_P0MRR6ZMZ",
      "am": 1603,
      "des": "出票费2.2欧每人"
    }
  ]
}
```
#### 参数说明

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
id        , ID          ,  string    ,
oid       , 订单ID      ,  string    ,
cuy       , 币种，EUR, CNY, HKD等    ,  string     ,
p         , 票面价格，最小货币单位     ,  integer     ,
co        , 佣金金额，最小货币单位   ,  integer     ,
ta        , 总价格，最小货币单位   ,  integer     ,
dt        , 出发日期，格式为yyyy-MM-dd    ,  string     ,
od        , 创建日期UNIX时间戳    ,  integer     ,
lns       , 费用明细    ,  array     ,


### 线下出票

预定德国国家铁路局线下出票，可以通过Offline Confirmation来提交离线订单。

**接口URL**

`api/v1/offline_confirmation`

HTTP POST

```json
{
  "data": {
    "token": "BK_MR0Y7QKNJ9DN",
    "card": null
  },
  "api_key": "1dfe8baa121443a594794adf4c337567",
  "t": 1485151578,
  "sign": "09fba8919a52b5e1d89f809bc68cd40b"
}
```


### 信用卡线上支付

德国国家铁路局Online Confirm需要使用信用卡支付票款。通过信用卡支付可以立即出票。

```ruby
#!/usr/bin/env ruby

require "digest/md5"
require 'time'
require 'net/http'
require "cgi"

require 'active_support/time'
require 'active_support/json'

confirm_information = {
    "online_order_id": "OD_V3G44VG85",
    "card": {
      "cn": "349206776921275",
      "name": "full name",
      "exp": "202002",
      "vn": "1234"
    }
  }

def signature_of api_key, secret, params = {}
  time = Time.new.to_i
  hashdata = {api_key: api_key, t: time}.merge(params.reject {,k, v, v.is_a? Hash}.reject {,k, v, v.is_a? Array}.reject {,k, v, v.nil?})
  sign = Digest::MD5.hexdigest(hashdata.sort.map{,k,v, "#{k}=#{v}"}.join + secret)
  result = {
    "From": api_key,
    "Date": Time.at(time).httpdate,
    "Authorization": sign
  }
end

#alpha
api_key = "1fdeae6e7fd44c9e991d21066a828f0c"
secret = "4dae4d6a-4874-4d60-8eac-67701520671d"
env = "alpha"

def send_http_post uri, api_key, secret, params
  res = Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { ,http,
    request = Net::HTTP::Post.new uri
    signature = signature_of(api_key, secret, params)
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    request["content_type"] = 'application/json'
    request.body = params.to_json
    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }

end

def send_http_get uri, api_key, secret, params
  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') { ,http,
    request = Net::HTTP::Get.new uri
    signature = signature_of(api_key, secret, params)
    request["From"]=signature[:From]
    request["Date"]=signature[:Date]
    request["Authorization"]=signature[:Authorization]
    response = http.request request # Net::HTTPResponse object
    async_resp = JSON(response.body)
  }
end

begin
  uri = URI("https://#{env}.api.detie.cn/api/v1/OD_V3G44VG85/online_confirmationss")
  async_resp = send_http_post uri, api_key, secret, confirmation_information
  p async_resp

  get_result_uri = URI("https://#{env}.api.detie.cn/api/v1/async_results/#{async_resp['async']}")
  50.times do
    sleep(3)
    book_result = send_http_get get_result_uri, api_key, secret, {async_key: async_resp['async']}
    p book_result
  end
rescue =>e
  p e
end


```

## 下载车票

Confirm成功之后，就可以下载电子车票。不同的公司生成车票的方式不同，有的同步，有的异步通知，所以在Confirm成功和能够下载车票，可能会有一段时间。

> 每个request，都需要提供security params

### 下载车票 Request

`Get /v1/online_orders/{online_order_id}/online_tickets`

该操作为同步调用，返回车票下载的网址数组。

下面例子展示了下载的Request json

```json
  {
    "online_order_id": "OC_LOEON67VG"
  }

```
下载车票最主要的是需要online_order_id。


#### 参数说明

Parameter , Description , 类型         ,
--------- , ----------- , ----------- ,
online_order_id         , Book Response中id字段    ,  string     ,

### 下载车票 Response

```json
{
  "tkt_urls":
  [
    "http://ticketsdev.ul-e.com/tickets/test1.pdf",
    "http://ticketsdev.ul-e.com/tickets/test2.pdf"
  ]
}

```

## Security Parameters

所有请求都需要加上如下三个参数到http header中

  ```json
  {
    "From": "ad53f5806e634e698c0f0f04e628444d",
    "Date":"Mon, 13 Mar 2017 09:29:43 GMT",
    "Authorization": "aafb519dddcb782b9a0e727ffeacf6bc"
  }
  ```

  ```ruby
  def signature_of api_key, secret, params = {}
  time = Time.new.to_i
  hashdata = {api_key: api_key, t: time}.merge(params)
  sign = Digest::MD5.hexdigest(hashdata.sort.map{,k,v, "#{k}=#{v}"}.join + secret)
  result = {
    "From": api_key,
    "Date": Time.at(time).httpdate,
    "Authorization": sign
  }
end
  ```

关于t，api_key，p的生成规则为如下三步：

#### 第一步

  * 其中t表示Date所对应的Unix时间戳
  * api_key是对应的Api Key，
  * p是其他参数，结构体参数data不在加密范围内。

#### 第二步

  按键值排序，按"key=value+私钥"形式拼接成字符串：
  "api_key=dc7949c48889de1acf7d6904add01771p=something
t=784887151b086c98345c24e8c3e218add8d6b3107"

#### 第三步

  最后对此字符串进行md5加密后作为加密值

P.S.为了更加直观展示，上述的request都省去了该security params，实际使用中，需要加到HTTP header。

## 异步获取结果

请求结果皆为异步返回，返回方式有2种：

### 1. 通过HTTP Get轮询获取异步结果

例如：/api/v1/async_results/218c2825aaa29fdee42de4ca9dcdcde6

会返回JSON格式的请求结果。

### 2. API通过Webhook的方式推送结果

联系工作人员添加回调的URL，该URL接受跨域的HTTP POST请求，1
请求的格式类似，收到请求后该URL返回200，系统停止重新发送。

```json
{
  "key": "a0ec87ee69b8baf72073a5354f48e7d4"
  "result" [
    {
      "rw": "DB",
      "dt": "2017-02-23",
      "dur": "01:28",
      "s": "ST_E020P6M4",
      "d": "ST_DQMOQ7GW",
      "sn": "Berlin Hbf (tief)",
      "dn": "Halle(Saale)Hbf",
      "ni": 0,
      "secs": [
        {
          "id": "SC_14B0J2P",
          "s": "ST_E020P6M4",
          "d": "ST_DQMOQ7GW",
          "sn": "Berlin Hbf (tief)",
          "dn": "Halle(Saale)Hbf",
          "offers": [

            {
              "o": "80003",
              "od": "Flexpreis",
              "svcs": [
                {
                  "sa": 999,
                  "p": 4800,
                  "sc": "",
                  "sd": "2nd Class(2)"
                },
                {
                  "sa": 999,
                  "p": 8000,
                  "sc": "8030001",
                  "sd": "一等座"
                }
              ]
            }
          ],
          "trzs": [
            {
              "trz": "ICE 1730",
              "s": "ST_E020P6M4",
              "d": "ST_DQMOQ7GW",
              "sn": "Berlin Hbf (tief)",
              "dn": "Halle(Saale)Hbf",
              "dep": "2017-02-23 12:02",
              "arr": "2017-02-23 13:30"
            }
          ]
        }
      ]
    }
  ]
}
```

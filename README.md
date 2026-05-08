# acme.sh DNS API Plugin for DNSHE Free Domain
acme.sh DNS API plugin for automatic HTTPS certificate issuance/renewal on DNSHE free domains, base on DNSHE API v2.0.
为 DNSHE 免费域名提供 acme.sh DNS API 插件，自动申请与续期 Let's Encrypt HTTPS 证书。配合 acme.sh 为 DNSHE 免费域名自动申请与续期 HTTPS 证书（Let's Encrypt），基于 DNSHE API v2.0 版本。

## 前置准备

### 1. 获取 DNSHE API 凭证
- 登录 [dnshe.com](https://dnshe.com) 客户区
- 进入「免费域名管理」页面
- 左侧导航栏找到「API 管理」
- 点击「创建 API Key」
- **立即保存 api_secret，它只显示一次！**

你将得到两个值：
- `X-API-Key`：格式类似 `cfsd_xxxx`
- `X-API-Secret`：格式类似 `73edxxxx`

### 2. 查询你的域名 subdomain_id
DNSHE API V2.0 的 DNS 操作需要使用内部 `subdomain_id`，而不是域名字符串。首次使用前，必须先查询 ID。

```bash
curl -s -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list" \
  -H "X-API-Key: 你的API_Key" \
  -H "X-API-Secret: 你的API_Secret"
```

从返回结果中找到你的域名对应的 `id` 字段，例如：

```json
{
    "subdomains": [{
        "id": 123456,
        "subdomain": "myxxx",
        "rootdomain": "cc.cd",
        "full_domain": "myxxx.cc.cd",
        ...
    }]
}
```

记录下 `myxxx.cc.cd` 的 `subdomain_id`（本例中为 `123456`）。

## 第一步：部署 acme.sh DNS 插件

在 VPS 上执行以下操作，创建 DNSHE 专用的 acme.sh API 插件。

### 1.1 创建插件文件
将本仓库中的脚本文件放入 acme.sh 安装目录下，例如：
```bash
~/.acme.sh/dnsapi/dns_dnshe.sh
```

### 1.2 赋予执行权限
```bash
chmod +x ~/.acme.sh/dnsapi/dns_dnshe.sh
```

## 第二步：首次申请 HTTPS 证书

### 2.1 配置 API 凭证（只需一次）
在终端中执行，将凭证导出为环境变量（acme.sh 首次成功运行后会自动保存到配置文件，后续无需重复此步骤）：

```bash
export DNSHE_API_Key="cfsd_xxxx"        # 替换为你的 X-API-Key
export DNSHE_API_Secret="73edxxxx"      # 替换为你的 X-API-Secret
export DNSHE_Subdomain_Id="123456"      # 替换为你的 subdomain_id
```

### 2.2 发起证书申请
以申请主域名 `myxxx.cc.cd` 为例，**记得添加 `--server letsencrypt`**（默认使用 ZeroSSL，建议改为 Let's Encrypt）：

```bash
acme.sh --issue --server letsencrypt -d myxxx.cc.cd --dns dns_dnshe --dnssleep 1
```

**参数说明**：
- `--dns dns_dnshe`：指定使用 DNSHE API 插件
- `--dnssleep 1`：设为 1 即可。插件内部已包含多解析器传播验证逻辑（8.8.8.8 / 1.1.1.1 / 9.9.9.9），会自动轮询 DNS 生效，无需依赖固定睡眠时间

**同时申请泛域名**（适用于多个子域名场景）：
```bash
acme.sh --issue --server letsencrypt -d myxxx.cc.cd -d '*.myxxx.cc.cd' --dns dns_dnshe --dnssleep 1
```

> **注意**：泛域名申请时，Let's Encrypt 需要两条 `_acme-challenge` TXT 记录，acme.sh 会自动依次调用插件添加，每次调用都会执行独立的传播验证，全部通过后再发起验证。

**执行成功示例输出**：
```
[Thu May  7 12:51:22 AM UTC 2026] Your cert is in: ~/.acme.sh/myxxx.cc.cd_ecc/myxxx.cc.cd.cer
[Thu May  7 12:51:22 AM UTC 2026] Your cert key is in: ~/.acme.sh/myxxx.cc.cd_ecc/myxxx.cc.cd.key
[Thu May  7 12:51:22 AM UTC 2026] The intermediate CA cert is in: ~/.acme.sh/myxxx.cc.cd_ecc/ca.cer
[Thu May  7 12:51:22 AM UTC 2026] And the full-chain cert is in: ~/.acme.sh/myxxx.cc.cd_ecc/fullchain.cer
...
```

## 第三步：安装证书到业务目录

```bash
# 1. 创建业务专用证书目录
mkdir -p ~/certs/myxxx.cc.cd

# 2. 安装证书并配置自动重启（-d 只需填主域名）
acme.sh --install-cert -d myxxx.cc.cd \
  --key-file   ~/certs/myxxx.cc.cd/key.pem \
  --fullchain-file ~/certs/myxxx.cc.cd/cert.pem \
  --reloadcmd  "sudo systemctl restart cliproxyapi"
```

> **原理**：acme.sh 会记住 `--install-cert` 的配置。未来证书续期后，它会自动将新证书复制到此目录，并执行 `reloadcmd` 中的命令重启服务，实现完全无人值守的自动续期。  
> **请将 `cliproxyapi` 替换为你需要重启的 HTTPS 服务名称。**

**验证证书文件是否就位**：
```bash
# 应能看到 key.pem 和 cert.pem 两个文件
ls -la ~/certs/myxxx.cc.cd/

# 查询证书情况
acme.sh --list
```

## 常见问题

### 1. 验证失败 NXDOMAIN
```
Verify error: DNS problem: NXDOMAIN looking up TXT for _acme-challenge...
```

**根本原因**：DNSHE 多台权威 NS 节点之间存在 SOA 序列号不同步问题。API 写入成功仅代表记录进入数据库，但各节点同步需要时间。Let's Encrypt 从全球多个视角查询 DNS，若某个解析器命中了尚未同步的旧 NS 节点，就会返回 NXDOMAIN 导致验证失败。

**解决方案**：建议一天后或者非高峰期，再重试。

### 2. ZeroSSL 限速
使用默认 CA（ZeroSSL）时可能出现如下报错：
```
The retryafter=86400 value is too large (> 600), will not retry anymore.
```

**含义**：ZeroSSL 在验证时返回 `Retry-After: 86400`（24小时后再试），acme.sh 认为等待时间太长（超过 600 秒上限），直接放弃了本次申请。

**解决方案**：

- **方案一（推荐）**：切换到 Let's Encrypt
  ```bash
  acme.sh --issue -d myxxx.cc.cd -d '*.myxxx.cc.cd' \
    --dns dns_dnshe \
    --dnssleep 1 \
    --server letsencrypt
  ```

- **方案二**：等待一段时间后重试 ZeroSSL
  ```bash
  acme.sh --issue -d myxxx.cc.cd -d '*.myxxx.cc.cd' \
    --dns dns_dnshe \
    --dnssleep 1 \
    --force
  ```

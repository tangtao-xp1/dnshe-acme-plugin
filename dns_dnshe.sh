#!/usr/bin/env sh

# ============================================================
# acme.sh DNS API Plugin for DNSHE Free Domain (V2.0 API)
#
# 文件路径：~/.acme.sh/dnsapi/dns_dnshe.sh
# 使用前提：
#   1. 已安装 acme.sh
#   2. 已在 DNSHE 控制台创建 API Key
#   3. 已通过 API 查询到域名的 subdomain_id
#
# 必须设置的环境变量（首次 export 后 acme.sh 会自动持久化保存）:
#   export DNSHE_API_Key="cfsd_xxxxxxxxxx"
#   export DNSHE_API_Secret="yyyyyyyyyyyy"
#   export DNSHE_Subdomain_Id="123"   ← 你的域名内部 ID，非字符串
#
# 查询 subdomain_id 的方法：
#   curl -s "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list" \
#     -H "X-API-Key: cfsd_xxxxxxxxxx" \
#     -H "X-API-Secret: yyyyyyyyyyyy" | python3 -m json.tool
#
# API 文档版本：DNSHE Free Domain API V2.0
# 参考：https://api005.dnshe.com/index.php?m=domain_hub
#
# 【重要】传播验证机制说明：
#   DNSHE 的多台权威 NS 节点存在同步延迟（可通过 SOA Serial 不一致观察到）。
#   API 写入成功仅代表记录进入数据库，并不代表所有节点已同步。
#   Let's Encrypt 从全球多个视角验证 DNS，若有解析器命中旧节点则返回 NXDOMAIN。
#   本脚本在 API 写入成功后，会轮询 8.8.8.8 / 1.1.1.1 / 9.9.9.9 三个解析器，
#   确认三者均能查到 TXT 记录后再通知 acme.sh 继续验证，从根本上消除此类失败。
#   因此使用本脚本时，建议设置 --dnssleep 1（传播验证已在脚本内完成）。
# ============================================================

DNSHE_API_URL="https://api005.dnshe.com/index.php?m=domain_hub"

# ────────────────────────────────────────────────────────────
# dns_dnshe_add()
# 功能：向 DNSHE 添加 TXT 记录（acme.sh 颁证验证阶段自动调用）
# 参数：
#   $1 = fulldomain  (例: _acme-challenge.myapp.cc.cd)
#   $2 = txtvalue    (acme.sh 生成的随机校验字符串)
# ────────────────────────────────────────────────────────────
dns_dnshe_add() {
  fulldomain="$1"
  txtvalue="$2"

  _info "=== DNSHE DNS Plugin: 开始添加 TXT 记录 ==="
  _info "域名: $fulldomain"
  _info "TXT值: $txtvalue"

  # ── 读取凭证 ──────────────────────────────────────────────
  # 优先读取环境变量，否则从 acme.sh 配置文件中读取（续期时使用）
  DNSHE_API_Key="${DNSHE_API_Key:-$(_readaccountconf_mutable DNSHE_API_Key)}"
  DNSHE_API_Secret="${DNSHE_API_Secret:-$(_readaccountconf_mutable DNSHE_API_Secret)}"
  DNSHE_Subdomain_Id="${DNSHE_Subdomain_Id:-$(_readaccountconf_mutable DNSHE_Subdomain_Id)}"

  # ── 校验凭证完整性 ────────────────────────────────────────
  if [ -z "$DNSHE_API_Key" ] || [ -z "$DNSHE_API_Secret" ]; then
    _err "❌ 未找到 DNSHE API 凭证！请先执行："
    _err "   export DNSHE_API_Key='cfsd_xxxxxxxxxx'"
    _err "   export DNSHE_API_Secret='yyyyyyyyyyyy'"
    return 1
  fi

  if [ -z "$DNSHE_Subdomain_Id" ]; then
    _err "❌ 未找到 DNSHE_Subdomain_Id！请先执行："
    _err "   export DNSHE_Subdomain_Id='123'  (替换为你的域名 ID)"
    _err "查询命令："
    _err "   curl -s 'https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list' \\"
    _err "     -H 'X-API-Key: \$DNSHE_API_Key' -H 'X-API-Secret: \$DNSHE_API_Secret'"
    return 1
  fi

  # ── 持久化保存凭证 ────────────────────────────────────────
  # acme.sh 会将这些值保存到 ~/.acme.sh/account.conf
  # 后续自动续期时无需再次 export
  _saveaccountconf_mutable DNSHE_API_Key "$DNSHE_API_Key"
  _saveaccountconf_mutable DNSHE_API_Secret "$DNSHE_API_Secret"
  _saveaccountconf_mutable DNSHE_Subdomain_Id "$DNSHE_Subdomain_Id"

  # ── 构建 API 请求 ─────────────────────────────────────────
  # DNSHE API V2.0: POST JSON, 认证通过 Header 传递
  # name 字段：填写完整 FQDN，API 会自动处理相对记录名
  body="{\"subdomain_id\": ${DNSHE_Subdomain_Id}, \"type\": \"TXT\", \"name\": \"${fulldomain}\", \"content\": \"${txtvalue}\", \"ttl\": 120}"

  _info "发送 API 请求..."
  _debug "请求体: $body"

  response=$(curl -s -X POST \
    "${DNSHE_API_URL}&endpoint=dns_records&action=create" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: ${DNSHE_API_Key}" \
    -H "X-API-Secret: ${DNSHE_API_Secret}" \
    -d "$body")

  _info "API 响应: $response"

  # ── 处理响应 ──────────────────────────────────────────────
  if _contains "$response" '"success":true' || _contains "$response" '"success": true'; then
    _info "✅ TXT 记录添加成功！"

    # ── 多解析器传播验证（核心修复）────────────────────────
    # 问题根因：DNSHE 多台权威 NS 的 SOA Serial 存在不一致，
    # API 写入成功后各节点同步需要时间，Let's Encrypt 多点查询
    # 若命中旧节点会返回 NXDOMAIN 导致验证失败。
    # 解决方案：轮询三个主流公共 DNS，三者均确认后才放行。
    _resolvers="8.8.8.8 1.1.1.1 9.9.9.9"
    _max_wait=300      # 最多等待 300 秒
    _check_interval=10 # 每 10 秒检查一次
    _elapsed=0

    _info "⏳ 开始等待 DNS 传播至多个公共解析器（最多 ${_max_wait}s）..."

    while [ "$_elapsed" -lt "$_max_wait" ]; do
      _all_ok=true
      for _resolver in $_resolvers; do
        _dig_result=$(dig "@${_resolver}" "${fulldomain}" TXT +short 2>/dev/null)
        if echo "$_dig_result" | grep -qF "$txtvalue"; then
          _info "  ✅ ${_resolver} 已看到记录"
        else
          _info "  ⏳ ${_resolver} 尚未同步（当前值: ${_dig_result:-空}）"
          _all_ok=false
        fi
      done

      if [ "$_all_ok" = "true" ]; then
        _info "🎉 所有解析器均已同步，DNS 传播完成！"
        return 0
      fi

      _info "   等待 ${_check_interval}s 后重试... (已等待 ${_elapsed}s / ${_max_wait}s)"
      sleep "$_check_interval"
      _elapsed=$(( _elapsed + _check_interval ))
    done

    _err "❌ DNS 传播超时（${_max_wait}s 内未能同步到所有解析器），Let's Encrypt 验证可能失败！"
    _err "   建议检查 DNSHE 控制台确认记录是否创建成功，或适当增大超时时间。"
    return 1
  else
    # 提取错误码辅助排查
    error_code=$(echo "$response" | sed 's/.*"error_code"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    _err "❌ TXT 记录添加失败！"
    _err "   错误码: $error_code"
    _err "   完整响应: $response"
    return 1
  fi
}

# ────────────────────────────────────────────────────────────
# dns_dnshe_rm()
# 功能：从 DNSHE 删除 TXT 记录（验证完成后 acme.sh 自动调用清理）
# 参数：
#   $1 = fulldomain  (同 add 时传入的值)
#   $2 = txtvalue    (同 add 时传入的 TXT 值)
# ────────────────────────────────────────────────────────────
dns_dnshe_rm() {
  fulldomain="$1"
  txtvalue="$2"

  _info "=== DNSHE DNS Plugin: 开始删除 TXT 记录 ==="
  _info "域名: $fulldomain"
  _info "TXT值: $txtvalue"

  # ── 读取凭证 ──────────────────────────────────────────────
  DNSHE_API_Key="${DNSHE_API_Key:-$(_readaccountconf_mutable DNSHE_API_Key)}"
  DNSHE_API_Secret="${DNSHE_API_Secret:-$(_readaccountconf_mutable DNSHE_API_Secret)}"
  DNSHE_Subdomain_Id="${DNSHE_Subdomain_Id:-$(_readaccountconf_mutable DNSHE_Subdomain_Id)}"

  if [ -z "$DNSHE_API_Key" ] || [ -z "$DNSHE_API_Secret" ] || [ -z "$DNSHE_Subdomain_Id" ]; then
    _err "❌ 凭证读取失败，无法删除 TXT 记录！请检查环境变量或 acme.sh 配置文件。"
    return 1
  fi

  # ── Step 1: 列出所有 DNS 记录，找到目标记录的 id ──────────
  _info "正在查询 DNS 记录列表..."
  list_response=$(curl -s -X GET \
    "${DNSHE_API_URL}&endpoint=dns_records&action=list&subdomain_id=${DNSHE_Subdomain_Id}" \
    -H "X-API-Key: ${DNSHE_API_Key}" \
    -H "X-API-Secret: ${DNSHE_API_Secret}")

  _debug "记录列表响应: $list_response"

  # ── Step 2: 解析 JSON 找到匹配 txtvalue 的记录 id ─────────
  # 策略：将 JSON 展开为多行，定位包含 txtvalue 的块，提取其 id
  # 这是不依赖 jq 的轻量解析方法
  record_id=$(echo "$list_response" \
    | tr '{' '\n' \
    | grep "\"$txtvalue\"" \
    | sed 's/.*"id"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/' \
    | grep '^[0-9]' \
    | head -1)

  # 如果上面的方法失败，尝试备用解析策略
  if [ -z "$record_id" ]; then
    record_id=$(echo "$list_response" \
      | tr ',' '\n' \
      | grep -A5 "\"$txtvalue\"" \
      | grep '"id"' \
      | head -1 \
      | tr -dc '0-9')
  fi

  if [ -z "$record_id" ]; then
    _info "⚠️  未在记录列表中找到 TXT 值为 '$txtvalue' 的记录，可能已被删除，跳过。"
    return 0
  fi

  _info "找到目标记录 ID: $record_id，准备删除..."

  # ── Step 3: 发送删除请求 ───────────────────────────────────
  del_body="{\"id\": ${record_id}}"
  del_response=$(curl -s -X POST \
    "${DNSHE_API_URL}&endpoint=dns_records&action=delete" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: ${DNSHE_API_Key}" \
    -H "X-API-Secret: ${DNSHE_API_Secret}" \
    -d "$del_body")

  _info "删除响应: $del_response"

  # ── 处理删除响应 ───────────────────────────────────────────
  if _contains "$del_response" '"success":true' || _contains "$del_response" '"success": true'; then
    _info "✅ TXT 记录删除成功，DNS 已清理干净。"
    return 0
  else
    error_code=$(echo "$del_response" | sed 's/.*"error_code"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    _err "❌ TXT 记录删除失败！错误码: $error_code，响应: $del_response"
    # 删除失败不影响证书颁发，仅记录错误，返回 0 避免中断流程
    return 0
  fi
}

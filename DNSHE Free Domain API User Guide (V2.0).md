# DNSHE Free Domain API User Guide (V2.0)

## Basic Information

- **API Endpoint**: `https://api005.dnshe.com/index.php?m=domain_hub`
- **Authentication Method**: API Key + API Secret
- **Supported Format**: JSON
- **Rate Limit**: Default 30 requests/minute

## Authentication

### Obtain API Credentials

1. Log in to the client area
2. Navigate to the "Free Domain Management" page
3. Find "API Management" in the left navigation bar
4. Click "Create API Key"

### Authentication Methods

#### Method 1: HTTP Header (Recommended)

```bash
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"
```

#### Method 2: URL/Body Parameters (Disabled)

For security reasons, `api_key` / `api_secret` are no longer supported via URL Query or request body. Please use only the `X-API-Key` and `X-API-Secret` request headers for authentication.

---

## API Endpoints

### Subdomain Management

#### 1.1 List Subdomains

- **Endpoint**: `subdomains`
- **Action**: `list`
- **Method**: `GET`

**Query Parameters**:

| Parameter     | Type    | Required | Default | Description                                                                                                                                                                                                                                  |
| ------------- | ------- | -------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| page          | integer | No       | 1       | Page number (starting from 1)                                                                                                                                                                                                                |
| per_page      | integer | No       | 200     | Items per page (1-500)                                                                                                                                                                                                                       |
| include_total | boolean | No       | false   | Whether to return the total count (slower for large datasets)                                                                                                                                                                                |
| search        | string  | No       | -       | Search keyword (matches subdomain or rootdomain)                                                                                                                                                                                             |
| rootdomain    | string  | No       | -       | Filter by root domain                                                                                                                                                                                                                        |
| status        | string  | No       | -       | Filter by status (active/suspended/expired)                                                                                                                                                                                                  |
| created_from  | string  | No       | -       | Creation start date (YYYY-MM-DD)                                                                                                                                                                                                             |
| created_to    | string  | No       | -       | Creation end date (YYYY-MM-DD)                                                                                                                                                                                                               |
| sort_by       | string  | No       | id      | Sort field (id/created_at/updated_at/expires_at/subdomain)                                                                                                                                                                                   |
| sort_dir      | string  | No       | desc    | Sort direction (asc/desc)                                                                                                                                                                                                                    |
| fields        | string  | No       | all     | Return fields (comma-separated). Optional: id,subdomain,rootdomain,full_domain,status,created_at,updated_at,expires_at,never_expires,cloudflare_zone_id,provider_account_id; id will be automatically added when custom fields are specified |

**Basic Request Example**:

```bash
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"
```

**Pagination Request Example**:

```bash
# Get page 1 (100 items per page)
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list&page=1&per_page=100" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"

# Get page 2 and return total count
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list&page=2&per_page=100&include_total=1" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"
```

**Search and Filter Example**:

```bash
# Search for domains containing "test"
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list&search=test" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"

# View only domains under example.com
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list&rootdomain=example.com" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"

# View suspended domains
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list&status=suspended" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"

# View domains created in January 2025
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list&created_from=2025-01-01&created_to=2025-01-31" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"

# Sort by expiration time in ascending order
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list&sort_by=expires_at&sort_dir=asc" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"

# Combined query: search for active domains starting with "test", sort by creation time in descending order, 50 items per page
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list&search=test&status=active&sort_by=created_at&sort_dir=desc&per_page=50" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"

# Return only ID and domain fields (reduce data transfer)
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=list&fields=id,subdomain,rootdomain,status" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"
```

**Basic Response Example**:

```json
{
  "success": true,
  "count": 2,
  "subdomains": [
    {
      "id": 1,
      "subdomain": "test",
      "rootdomain": "example.com",
      "full_domain": "test.example.com",
      "status": "active",
      "created_at": "2025-10-19 10:00:00",
      "updated_at": "2025-10-19 10:00:00"
    },
    {
      "id": 2,
      "subdomain": "api",
      "rootdomain": "example.com",
      "full_domain": "api.example.com",
      "status": "active",
      "created_at": "2025-10-19 11:00:00",
      "updated_at": "2025-10-19 11:00:00"
    }
  ]
}
```

**Pagination Response Example**:

```json
{
  "success": true,
  "count": 100,
  "subdomains": [
    {
      "id": 201,
      "subdomain": "app201",
      "rootdomain": "example.com",
      "full_domain": "app201.example.com",
      "status": "active",
      "created_at": "2025-10-19 10:00:00",
      "updated_at": "2025-10-19 10:00:00"
    }
  ],
  "pagination": {
    "page": 2,
    "per_page": 100,
    "has_more": true,
    "next_page": 3,
    "prev_page": 1,
    "total": 12500
  }
}
```

**Performance Optimization Suggestions**:

- Default 200 items per page; it is recommended to adjust `per_page` according to needs (50-100 is recommended)
- `include_total=1` will execute a COUNT query, which may be slow for large datasets; use only when necessary
- Judging whether there is a next page through `pagination.has_more` is more efficient than relying on `total`
- Using the `fields` parameter can significantly reduce data transfer volume
- Maximum `per_page=500`; values exceeding this will be automatically limited to 500
- For 10,000+ domains, it is recommended to use search and filter functions to accurately locate target domains

---

#### 1.2 Register Subdomain

- **Endpoint**: `subdomains`
- **Action**: `register`
- **Method**: `POST`

**Request Parameters**:

| Parameter  | Type   | Required | Description      |
| ---------- | ------ | -------- | ---------------- |
| subdomain  | string | Yes      | Subdomain prefix |
| rootdomain | string | Yes      | Root domain      |

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=register" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain": "myapp",
    "rootdomain": "example.com"
  }'
```

**Response Example**:

```json
{
  "success": true,
  "message": "Subdomain registered successfully",
  "subdomain_id": 3,
  "full_domain": "myapp.example.com"
}
```

---

#### 1.3 Get Subdomain Details

- **Endpoint**: `subdomains`
- **Action**: `get`
- **Method**: `GET`

**Request Parameters**:

| Parameter    | Type    | Required | Description  |
| ------------ | ------- | -------- | ------------ |
| subdomain_id | integer | Yes      | Subdomain ID |

**Request Example**:

```bash
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=get&subdomain_id=1" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"
```

**Response Example**:

```json
{
  "success": true,
  "subdomain": {
    "id": 1,
    "subdomain": "test",
    "rootdomain": "example.com",
    "full_domain": "test.example.com",
    "status": "active",
    "created_at": "2025-10-19 10:00:00",
    "updated_at": "2025-10-19 10:00:00"
  },
  "dns_records": [
    {
      "id": 1,
      "name": "test.example.com",
      "type": "A",
      "content": "192.168.1.1",
      "ttl": 600,
      "priority": null,
      "status": "active",
      "created_at": "2025-10-19 10:05:00"
    }
  ],
  "dns_count": 1
}
```

---

#### 1.4 Delete Subdomain

- **Endpoint**: `subdomains`
- **Action**: `delete`
- **Method**: `POST` or `DELETE`

**Request Parameters**:

| Parameter    | Type    | Required | Description  |
| ------------ | ------- | -------- | ------------ |
| subdomain_id | integer | Yes      | Subdomain ID |

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=delete" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain_id": 1
  }'
```

**Response Example**:

```json
{
  "success": true,
  "message": "Subdomain deleted successfully",
  "subdomain_id": 1,
  "full_domain": "test.example.com",
  "dns_records_deleted": 4
}
```

---

#### 1.5 Renew Subdomain

- **Endpoint**: `subdomains`
- **Action**: `renew`
- **Method**: `POST` or `PUT`

**Request Parameters**:

| Parameter    | Type    | Required | Description  |
| ------------ | ------- | -------- | ------------ |
| subdomain_id | integer | Yes      | Subdomain ID |

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=subdomains&action=renew" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain_id": 3
  }'
```

**Response Example**:

```json
{
  "success": true,
  "message": "Subdomain renewed successfully (charged 9.90 credit)",
  "subdomain_id": 3,
  "subdomain": "myapp",
  "previous_expires_at": "2025-05-01 00:00:00",
  "new_expires_at": "2026-05-01 00:00:00",
  "renewed_at": "2025-04-10 12:34:56",
  "never_expires": 0,
  "status": "active",
  "remaining_days": 366,
  "charged_amount": 9.9
}
```

**Description**: `charged_amount` indicates the amount deducted from the user's account balance for this renewal. If the renewal is free or the deduction amount is 0, this field will be `0`.

**Possible Errors**:

- `403 renewal disabled`: No valid registration period is configured in the backend.
- `422 renewal not yet available`: The free renewal window has not yet opened (returns `error_code=renewal_not_yet_available` and remaining time field).
- `403 redemption period requires administrator`: The domain is in the redemption period and the backend is configured for manual processing.
- `403 renewal window expired`: The renewal grace period has expired.
- `402 insufficient balance for redemption renewal`: The redemption period is set to automatic deduction, but the account balance is insufficient.
- `404 subdomain not found`: The corresponding subdomain cannot be found or does not belong to the current API Key.

---

### DNS Record Management

#### 2.1 List DNS Records

- **Endpoint**: `dns_records`
- **Action**: `list`
- **Method**: `GET`

**Request Parameters**:

| Parameter    | Type    | Required | Description  |
| ------------ | ------- | -------- | ------------ |
| subdomain_id | integer | Yes      | Subdomain ID |

**Request Example**:

```bash
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=dns_records&action=list&subdomain_id=1" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"
```

**Response Example**:

```json
{
  "success": true,
  "count": 2,
  "records": [
    {
      "id": 1,
      "record_id": "5a0ce6c4d1d4c71bc5e60a2a2a0e4997",
      "name": "test.example.com",
      "type": "A",
      "content": "192.168.1.1",
      "ttl": 600,
      "priority": null,
      "line": null,
      "proxied": false,
      "status": "active",
      "created_at": "2025-10-19 10:05:00",
      "updated_at": "2025-10-19 10:05:00"
    },
    {
      "id": 2,
      "name": "www.test.example.com",
      "type": "CNAME",
      "content": "test.example.com",
      "ttl": 600,
      "priority": null,
      "proxied": false,
      "status": "active",
      "created_at": "2025-10-19 10:10:00"
    }
  ]
}
```

**Note**: The list returns both the internal module `id` and the cloud DNS provider `record_id`. Either field can be used to locate the record for `update`/`delete` (using `id` is recommended).

---

#### 2.2 Create DNS Record

- **Endpoint**: `dns_records`
- **Action**: `create`
- **Method**: `POST`

**Request Parameters**:

| Parameter              | Type    | Required               | Description                                                                           |
| ---------------------- | ------- | ---------------------- | ------------------------------------------------------------------------------------- |
| subdomain_id           | integer | Yes                    | Subdomain ID                                                                          |
| type                   | string  | Yes                    | Record type (A/AAAA/CNAME/MX/TXT/NS/SRV/CAA)                                          |
| name                   | string  | No                     | Record name (`@` or empty = current subdomain itself; full domain is supported)       |
| content                | string  | Conditionally Required | Record value (SRV/CAA can be automatically assembled from structured parameters)      |
| ttl                    | integer | No                     | TTL value (default 600)                                                               |
| priority               | integer | No                     | MX priority (default 10 for MX)/SRV priority (default 0 for SRV)                      |
| line                   | string  | No                     | Resolution line (available for us.ci/cn.mt, automatically ignored by other providers) |
| record_weight / weight | integer | No                     | SRV weight                                                                            |
| record_port / port     | integer | No                     | SRV port (1-65535)                                                                    |
| record_target / target | string  | No                     | SRV target host                                                                       |
| caa_flag               | integer | No                     | CAA flag (default 0)                                                                  |
| caa_tag                | string  | No                     | CAA tag (default issue)                                                               |
| caa_value              | string  | No                     | CAA value                                                                             |

**Note**: If NS management is disabled in the backend (`disable_ns_management`), writing `NS` type records will be rejected.

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=dns_records&action=create" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain_id": 1,
    "type": "A",
    "content": "192.168.1.100",
    "ttl": 600
  }'
```

**Response Example**:

```json
{
  "success": true,
  "message": "DNS record created successfully",
  "id": 3,
  "record_id": "5a0ce6c4d1d4c71bc5e60a2a2a0e4997"
}
```

---

#### 2.3 Update DNS Record

- **Endpoint**: `dns_records`
- **Action**: `update`
- **Method**: `POST` or `PUT` or `PATCH`

**Request Parameters**:

| Parameter                      | Type    | Required | Description                                                          |
| ------------------------------ | ------- | -------- | -------------------------------------------------------------------- |
| record_id                      | string  | No       | Record positioning ID (can pass module `id` or provider `record_id`) |
| id                             | integer | No       | Internal module record ID (recommended)                              |
| type                           | string  | No       | New type (A/AAAA/CNAME/MX/TXT/NS/SRV/CAA)                            |
| name                           | string  | No       | New name (`@` or empty = current subdomain itself)                   |
| content                        | string  | No       | New record value                                                     |
| ttl                            | integer | No       | New TTL value                                                        |
| priority                       | integer | No       | MX/SRV priority                                                      |
| line                           | string  | No       | Resolution line                                                      |
| record_weight / weight         | integer | No       | SRV weight                                                           |
| record_port / port             | integer | No       | SRV port                                                             |
| record_target / target         | string  | No       | SRV target host                                                      |
| caa_flag / caa_tag / caa_value | mixed   | No       | CAA structured parameters                                            |

**Note**: At least one of `record_id` or `id` must be provided.

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=dns_records&action=update" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "type": "A",
    "content": "192.168.1.200",
    "ttl": 600
  }'
```

**Response Example**:

```json
{
  "success": true,
  "message": "DNS record updated successfully",
  "id": 1,
  "record_id": "5a0ce6c4d1d4c71bc5e60a2a2a0e4997"
}
```

---

#### 2.4 Delete DNS Record

- **Endpoint**: `dns_records`
- **Action**: `delete`
- **Method**: `POST` or `DELETE`

**Request Parameters**:

| Parameter | Type    | Required | Description                                                                                        |
| --------- | ------- | -------- | -------------------------------------------------------------------------------------------------- |
| record_id | string  | No       | Record ID returned by the cloud DNS provider. If provided, it will be matched first.               |
| id        | integer | No       | Internal module record ID, which can directly use the `id` value returned by the `list` interface. |

**Note**: At least one of `record_id` or `id` must be provided.

**Request Examples**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=dns_records&action=delete" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1
  }'
```

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=dns_records&action=delete" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "record_id": "5a0ce6c4d1d4c71bc5e60a2a2a0e4997"
  }'
```

**Response Example**:

```json
{
  "success": true,
  "message": "DNS record deleted successfully"
}
```

---

### API Key Management

#### 3.1 List API Keys

- **Endpoint**: `keys`
- **Action**: `list`
- **Method**: `GET`

**Request Example**:

```bash
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=keys&action=list" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"
```

**Response Example**:

```json
{
  "success": true,
  "count": 2,
  "keys": [
    {
      "id": 1,
      "key_name": "Production Environment Key",
      "api_key": "cfsd_xxxxxxxxxx",
      "status": "active",
      "request_count": 1523,
      "last_used_at": "2025-10-19 15:30:00",
      "created_at": "2025-10-19 10:00:00"
    },
    {
      "id": 2,
      "key_name": "test-key",
      "api_key": "cfsd_yyyyyyyyyy",
      "status": "active",
      "request_count": 45,
      "last_used_at": "2025-10-19 14:00:00",
      "created_at": "2025-10-19 11:00:00"
    }
  ]
}
```

---

#### 3.2 Create API Key

- **Endpoint**: `keys`
- **Action**: `create`
- **Method**: `POST`

**Request Parameters**:

| Parameter    | Type   | Required | Description                                                                                                                                       |
| ------------ | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| key_name     | string | Yes      | API key name                                                                                                                                      |
| ip_whitelist | string | No       | IP whitelist (separated by commas/newlines/semicolons, supports single IP or CIDR; "Enable API IP Whitelist" must be turned on in the background) |

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=keys&action=create" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "key_name": "New API Key",
    "ip_whitelist": "192.168.1.1,192.168.1.2"
  }'
```

**Response Example**:

```json
{
  "success": true,
  "message": "API key created successfully",
  "api_key": "cfsd_zzzzzzzzzz",
  "api_secret": "aaaaaaaaaaaaaaaa",
  "warning": "Please save the api_secret, it will not be shown again"
}
```

> **Important**: The `api_secret` is only displayed once, please save it properly!

---

#### 3.3 Delete API Key

- **Endpoint**: `keys`
- **Action**: `delete`
- **Method**: `POST` or `DELETE`

**Request Parameters**:

| Parameter | Type    | Required | Description |
| --------- | ------- | -------- | ----------- |
| key_id    | integer | Yes      | API key ID  |

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=keys&action=delete" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "key_id": 2
  }'
```

**Response Example**:

```json
{
  "success": true,
  "message": "API key deleted successfully"
}
```

---

#### 3.4 Regenerate API Key

- **Endpoint**: `keys`
- **Action**: `regenerate`
- **Method**: `POST`

**Request Parameters**:

| Parameter | Type    | Required | Description |
| --------- | ------- | -------- | ----------- |
| key_id    | integer | Yes      | API key ID  |

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=keys&action=regenerate" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "key_id": 1
  }'
```

**Response Example**:

```json
{
  "success": true,
  "message": "API secret regenerated successfully",
  "api_key": "cfsd_xxxxxxxxxx",
  "api_secret": "new_secret_here",
  "warning": "Please save the new api_secret, it will not be shown again"
}
```

---

### Quota Query

#### 4.1 Query Quota

- **Endpoint**: `quota`
- **Method**: `GET`

**Request Example**:

```bash
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=quota" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"
```

**Response Example**:

```json
{
  "success": true,
  "quota": {
    "used": 3,
    "base": 5,
    "invite_bonus": 2,
    "total": 7,
    "available": 4
  }
}
```

---

### Error Codes and Unified Error Structure

Starting from the current version, all API error responses follow the unified structure below:

```json
{
  "success": false,
  "error_code": "auth_invalid_credentials",
  "message": "Invalid API key",
  "details": {
    "request_id": "optional"
  },
  "error": "Invalid API key"
}
```

**Field Description**:

| Field      | Type    | Description                                                   |
| ---------- | ------- | ------------------------------------------------------------- |
| success    | boolean | Fixed to false                                                |
| error_code | string  | Stable error code (recommended for business-side processing)  |
| message    | string  | Human-readable error description                              |
| details    | object  | Optional, additional context (e.g., limit/remaining/reset_at) |
| error      | string  | Compatible with old clients (same as message)                 |

**Common Error Codes**:

| error_code                                             | HTTP Status Code | Description                            |
| ------------------------------------------------------ | ---------------- | -------------------------------------- |
| bad_request                                            | 400              | Invalid request parameters             |
| auth_invalid_credentials                               | 401              | Invalid or missing API Key/Secret      |
| auth_ip_not_allowed                                    | 403              | Request IP not in whitelist            |
| api_access_disabled                                    | 403              | API access disabled in the background  |
| not_found / subdomain_not_found / dns_record_not_found | 404              | Resource not found                     |
| quota_exceeded                                         | 429              | Quota exceeded                         |
| rate_limit_exceeded                                    | 429              | Request rate limit exceeded            |
| provider_operation_failed                              | 502              | Upstream DNS provider operation failed |
| internal_error                                         | 500              | Internal service error                 |

---

### Rate Limiting

- **Default Limit**: 60 requests/minute
- **Response Headers**: Rate limiting information is included in the request response

**Rate Limit Exceeded Response Example**:

```json
{
  "success": false,
  "error_code": "rate_limit_exceeded",
  "message": "Rate limit exceeded",
  "details": {
    "limit": 60,
    "remaining": 0,
    "reset_at": "2025-10-19 15:31:00"
  },
  "error": "Rate limit exceeded"
}
```

---

### SDK Examples

#### PHP Example

```php
<?php
class CloudflareSubdomainAPI {
    private $baseUrl;
    private $apiKey;
    private $apiSecret;

    public function __construct($baseUrl, $apiKey, $apiSecret) {
        $this->baseUrl = rtrim($baseUrl, '/');
        $this->apiKey = $apiKey;
        $this->apiSecret = $apiSecret;
    }

    private function request($endpoint, $action, $method = 'GET', $data = []) {
        $url = $this->baseUrl . '?m=domain_hub&endpoint=' . $endpoint . '&action=' . $action;

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'X-API-Key: ' . $this->apiKey,
            'X-API-Secret: ' . $this->apiSecret,
            'Content-Type: application/json'
        ]);

        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        return json_decode($response, true);
    }

    // List subdomains
    public function listSubdomains() {
        return $this->request('subdomains', 'list', 'GET');
    }

    // Register subdomain
    public function registerSubdomain($subdomain, $rootdomain) {
        return $this->request('subdomains', 'register', 'POST', [
            'subdomain' => $subdomain,
            'rootdomain' => $rootdomain
        ]);
    }

    // Create DNS record
    public function createDnsRecord($subdomainId, $type, $content, $ttl = 600) {
        return $this->request('dns_records', 'create', 'POST', [
            'subdomain_id' => $subdomainId,
            'type' => $type,
            'content' => $content,
            'ttl' => $ttl
        ]);
    }
}

// Usage Example
$api = new CloudflareSubdomainAPI(
    'https://api005.dnshe.com/index.php',
    'cfsd_xxxxxxxxxx',
    'yyyyyyyyyyyy'
);

// List subdomains
$result = $api->listSubdomains();
print_r($result);

// Register new subdomain
$result = $api->registerSubdomain('myapp', 'example.com');
print_r($result);
```

#### Python Example

```python
import requests
import json

class CloudflareSubdomainAPI:
    def __init__(self, base_url, api_key, api_secret):
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self.api_secret = api_secret
        self.headers = {
            'X-API-Key': api_key,
            'X-API-Secret': api_secret,
            'Content-Type': 'application/json'
        }

    def request(self, endpoint, action, method='GET', data=None):
        url = f"{self.base_url}?m=domain_hub&endpoint={endpoint}&action={action}"

        if method == 'GET':
            response = requests.get(url, headers=self.headers)
        else:
            response = requests.post(url, headers=self.headers, json=data)

        return response.json()

    def list_subdomains(self):
        return self.request('subdomains', 'list', 'GET')

    def register_subdomain(self, subdomain, rootdomain):
        return self.request('subdomains', 'register', 'POST', {
            'subdomain': subdomain,
            'rootdomain': rootdomain
        })

    def create_dns_record(self, subdomain_id, record_type, content, ttl=600):
        return self.request('dns_records', 'create', 'POST', {
            'subdomain_id': subdomain_id,
            'type': record_type,
            'content': content,
            'ttl': ttl
        })

# Usage Example
api = CloudflareSubdomainAPI(
    'https://api005.dnshe.com/index.php',
    'cfsd_xxxxxxxxxx',
    'yyyyyyyyyyyy'
)

# List subdomains
result = api.list_subdomains()
print(result)

# Register new subdomain
result = api.register_subdomain('myapp', 'example.com')
print(result)
```

#### JavaScript Example

```javascript
class CloudflareSubdomainAPI {
    constructor(baseUrl, apiKey, apiSecret) {
        this.baseUrl = baseUrl.replace(/\/$/, '');
        this.apiKey = apiKey;
        this.apiSecret = apiSecret;
    }

    async request(endpoint, action, method = 'GET', data = null) {
        const url = `${this.baseUrl}?m=domain_hub&endpoint=${endpoint}&action=${action}`;

        const options = {
            method: method,
            headers: {
                'X-API-Key': this.apiKey,
                'X-API-Secret': this.apiSecret,
                'Content-Type': 'application/json'
            }
        };

        if (method === 'POST' && data) {
            options.body = JSON.stringify(data);
        }

        const response = await fetch(url, options);
        return await response.json();
    }

    async listSubdomains() {
        return await this.request('subdomains', 'list', 'GET');
    }

    async registerSubdomain(subdomain, rootdomain) {
        return await this.request('subdomains', 'register', 'POST', {
            subdomain: subdomain,
            rootdomain: rootdomain
        });
    }

    async createDnsRecord(subdomainId, type, content, ttl = 600) {
        return await this.request('dns_records', 'create', 'POST', {
            subdomain_id: subdomainId,
            type: type,
            content: content,
            ttl: ttl
        });
    }
}

// Usage Example
const api = new CloudflareSubdomainAPI(
    'https://api005.dnshe.com/index.php',
    'cfsd_xxxxxxxxxx',
    'yyyyyyyyyyyy'
);

// List subdomains
api.listSubdomains().then(result => {
    console.log(result);
});

// Register new subdomain
api.registerSubdomain('myapp', 'example.com').then(result => {
    console.log(result);
});
```

---

### WHOIS Query (Public API)

This interface is used to query WHOIS information externally, supporting both internal subdomains and external domains. By default, no API key is required, and the system will apply a rate limit based on the accessing IP (default 30 times/minute). If the system enforces API verification, then an API key must be used for the query.

- **Endpoint**: `whois`
- **Method**: `GET`

**Parameters**:

| Parameter | Type   | Required | Description                             |
| --------- | ------ | -------- | --------------------------------------- |
| domain    | string | Yes      | Full subdomain, e.g., `foo.example.com` |

**Request Example (Public Mode)**:

```bash
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=whois&domain=foo.example.com"
```

**Request Example (When API Key is Required)**:

```bash
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=whois&domain=foo.example.com" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"
```

**Response Example (Registered)**:

```json
{
  "success": true,
  "domain": "foo.example.com",
  "status": "active",
  "registered_at": "2025-01-10 08:30:00",
  "expires_at": "2026-01-10 08:30:00",
  "registrant_email": "whois@example.com",
  "nameservers": [
    "ns1.example.net",
    "ns2.example.net"
  ],
  "rate_limit": {
    "limit": 2,
    "remaining": 1,
    "reset_at": "2025-01-10 08:31:00"
  }
}
```

**Response Example (Unregistered)**:

```json
{
  "success": true,
  "domain": "foo.example.com",
  "registered": false,
  "status": "unregistered",
  "message": "domain not registered"
}
```

**Note**:

- The content of `registrant_email` depends on whether domain privacy protection is enabled.
- A `name_servers` field is also returned with content identical to `nameservers` to facilitate compatibility across different SDKs.
- For unregistered domains, the API returns `registered=false` and `status=unregistered`, along with the full queried domain name.
- When API Key mode is not enabled, the `rate_limit` field in the response body displays the remaining quota for the current IP.

---

### Permanent Upgrade Center

#### 8.1 Query My Permanent Upgrade Status

- **Endpoint**: `permanent_upgrade`
- **Action**: `list`
- **Method**: `GET`

**Parameters**:

| Parameter | Type    | Required | Description                          |
| --------- | ------- | -------- | ------------------------------------ |
| page      | integer | No       | Page number, default is 1            |
| per_page  | integer | No       | Number of items per page, maximum 50 |

**Request Example**:

```bash
curl -X GET "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=permanent_upgrade&action=list&page=1&per_page=10" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy"
```

**Response Example**:

```json
{
  "success": true,
  "state": {
    "requests": [],
    "assist_logs": [],
    "eligible_subdomains": []
  }
}
```

#### 8.2 Create Permanent Upgrade Task

- **Endpoint**: `permanent_upgrade`
- **Action**: `create`
- **Method**: `POST` / `PUT`

**Parameters**:

| Parameter    | Type    | Required | Description         |
| ------------ | ------- | -------- | ------------------- |
| subdomain_id | integer | Yes      | Target subdomain ID |

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=permanent_upgrade&action=create" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain_id": 123
  }'
```

#### 8.3 Assist with Invitation Code

- **Endpoint**: `permanent_upgrade`
- **Action**: `assist`
- **Method**: `POST` / `PUT`

**Parameters**:

| Parameter   | Type   | Required | Description                       |
| ----------- | ------ | -------- | --------------------------------- |
| assist_code | string | Yes      | Invitation code shared by friends |

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=permanent_upgrade&action=assist" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "assist_code": "ABCD1234"
  }'
```

#### 8.4 Cancel Permanent Upgrade Task

- **Endpoint**: `permanent_upgrade`
- **Action**: `cancel`
- **Method**: `POST` / `DELETE`

**Parameters**:

| Parameter  | Type    | Required | Description     |
| ---------- | ------- | -------- | --------------- |
| request_id | integer | Yes      | Upgrade task ID |

**Request Example**:

```bash
curl -X POST "https://api005.dnshe.com/index.php?m=domain_hub&endpoint=permanent_upgrade&action=cancel" \
  -H "X-API-Key: cfsd_xxxxxxxxxx" \
  -H "X-API-Secret: yyyyyyyyyyyy" \
  -H "Content-Type: application/json" \
  -d '{
    "request_id": 456
  }'
```

**Common Errors**:

- `feature_disabled`: "Permanent Upgrade Center" is not enabled in the background
- `service_unavailable`: Service is unavailable
- `unknown action`: Incorrect action spelling or method mismatch

---

## Security Recommendations

### Protecting API Keys

- Do not hardcode API keys in client-side code.
- Use environment variables to store keys.
- Rotate your API keys regularly.

### IP Whitelisting

- Enable IP whitelisting for production environment keys.
- Allow access only from known server IP addresses.

### Principle of Least Privilege

- Create different API keys for different purposes.
- Delete unused keys promptly.

### Monitoring Usage

- Regularly check API request logs.
- Watch for abnormal request patterns.

### HTTPS

- Always use HTTPS for API calls.
- Avoid transmitting keys over insecure networks.

---

## FAQ

**Q1: What should I do if my API key is lost or compromised?**  
A: You can use the "Regenerate" action to create a new key. Once regenerated, the old key will be immediately invalidated.

**Q2: How can I increase my rate limit?**  
A: Please contact the administrator to adjust the "API Request Rate Limit" settings in the backend.

**Q3: Can I use API keys from sub-accounts?**  
A: No. API keys can only be created and managed by the main account.

**Q4: Does the API support batch operations?**  
A: Currently, batch operations are not supported. APIs must be called individually for each task.

**Q5: How can I view API usage statistics?**  
A: You can view the usage count and "Last Used" timestamp for each key in the "API Management" card within the Client Area.

---

## Changelog

### v2.0 (2026-04-25)

- Official release of V2.0.
- Optimized API command structure.
- Added new functional interfaces/endpoints.
- Improved pagination and query performance.
- Optimized error structures and security mechanisms.

### v1.0 (2025-10-19)

- Initial version release.
- Support for subdomain management.
- Support for DNS record management.
- Support for API key management.
- Support for quota queries.
- Support for rate limiting.
/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* BEGIN SQLCIPHER */
#if defined(SQLITE_HAS_CODEC) && defined(SQLCIPHER_CRYPTO_CUSTOM) 
#if defined(SQLCIPHER_CRYPTO_DEVLOCK) || !defined(SQLITE_CORE)

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <alloca.h>
#include "sqlite3ext.h"
SQLITE_EXTENSION_INIT1


static unsigned char g_device_salt[16];
static volatile int g_init = 0;


static int read_cpu_serial(char *buf, int buf_len) {
    int ret = 0;
    char line[256];
    FILE *fp = fopen("/proc/cpuinfo", "r");
    if (!fp) return 0;

    while (fgets(line, sizeof(line), fp)) {
        if (strncmp(line, "Serial", 6))
            continue;

        char *pch = strchr(line, ':');
        if (!pch) continue;

        char c;
        while ((c = *++pch) != 0) {
            if (c != ' ' && c != '\t') break;
        }

        while ((c = *pch++) != 0) {
            if (c == '\r' || c == '\n') break;
            if (ret >= buf_len) break;
            buf[ret++] = c;
        }
        break;
    }

    fclose(fp);
    return ret;
}

#ifdef __ANDROID__
#include <sys/system_properties.h>

static int read_android_serial(char *buf, int buf_len) {
    assert(buf_len >= PROP_VALUE_MAX);
    return __system_property_get("ro.serialno", buf);
}
#endif


static void init_device_salt(void *ctx) {
    if (g_init) return;

    char serial[256];
    int serial_len = 0;

#ifdef __ANDROID__
    serial_len += read_android_serial(serial + serial_len, sizeof(serial) - serial_len);
#endif
    serial_len += read_cpu_serial(serial + serial_len, sizeof(serial) - serial_len);
    
    sqlcipher_get_fallback_provider()->kdf(ctx, (unsigned char *) serial, serial_len, 
            (unsigned char *) serial, serial_len, 1, sizeof(g_device_salt), g_device_salt);

    g_init = 1;
}

static int sqlcipher_devlock_kdf(void *ctx, const unsigned char *pass, int pass_sz, unsigned char* salt, 
        int salt_sz, int workfactor, int key_sz, unsigned char *key) {

    const sqlcipher_provider *p = sqlcipher_get_fallback_provider();
    int ret = p->kdf(ctx, pass, pass_sz, salt, salt_sz, workfactor, key_sz, key);
    if (ret != SQLITE_OK)
        return ret;

    unsigned char *buf = alloca(key_sz);
    memcpy(buf, key, key_sz);
    return p->kdf(ctx, buf, key_sz, g_device_salt, sizeof(g_device_salt), 1, key_sz, key);
}

static const char *sqlcipher_devlock_get_provider_name(void *ctx) {
    return "devlock";
}

static const char *sqlcipher_devlock_get_provider_version(void *ctx) {
    return "0.1";
}

static int sqlcipher_devlock_set_cipher(void *ctx, const char *cipher_name) {
    return sqlcipher_get_fallback_provider()->set_cipher(ctx, "aes-256-cbc");
}

static const char *sqlcipher_devlock_get_cipher(void *ctx) {
    return "devlock";
}

static int sqlcipher_devlock_ctx_init(void **ctx) {
    sqlcipher_get_fallback_provider()->ctx_init(ctx);
    init_device_salt(*ctx);
    return SQLITE_OK;
}

static volatile int g_devlock_registered = 0;
static const sqlcipher_provider g_devlock_provider = {
    0,                                  /* activate */
    0,                                  /* deactivate */
    sqlcipher_devlock_get_provider_name,/* get_provider_name */
    0,                                  /* add_random */
    0,                                  /* random */
    0,                                  /* hmac */
    sqlcipher_devlock_kdf,              /* kdf */
    0,                                  /* cipher */
    sqlcipher_devlock_set_cipher,       /* set_cipher */
    sqlcipher_devlock_get_cipher,       /* get_cipher */
    0,                                  /* get_key_sz */
    0,                                  /* get_iv_sz */
    0,                                  /* get_block_sz */
    0,                                  /* get_hmac_sz */
    0,                                  /* ctx_copy */
    0,                                  /* ctx_cmp */
    sqlcipher_devlock_ctx_init,         /* ctx_init */
    0,                                  /* ctx_free */
    0,                                  /* fips_status */
    sqlcipher_devlock_get_provider_version
};

#ifndef SQLITE_CORE
#ifdef _WIN32
__declspec(dllexport)
#endif
int sqlite3_devlock_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi) {
    SQLITE_EXTENSION_INIT2(pApi);

    if (!g_devlock_registered) {
        g_devlock_registered = 1;
        return sqlcipher_register_custom_provider("devlock", &g_devlock_provider);
    }

    return SQLITE_OK;
}
#else /* SQLITE_CORE */
int sqlcipherCryptoDevlockInit() {
    g_devlock_registered = 1;
    return sqlcipher_register_custom_provider("devlock", &g_devlock_provider);
}
#endif

#endif /* defined(SQLCIPHER_CRYPTO_DEVLOCK) || !defined(SQLITE_CORE) */
#endif /* SQLITE_HAS_CODEC && SQLCIPHER_CRYPTO_CUSTOM */

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
#if defined(SQLCIPHER_CRYPTO_XXTEA) || !defined(SQLITE_CORE)

#include "sqlite3ext.h"
SQLITE_EXTENSION_INIT1


#define XXTEA_BLOCKBIT  32
#define XXTEA_KEYBIT    128
#define XXTEA_BLOCKBYTE (XXTEA_BLOCKBIT >> 3)
#define XXTEA_KEYBYTE   (XXTEA_KEYBIT >> 3)

#define XXTEA_DELTA  0x61C88647   /* -(0x9E3779B9) */
#define MX (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (key[(p&3)^e] ^ z)))


static void xxtea_encode(uint32_t *v, int n, uint32_t const key[4])
{
    uint32_t y, z, sum;
    unsigned p, rounds, e;

    /* rounds = 6 + 52/n; */
    /* For SQLCipher, encode/decode is done on a whole page, which is 512 bytes at least.
       n = (page_size - reserved_size) / 4, which will be always greater than 52, so we 
       save a division. */
    rounds = 6;
    sum = 0;
    z = v[n-1];
    do {
        sum -= XXTEA_DELTA;
        e = (sum >> 2) & 3;
        for (p = 0; p < n - 1; p++) {
            y = v[p + 1];
            z = v[p] += MX;
        }
        y = v[0];
        z = v[n - 1] += MX;
    } while (--rounds);
}

static void xxtea_decode(uint32_t *v, int n, uint32_t const key[4])
{
    uint32_t y, z, sum;
    unsigned p, rounds, e;

    /* rounds = 6 + 52/n; */
    /* For SQLCipher, encode/decode is done on a whole page, which is 512 bytes at least.
       n = (page_size - reserved_size) / 4, which will be always greater than 52, so we 
       save a division. */
    rounds = 6;
    sum = rounds * (-XXTEA_DELTA);
    y = v[0];
    do {
        e = (sum >> 2) & 3;
        for (p = n - 1; p > 0; p--) {
            z = v[p - 1];
            y = v[p] -= MX;
        }
        z = v[n - 1];
        y = v[0] -= MX;
    } while ((sum += XXTEA_DELTA) != 0);
}


typedef struct xxtea_context {
    int turns;
} xxtea_context;

static int sqlcipher_xxtea_cipher(void *ctx, int mode, unsigned char *key, int key_sz, unsigned char *iv, 
        unsigned char *in, int in_sz, unsigned char *out) {
	int n = in_sz / XXTEA_BLOCKBYTE;
	int turns = ((xxtea_context *) ctx)->turns;
    uint32_t xor_key = *(uint32_t *) iv;
    int i;

	//CODEC_TRACE(("sqlcipher_xxtea_cipher: cipher data %d\n",xxtea_turns));
	//CODEC_HEXDUMP("sqlcipher_xxtea_cipher: key data ", key,key_sz);

    if (!mode) {
        /* Decryption */
        for (i = 0; i < turns; i++) {
            /* It's OK to modify input buffer on decrytion mode, because it will be overwriten
               by plain-text page later on. */
            xxtea_decode((uint32_t *) in, n, (uint32_t *) key);
        }

        uint32_t *p_in = (uint32_t *) in;
        uint32_t *p_out = (uint32_t *) out;
        for (i = 0; i < n; i++) {
            *p_out++ = xor_key ^ *p_in;
            xor_key = *p_in++;
        }
    } else {
        /* Encryption */
        uint32_t *p_in = (uint32_t *) in;
        uint32_t *p_out = (uint32_t *) out;
        for (i = 0; i < n; i++) {
            xor_key ^= *p_in++;
            *p_out++ = xor_key;
        }

        for (i = 0; i < turns; i++) {
            xxtea_encode((uint32_t *) out, n, (uint32_t *) key);
        }
    }

	return SQLITE_OK; 
}

static const char *sqlcipher_xxtea_get_provider_name(void *ctx) {
    return "xxtea";
}

static const char *sqlcipher_xxtea_get_provider_version(void *ctx) {
    return "0.1";
}

static int sqlcipher_xxtea_set_cipher(void *ctx, const char *cipher_name) {
    return SQLITE_OK;
}

static const char *sqlcipher_xxtea_get_cipher(void *ctx) {
    return "xxtea";
}

static int sqlcipher_xxtea_get_key_sz(void *ctx) {
	return XXTEA_KEYBYTE;
}

static int sqlcipher_xxtea_get_iv_sz(void *ctx) {
    return 4;
}

static int sqlcipher_xxtea_get_block_sz(void *ctx) {
	return XXTEA_BLOCKBYTE;
}

static int sqlcipher_xxtea_ctx_copy(void *target_ctx, void *source_ctx) {
    ((xxtea_context *) target_ctx)->turns = ((xxtea_context *) source_ctx)->turns;
    return SQLITE_OK;
}

static int sqlcipher_xxtea_ctx_cmp(void *c1, void *c2) {
    return memcmp(c1, c2, sizeof(xxtea_context)) == 0;
}

static int sqlcipher_xxtea_ctx_init(void **ctx) {
    xxtea_context *c = sqlcipher_malloc(sizeof(xxtea_context));
    if (!c) return SQLITE_NOMEM;

    c->turns = 1;
    *ctx = c;
    return SQLITE_OK;
}

static int sqlcipher_xxtea_ctx_free(void **ctx) {
    sqlcipher_free(*ctx, sizeof(xxtea_context));
    return SQLITE_OK;
}

static int sqlcipher_xxtea_fips_status(void *ctx) {
    return 0;
}

static volatile int g_xxtea_registered = 0;
static const sqlcipher_provider g_xxtea_provider = {
    0,                                  /* activate */
    0,                                  /* deactivate */
    sqlcipher_xxtea_get_provider_name,  /* get_provider_name */
    0,                                  /* add_random */
    0,                                  /* random */
    0,                                  /* hmac */
    0,                                  /* kdf */
    sqlcipher_xxtea_cipher,             /* cipher */
    sqlcipher_xxtea_set_cipher,         /* set_cipher */
    sqlcipher_xxtea_get_cipher,         /* get_cipher */
    sqlcipher_xxtea_get_key_sz,         /* get_key_sz */
    sqlcipher_xxtea_get_iv_sz,          /* get_iv_sz */
    sqlcipher_xxtea_get_block_sz,       /* get_block_sz */
    0,                                  /* get_hmac_sz */
    sqlcipher_xxtea_ctx_copy,           /* ctx_copy */
    sqlcipher_xxtea_ctx_cmp,            /* ctx_cmp */
    sqlcipher_xxtea_ctx_init,           /* ctx_init */
    sqlcipher_xxtea_ctx_free,           /* ctx_free */
    sqlcipher_xxtea_fips_status,        /* fips_status */
    sqlcipher_xxtea_get_provider_version
};

#ifndef SQLITE_CORE
#ifdef _WIN32
__declspec(dllexport)
#endif
int sqlite3_xxtea_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi) {
    SQLITE_EXTENSION_INIT2(pApi);

    if (!g_xxtea_registered) {
        g_xxtea_registered = 1;
        return sqlcipher_register_custom_provider("xxtea", &g_xxtea_provider);
    }

    return SQLITE_OK;
}
#else /* SQLITE_CORE */
int sqlcipherCryptoXxteaInit() {
    g_xxtea_registered = 1;
    return sqlcipher_register_custom_provider("xxtea", &g_xxtea_provider);
}
#endif

#endif /* defined(SQLCIPHER_CRYPTO_XXTEA) || !defined(SQLITE_CORE) */
#endif /* SQLITE_HAS_CODEC && SQLCIPHER_CRYPTO_CUSTOM */

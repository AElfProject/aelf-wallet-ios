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

#if defined(SQLITE_HAS_CODEC) && defined(SQLCIPHER_CRYPTO_CUSTOM)

#include "sqliteInt.h"
#include "sqlcipher.h"
#include <assert.h>


/* Structure to store registered custom providers, in a list */
typedef struct sqlcipher_named_provider {
    sqlcipher_provider p;
    char name[0];   /* dynamic length */
} sqlcipher_named_provider;

/* Provider context */
typedef struct custom_ctx {
    sqlcipher_provider *p;  /* Currently selected provider */
    void *p_ctx;            /* Context for selected provider */
} custom_ctx;


/* Custom provider list */
static sqlcipher_named_provider **custom_providers = NULL;
static int custom_providers_count = 0;
static int custom_providers_capacity = 0;
static sqlite3_mutex *custom_providers_mutex;

/* Default fallback provider, should be openssl, libtomcrypt or commoncrypto */
static sqlcipher_provider *fallback_provider;
static int activate_count = 0;

static int sqlcipher_dummy_activate(void *ctx) {
    return SQLITE_OK;
}

static void provider_overload(const sqlcipher_provider *base, sqlcipher_provider *p) {
    if (!p->activate) p->activate = sqlcipher_dummy_activate;
    if (!p->deactivate) p->deactivate = sqlcipher_dummy_activate;

    /* sqlcipher_provider is actually a pile of function pointers, which has the same size of (void *).
       We can just run a loop comparing and assigning raw pointers. */
    int n = sizeof(sqlcipher_provider) / sizeof(void *);
    int i;
    for (i = 2; i < n; i++) {
        if ( ((void **) p)[i] == 0 )
            ((void **) p)[i] = ((void **) base)[i];
    }
}

static int select_provider(custom_ctx *ctx, const char *name) {
    int rc = SQLITE_OK;
    
    sqlite3_mutex_enter(custom_providers_mutex);
    sqlcipher_provider *p = NULL;

    /* Select provider according to name. */
    if (name) {
        int i;
        for (i = 0; i < custom_providers_count; i++) {
            if (strcmp(custom_providers[i]->name, name) == 0) {
                p = &custom_providers[i]->p;
                break;
            }
        }
    }

    /* No provider can match the name, use default provider. */
    if (!p)
        p = fallback_provider;

    /* Cleanup previous context if exists. */
    if (p == ctx->p) goto end;
    if (ctx->p_ctx) {
        ctx->p->ctx_free(&ctx->p_ctx);
        ctx->p_ctx = NULL;
    }

    /* Now we have chosen which provider will be used, 
       we can initialize the real provider context. */
    ctx->p = p;
    rc = ctx->p->ctx_init(&ctx->p_ctx);
    
end:
    sqlite3_mutex_leave(custom_providers_mutex);
    return rc;
}

int sqlcipher_register_custom_provider(const char *name, const sqlcipher_provider *p) {
    sqlite3_mutex_enter(custom_providers_mutex);

    /* Grow custom provider list if it's full. */
    if (custom_providers_count >= custom_providers_capacity) {
        /* Linear growth should be enough here as we probably don't have so much providers. */
        int new_capacity = custom_providers_capacity + 16;
        void *new_list = sqlite3_realloc(custom_providers, new_capacity * sizeof(sqlcipher_named_provider *));
        if (!new_list) goto bail;

        custom_providers = (sqlcipher_named_provider **) new_list;
        custom_providers_capacity = new_capacity;
    }
    
    size_t len = strlen(name) + 1;
    sqlcipher_named_provider *np = sqlite3_malloc(sizeof(sqlcipher_named_provider) + len * sizeof(char));
    if (!np) goto bail;

    /* Overload provider functions. */
    strncpy(np->name, name, len);
    memcpy(&np->p, p, sizeof(sqlcipher_provider));
    provider_overload(fallback_provider, &np->p);

    /* Find existing provider. */
    int i;
    for (i = 0; i < custom_providers_count; i++) {
        if (strcmp(custom_providers[i]->name, name) == 0)
            break;
    }
    if (i < custom_providers_count) {
        /* Free previous provider and replace with new one. */
        sqlite3_free(custom_providers[i]);
    } else {
        /* Not found, enlarge the list. */
        custom_providers_count++;
    }
    custom_providers[i] = np;

    sqlite3_mutex_leave(custom_providers_mutex);
    return SQLITE_OK;

bail:
    sqlite3_mutex_leave(custom_providers_mutex);
    return SQLITE_NOMEM;
}

int sqlcipher_unregister_custom_provider(const char *name) {
    sqlite3_mutex_enter(custom_providers_mutex);

    /* Find existing provider. */
    int i;
    for (i = 0; i < custom_providers_count; i++) {
        if (strcmp(custom_providers[i]->name, name) == 0)
            break;
    }
    if (i < custom_providers_count) {
        /* Found, free the provider and swap it to the end of the list. */
        sqlite3_free(custom_providers[i]);
        custom_providers_count--;
        custom_providers[i] = custom_providers[custom_providers_count];
    }

    sqlite3_mutex_leave(custom_providers_mutex);
    return SQLITE_OK;
}

const sqlcipher_provider *sqlcipher_get_fallback_provider() {
    return fallback_provider;
}

static int sqlcipher_custom_activate(void *ctx) {
    sqlite3_mutex *mutex = sqlite3_mutex_alloc(SQLITE_MUTEX_STATIC_MASTER);
    sqlite3_mutex_enter(mutex);

    if (!fallback_provider) {
        fallback_provider = (sqlcipher_provider *) 
                sqlite3_malloc(sizeof(sqlcipher_provider));
        if (!fallback_provider) goto bail;

#if defined (SQLCIPHER_CRYPTO_CC)
        extern int sqlcipher_cc_setup(sqlcipher_provider *p);
        sqlcipher_cc_setup(fallback_provider);
#elif defined (SQLCIPHER_CRYPTO_LIBTOMCRYPT)
        extern int sqlcipher_ltc_setup(sqlcipher_provider *p);
        sqlcipher_ltc_setup(fallback_provider);
#elif defined (SQLCIPHER_CRYPTO_OPENSSL)
        extern int sqlcipher_openssl_setup(sqlcipher_provider *p);
        sqlcipher_openssl_setup(fallback_provider);
#else
#error "NO DEFAULT SQLCIPHER CRYPTO PROVIDER DEFINED"
#endif

        custom_providers_mutex = sqlite3_mutex_alloc(SQLITE_MUTEX_FAST);

        /* initialize static-linked crypto modules. */
        int rc = SQLITE_OK;
#ifdef SQLCIPHER_CRYPTO_XXTEA
        if (rc == SQLITE_OK) {
            extern int sqlcipherCryptoXxteaInit();
            rc = sqlcipherCryptoXxteaInit();
        }
#endif
#ifdef SQLCIPHER_CRYPTO_DEVLOCK
        if (rc == SQLITE_OK) {
            extern int sqlcipherCryptoDevlockInit();
            rc = sqlcipherCryptoDevlockInit();
        }
#endif
        (void) rc;
    }

    activate_count++;
    sqlite3_mutex_leave(mutex);
    return SQLITE_OK;

bail:
    sqlite3_mutex_leave(mutex);
    return SQLITE_NOMEM;
}

static int sqlcipher_custom_deactivate(void *ctx) {
    sqlite3_mutex *mutex = sqlite3_mutex_alloc(SQLITE_MUTEX_STATIC_MASTER);
    sqlite3_mutex_enter(mutex);

    if (--activate_count == 0) {
        sqlite3_free(fallback_provider);
        fallback_provider = NULL;
        
        sqlite3_free(custom_providers);
        custom_providers = NULL;
        custom_providers_count = 0;
        custom_providers_capacity = 0;

        sqlite3_mutex_free(custom_providers_mutex);
    }

    sqlite3_mutex_leave(mutex);
    return SQLITE_OK;
}

static int sqlcipher_custom_ctx_init(void **ctx) {
    custom_ctx *c;
    c = sqlite3_malloc(sizeof(custom_ctx));
    *ctx = c;
    if (!c) return SQLITE_NOMEM;

    sqlcipher_custom_activate(c);
    c->p = fallback_provider;
    c->p_ctx = NULL;
    return c->p->ctx_init(&c->p_ctx);
}

static int sqlcipher_custom_ctx_free(void **ctx) {
    int rc;
    custom_ctx *c = (custom_ctx *) *ctx;
    if (c->p_ctx && (rc = c->p->ctx_free(&c->p_ctx)) != SQLITE_OK)
        return rc;
    
    sqlcipher_custom_deactivate(*ctx);
    sqlite3_free(*ctx);
    return SQLITE_OK;
}

static int sqlcipher_custom_ctx_copy(void *target_ctx, void *source_ctx) {
    custom_ctx *src = (custom_ctx *) source_ctx;
    custom_ctx *dst = (custom_ctx *) target_ctx;
    
    dst->p = src->p;
    return dst->p->ctx_copy(dst->p_ctx, src->p_ctx);
}

static int sqlcipher_custom_ctx_cmp(void *c1, void *c2) {
    custom_ctx *ctx1 = (custom_ctx *) c1;
    custom_ctx *ctx2 = (custom_ctx *) c2;
    if (ctx1->p != ctx2->p) return 0;
    if (ctx1->p_ctx && ctx2->p_ctx)
        return ctx1->p->ctx_cmp(ctx1->p_ctx, ctx2->p_ctx);
    if (!ctx1->p_ctx && !ctx2->p_ctx)
        return 1;
    return 0;
}

static const char* sqlcipher_custom_get_provider_name(void *ctx) {
    return "custom";
}

static const char* sqlcipher_custom_get_provider_version(void *ctx) {
    return "0.2.2";
}

static int sqlcipher_custom_set_cipher(void *ctx, const char *cipher_name) {
    custom_ctx *c = (custom_ctx *) ctx;
    int rc;
    /* Initialize provider accroding to cipher_name. */
    if ((rc = select_provider(c, cipher_name)) != SQLITE_OK) 
        return rc;
    return c->p->set_cipher(c->p_ctx, cipher_name);
}

static const char* sqlcipher_custom_get_cipher(void *ctx) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->get_cipher(c->p_ctx);
}

static int sqlcipher_custom_random(void *ctx, void *buffer, int length) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->random(c->p_ctx, buffer, length);
}

static int sqlcipher_custom_add_random(void *ctx, void *buffer, int length) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->add_random(c->p_ctx, buffer, length);
}

static int sqlcipher_custom_hmac(void *ctx, unsigned char *hmac_key, int key_sz, 
        unsigned char *in, int in_sz, unsigned char *in2, int in2_sz, unsigned char *out) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->hmac(c->p_ctx, hmac_key, key_sz, in, in_sz, in2, in2_sz, out);
}

static int sqlcipher_custom_kdf(void *ctx, const unsigned char *pass, int pass_sz, 
        unsigned char* salt, int salt_sz, int workfactor, int key_sz, unsigned char *key) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->kdf(c->p_ctx, pass, pass_sz, salt, salt_sz, workfactor, key_sz, key);
}

static int sqlcipher_custom_cipher(void *ctx, int mode, unsigned char *key, int key_sz, 
        unsigned char *iv, unsigned char *in, int in_sz, unsigned char *out) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->cipher(c->p_ctx, mode, key, key_sz, iv, in, in_sz, out);
}

static int sqlcipher_custom_get_key_sz(void *ctx) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->get_key_sz(c->p_ctx);
}

static int sqlcipher_custom_get_iv_sz(void *ctx) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->get_iv_sz(c->p_ctx);
}

static int sqlcipher_custom_get_block_sz(void *ctx) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->get_block_sz(c->p_ctx);
}

static int sqlcipher_custom_get_hmac_sz(void *ctx) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->get_hmac_sz(c->p_ctx);
}

static int sqlcipher_custom_fips_status(void *ctx) {
    custom_ctx *c = (custom_ctx *) ctx;
    assert(c->p && c->p_ctx);
    return c->p->fips_status(c->p_ctx);
}


int sqlcipher_custom_setup(sqlcipher_provider *p) {
    p->activate = sqlcipher_custom_activate;  
    p->deactivate = sqlcipher_custom_deactivate;
    p->get_provider_name = sqlcipher_custom_get_provider_name;
    p->random = sqlcipher_custom_random;
    p->hmac = sqlcipher_custom_hmac;
    p->kdf = sqlcipher_custom_kdf;
    p->cipher = sqlcipher_custom_cipher;
    p->set_cipher = sqlcipher_custom_set_cipher;
    p->get_cipher = sqlcipher_custom_get_cipher;
    p->get_key_sz = sqlcipher_custom_get_key_sz;
    p->get_iv_sz = sqlcipher_custom_get_iv_sz;
    p->get_block_sz = sqlcipher_custom_get_block_sz;
    p->get_hmac_sz = sqlcipher_custom_get_hmac_sz;
    p->ctx_copy = sqlcipher_custom_ctx_copy;
    p->ctx_cmp = sqlcipher_custom_ctx_cmp;
    p->ctx_init = sqlcipher_custom_ctx_init;
    p->ctx_free = sqlcipher_custom_ctx_free;
    p->add_random = sqlcipher_custom_add_random;
    p->fips_status = sqlcipher_custom_fips_status;
    p->get_provider_version = sqlcipher_custom_get_provider_version;
    return SQLITE_OK;
}

#endif /* SQLITE_HAS_CODEC && SQLCIPHER_CRYPTO_CUSTOM */

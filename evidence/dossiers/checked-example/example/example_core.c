/*
 * example_core.c -- the core of example.c, shrunk for proving.
 *
 * Same bug as example.c (paper Section 5): a heap object
 *     struct S { char buf[20]; unsigned char op; };
 * is filled through a char * with an off-by-one bound, so input byte 21 lands
 * in op, and handlers[op]() then calls whichever function the input chose --
 * h_admin for 0xff.  The table is in bounds for every op, ASan sees one
 * 21-byte block, and UBSan sees only a char *.
 *
 * What is gone: all output, and every write outside the harness's own heap
 * object.  The handlers are empty (h_admin stays a distinct function; which
 * one runs is seen in an execution trace).  So the harness writes nothing,
 * keeps all static data unchanged, and returns 0: it fits the harness contract
 * of pupnp's FuzzHttp proof (fuzz_one_stmt / fuzz_one_stmtA, which keep every
 * static byte but errno), and the process's visible behaviour is only what
 * OSS Verify's driver prints ("0" per call), as for pupnp.
 *
 * -DFILL_LAST=<n> as in example.c: NAME_LEN - 1 is the correct program,
 * NAME_LEN the bug (default), NAME_LEN + 1 an overflow past the malloc block.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

#define NAME_LEN 20

#ifndef FILL_LAST
#define FILL_LAST NAME_LEN /* BUG: the last valid index of buf is NAME_LEN - 1 */
#endif

typedef void (*handler)(void);

static void h_nop(void) {}
static void h_admin(void) {} /* stands for any privileged operation */

/* One entry per byte value: h_nop, except handlers[0xff], which is h_admin. */
#define N h_nop
#define N16 N, N, N, N, N, N, N, N, N, N, N, N, N, N, N, N
static const handler handlers[256] = {
    N16, N16, N16, N16, N16, N16, N16, N16, N16, N16, N16, N16, N16, N16, N16,
    N, N, N, N, N, N, N, N, N, N, N, N, N, N, N, h_admin,
};
#undef N16
#undef N

struct S {
  char buf[NAME_LEN];
  unsigned char op;
};

static void fill(char *dst, const uint8_t *in, size_t n) {
  for (size_t i = 0; i < n && i <= FILL_LAST; i++)
    dst[i] = (char)in[i];
}

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
  struct S *x = malloc(sizeof *x);
  if (x == NULL)
    return 0;
  x->op = 0;
  fill(x->buf, data, size); /* may write past buf, into op */
  handlers[x->op]();        /* in bounds for every op */
  free(x);
  return 0;
}

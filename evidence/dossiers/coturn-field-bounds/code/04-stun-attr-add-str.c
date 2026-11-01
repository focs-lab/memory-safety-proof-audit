/*
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * https://opensource.org/license/bsd-3-clause
 *
 * Copyright (C) 2011, 2012, 2013 Citrix Systems
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the project nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/* Verbatim research excerpt: src/client/ns_turn_msg.c:1666-1703; commit 70ca74e0bd8300e22a179e9a7beead862763ca5c. */
bool stun_attr_add_str(uint8_t *buf, size_t *len, uint16_t attr, const uint8_t *avalue, int alen) {
  if (alen < 0) {
    alen = 0;
  }
  uint8_t tmp[1];
  if (!avalue) {
    alen = 0;
    avalue = tmp;
  }
  const int clen = stun_get_command_message_len_str(buf, *len);
  int newlen = clen + 4 + alen;
  const int newlenrem4 = newlen & 0x00000003;
  int paddinglen = 0;
  if (newlenrem4) {
    paddinglen = 4 - newlenrem4;
    newlen = newlen + paddinglen;
  }

  if (newlen >= MAX_STUN_MESSAGE_SIZE) {
    return false;
  }

  uint8_t *attr_start = buf + clen;

  stun_set_command_message_len_str(buf, newlen);
  *len = newlen;

  turn_write_u16(attr_start, attr);
  turn_write_u16(attr_start + 2, (uint16_t)alen);
  if (alen > 0) {
    memcpy(attr_start + 4, avalue, alen);
  }

  // Write 0 padding to not leak data
  memset(attr_start + 4 + alen, 0, paddinglen);

  return true;
}

/* Paper illustration, not a standalone program. Macros expanded and omissions marked.
 * Derived from coturn 70ca74e0bd8300e22a179e9a7beead862763ca5c; exact excerpts and original licence headers are in code/01-05 and upstream/. */
typedef struct _stun_buffer {
  uint8_t channel[4];
  uint8_t buf[65507];
  /* len, offset, coffset omitted */
} stun_buffer;

/* Inside stun_attr_add_str(uint8_t *buf, ...): */
const int clen =
    stun_get_command_message_len_str(buf, *len);
/* newlen calculation and padding omitted */
if (newlen >= MAX_STUN_MESSAGE_SIZE)
  return false;
uint8_t *attr_start = buf + clen;
/* update message length */
turn_write_u16(attr_start, attr);

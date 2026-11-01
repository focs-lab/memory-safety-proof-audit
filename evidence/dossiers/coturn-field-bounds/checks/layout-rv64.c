typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned long size_t;
#define STUN_CHANNEL_HEADER_LENGTH 4
#define STUN_BUFFER_SIZE 65507
typedef struct _stun_buffer {
  uint8_t channel[STUN_CHANNEL_HEADER_LENGTH];
  uint8_t buf[STUN_BUFFER_SIZE];
  size_t len;
  uint16_t offset;
  uint8_t coffset;
} stun_buffer;

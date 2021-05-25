; z8k_hostcomm.inc


hc_nop                  equ     0
hc_reset                equ     1
hc_epu_trap             equ     2
hc_priv_trap            equ     3
hc_seg_trap             equ     4
hc_vi_trap              equ     5
hc_nvi_trap             equ     6
hc_exit                 equ     7
hc_breakpoint           equ     8
hc_sysstack_overrun     equ     9
hc_sysstack_underrun    equ     10
hc_termin               equ     11
hc_terminnowait         equ     12
hc_termout              equ     13
hc_termoutnowait        equ     14
hc_termreadline         equ     15
hc_terminstat           equ     16
hc_termoutstat          equ     17

hc_maxpayload           equ     256

hc_msg_nop              equ     0
hc_msg_cont             equ     1
hc_msg_breakpoint       equ     2

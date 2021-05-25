; z8k_fcw.inc

fcw_segmented   equ     1000000000000000b       ; segmented mode
fcw_system      equ     0100000000000000b       ; system mode
fcw_epa         equ     0010000000000000b       ; epu connected
fcw_vie         equ     0001000000000000b       ; vectored interrupt enable
fcw_nvie        equ     0000100000000000b       ; non vectored interrupt enable
fcw_c           equ     0000000010000000b       ; carry flag
fcw_z           equ     0000000001000000b       ; zero flag
fcw_s           equ     0000000000100000b       ; sign flag
fcw_pv          equ     0000000000010000b       ; parity/overflow flag
fcw_da          equ     0000000000001000b       ; decimal adjust
fcw_h           equ     0000000000000100b       ; half carry

        cpu     z8001
        supmode on
        include bitfuncs.inc
        include z8k_fcw.inc
        include z8k_hostcomm.inc
        include z8k_errno.inc
        include z8k_sc.inc


SP      reg     rr14
SPSEG   reg     r14
SPOFF   reg     r15


        org     0

;******************************************
; RESET-Vektor                            *
;******************************************

reset_trap:
                dw      0
reset_fcw       dw      fcw_segmented+fcw_system
reset_pc        dd      reset_handler


;******************************************
; FCW/PC nach TRAP                        *
;******************************************

trap_exit:
                dw      0
trap_fcw        dw      fcw_segmented+fcw_system
trap_pc         dd      reset_handler


;******************************************
; Register nach TRAP                      *
;******************************************

reg_save_area:
save_r0         dw      0
save_r1         dw      0
save_r2         dw      0
save_r3         dw      0
save_r4         dw      0
save_r5         dw      0
save_r6         dw      0
save_r7         dw      0
save_r8         dw      0
save_r9         dw      0
save_r10        dw      0
save_r11        dw      0
save_r12        dw      0
save_r13        dw      0
save_r14        dw      0
save_r15        dw      0
save_nspseg     dw      0
save_nspoff     dw      0


;******************************************
; TRAP-Info/-Steuerung                    *
;******************************************

trap_reason     dw      0
trap_code       dw      0
rc_halted       dw      0
rc_cont         dw      0

last_sc_code    dw      0
exit_code       dw      0

pc_hist1        dw      0
pc_hist2        dw      0
pc_hist3        dw      0
pc_hist4        dw      0
pc_hist5        dw      0
pc_hist6        dw      0
pc_hist7        dw      0
pc_hist8        dw      0

pc_ihist1       dw      0
pc_ihist2       dw      0
pc_ihist3       dw      0
pc_ihist4       dw      0
pc_ihist5       dw      0
pc_ihist6       dw      0
pc_ihist7       dw      0
pc_ihist8       dw      0

nmi_count       dw      0
deferred_break  dw      0


;******************************************
; Kommunikation mit Atmega                *
;******************************************

        org     100h-8

hostcomm_area:
host_sema       dw      0
host_message    dw      0       ; von Host via NMI
host_command    dw      0       ; zu Host via MO
host_size       dw      0
host_payload:   db      hc_maxpayload dup (0)


;******************************************
; PSA                                     *
;******************************************

        org     200h

psa:
        dw      0
        dw      0
        dd      0

epu_trap:
        dw      0
        dw      fcw_segmented+fcw_system
        dd      epu_handler

priv_trap:
        dw      0
        dw      fcw_segmented+fcw_system
        dd      priv_handler

sc_trap:
        dw      0
        dw      fcw_segmented+fcw_system
        dd      sc_handler

seg_trap:
        dw      0
        dw      fcw_segmented+fcw_system
        dd      seg_handler

nmi_trap:
        dw      0
        dw      fcw_segmented+fcw_system
        dd      nmi_handler

nvi_trap:
        dw      0
        dw      fcw_segmented+fcw_system
        dd      nvi_handler

vi_trap:
        dw      0
        dw      fcw_segmented+fcw_system
  rept 128
        dd      vi_handler
  endm


;******************************************
; Identifikation                          *
;******************************************

        org     500h

        db      'zb'
zbios_date:
        dw      2021h, 0520h    ; 2021-05-20


;******************************************
; Debug-Info                              *
;******************************************

debug:
        push    @SP, r0
        ld      r0, SP(#4)
        ex      |pc_hist1|, r0
        ex      |pc_hist2|, r0
        ex      |pc_hist3|, r0
        ex      |pc_hist4|, r0
        ex      |pc_hist5|, r0
        ex      |pc_hist6|, r0
        ex      |pc_hist7|, r0
        ld      |pc_hist8|, r0
        pop     r0, @SP
        ret


idebug:
        push    @SP, r0
        ld      r0, SP(#4)
        ex      |pc_ihist1|, r0
        ex      |pc_ihist2|, r0
        ex      |pc_ihist3|, r0
        ex      |pc_ihist4|, r0
        ex      |pc_ihist5|, r0
        ex      |pc_ihist6|, r0
        ex      |pc_ihist7|, r0
        ld      |pc_ihist8|, r0
        pop     r0, @SP
        ret


;******************************************
; HALT                                    *
;******************************************

halt_cpu:
        calr    debug
        halt
        ret


;******************************************
; grundlegende Kommunikation mit Atmega   *
;******************************************

host_lock:
        calr    debug

.host_lock:
        tset    |host_sema|
        ret     pl

        calr    halt_cpu
        jr      host_lock


host_unlock:
        clr     |host_sema|
        ret


host_transact:
        calr    debug

.still_active:
        mbit
        jr      pl, .still_active

        mset

.not_yet_active:
        mbit
        jr      mi, .not_yet_active

        mres
        calr    debug
        ret


;******************************************
; RESET                                   *
;******************************************

reset_handler:
        lda     rr0, psa
        ldctl   psapseg, r0
        ldctl   psapoff, r1
        lda     SP, sysstack_top
        calr    debug
        clr     r0
        ldctl   refresh, r0
        ld      |host_sema|, r0
        ld      |host_message|, r0
        ld      |host_command|, r0
        ld      |host_size|, r0
        ld      |nmi_count|, r0
        ld      |rc_halted|, r0
        ld      |rc_cont|, r0
        mres
        ld      rr0,|reset_pc|
        push    @SP, rr0
        ld      r0,|reset_fcw|
        push    @SP, r0
        ld      r0, #0DEADh
        push    @SP, r0
        ld      r1, #0C0DEh
        ld      r2, r0
        ld      r3, r1
        ld      r4, r0
        ld      r5, r1
        ld      r6, r0
        ld      r7, r1
        ld      r8, r0
        ld      r9, r1
        ld      r10, r0
        ld      r11, r1
        ld      r12, r0
        ld      r13, r1

        ld      |trap_code|, #hc_reset


;******************************************
; TRAP-Handler                            *
;******************************************

trap_handler:
        calr    debug
        ldm     |reg_save_area|, r0, #15
        ldctl   r0, nspseg
        ld      |save_nspseg|, r0
        ldctl   r0, nspoff
        ld      |save_nspoff|, r0
        ld      r0, @SP
        ld      |trap_reason|, r0
        ld      |trap_exit+0|, #0
        ld      r0, SP(#2)              ; FCW
        ld      |trap_fcw|, r0
        ld      rr0, SP(#4)             ; PC
        ld      |trap_pc|, rr0
        add     SPOFF, #8
        ld      |save_r15|, SPOFF

        calr    host_lock
        ld      r0, |trap_code|
        ld      |host_command|, r0
        clr     |host_size|
        calr    host_transact
        calr    host_unlock
        calr    debug

        inc     |rc_halted|

.halt:
        calr    halt_cpu
        ld      r0, |rc_halted|
        cp      r0, |rc_cont|
        jr      nz, .halt

        calr    debug
        ldm     r0, |reg_save_area|, #16
        ldps    |trap_exit|


;******************************************
; TRAPs                                   *
;******************************************

epu_handler:
        ld      |trap_code|, #hc_epu_trap
        jr      trap_handler

priv_handler:
        ld      |trap_code|, #hc_priv_trap
        jr      trap_handler

seg_handler:
        ld      |trap_code|, #hc_seg_trap
        jr      trap_handler


;******************************************
; Interrupts                              *
;******************************************

nvi_handler:
        ld      |trap_code|, #hc_nvi_trap
        jr      trap_handler

vi_handler:
        ld      |trap_code|, #hc_vi_trap
        jr      trap_handler


;******************************************
; NMI                                     *
;******************************************

nmi_handler:
        calr    idebug
        inc     |nmi_count|, #1
        cp      sysstack_bottom, #1234h
        jr      nz, .stack_overrun

        cp      sysstack_top, #4321h
        jr      nz, .stack_underrun

        push    @SP, r0

        ld      r0, #hc_msg_nop
        ex      r0, |host_message|
        cp      r0, #hc_msg_breakpoint
        jr      nz, .not_breakpoint

        ld      r0, SP(#4)
        and     r0, #fcw_system
        jr      nz, .system_mode

.user_mode:
        ld      |trap_code|, #hc_breakpoint
        calr    idebug
        pop     r0, @SP
        jp      trap_handler

.system_mode:
        inc     |deferred_break|
        calr    idebug
        jr      .iret

.not_breakpoint:
        cp      r0, #hc_msg_cont
        jr      nz, .iret

        calr    idebug
        ld      r0, |rc_halted|
        ld      |rc_cont|, r0

.iret:
        calr    idebug
        pop     r0, @SP
        iret

.stack_overrun:
        calr    idebug
        ld      |trap_code|, #hc_sysstack_overrun
        jp      trap_handler

.stack_underrun:
        calr    idebug
        ld      |trap_code|, #hc_sysstack_underrun
        jp      trap_handler


;******************************************
; Definitionen Systemaufrufe              *
;******************************************

BP      reg     rr12

RES     reg     r0
N       reg     r1

PTRSEG  reg     r2
PTROFF  reg     r3
PTR     reg     rr2

TEMPSEG reg     r6
TEMPOFF reg     r7
TEMPPTR reg     rr6

SC_STACKPARA    equ     4               ; @BP
SC_IDENT        equ     SC_STACKPARA+0
SC_FCW          equ     SC_STACKPARA+2
SC_PCSEG        equ     SC_STACKPARA+4
SC_PCOFF        equ     SC_STACKPARA+6


;******************************************
; Systemaufrufe                           *
;******************************************

; **** EXIT ****
sc_exit:
; -->   N:  Exitkode
        ld      |trap_code|, #hc_exit
        ld      |exit_code|, N
        jr      sc_break_or_exit


; **** BREAKPOINT ****
sc_breakpoint:
        ld      |trap_code|, #hc_breakpoint

sc_break_or_exit:
        ld      TEMPOFF, BP(#SC_PCOFF)  ; Offset PC
        dec     TEMPOFF, #2             ; Länge SC-Instruktion
        ld      BP(#SC_PCOFF), TEMPOFF  ; korrigierte Rücksprungadresse
        add     SPOFF, #4               ; Rücksprungadresse entfernen
        pop     TEMPPTR, @SP
        pop     BP, @SP
        jp      trap_handler


; **** Fehler ****

error_einval:
        ld      RES, #EINVAL
        ret

error_eio:
        ld      RES, #EIO
        ret


; **** TERMINNOWAIT ****
sc_terminnowait:
        ld      TEMPOFF, #hc_terminnowait
        jr      sc_termin_


; **** TERMIN ****
sc_termin:
        ld      TEMPOFF, #hc_terminnowait

sc_termin_:
; -->   N:      Anzahl Zeichen
; -->   PTR:    Pufferadresse
; <--   RES:    Anzahl Zeichen oder Fehlerkode
        calr    debug
        cp      N, #hc_maxpayload
        jr      ugt, error_einval

        calr    host_lock
        ld      |host_command|, TEMPOFF
        ld      |host_size|, N
        calr    host_transact
        calr    sc_copyout
        ld      RES, |host_size|
        calr    host_unlock
        cp      RES, N
        jr      ugt, error_eio

        calr    debug
        ret


; **** TERMOUTNOWAIT ****
sc_termoutnowait:
        ld      TEMPOFF, #hc_termoutnowait
        jr      sc_termout_


; **** TERMOUT ****
sc_termout:
        ld      TEMPOFF, #hc_termout

sc_termout_:
; -->   N:      Anzahl Zeichen
; -->   PTR:    Pufferadresse
; <--   RES:    Anzahl Zeichen oder Fehlerkode
        calr    debug
        cp      N, #hc_maxpayload
        jr      ugt, error_einval

        calr    host_lock
        ld      |host_command|, TEMPOFF
        ld      |host_size|, N
        calr    sc_copyin
        calr    host_transact
        ld      RES, |host_size|
        calr    host_unlock
        cp      RES, N
        jr      ugt, error_eio

        calr    debug
        ret


; **** TERMREADLINE ****
sc_termreadline:
; -->   N:      Anzahl Zeichen maximal
; -->   PTR:    Pufferadresse
; <--   RES:    Anzahl Zeichen oder Fehlerkode
        calr    debug
        cp      N, #hc_maxpayload
        jr      ugt, error_einval

        calr    host_lock
        ld      |host_command|, #hc_termreadline
        ld      |host_size|, N
        calr    host_transact
        calr    sc_copyout
        ld      RES, |host_size|
        calr    host_unlock
        cp      RES, N
        jr      ugt, error_eio

        calr    debug
        ret


; **** TERMINSTAT ****
sc_terminstat:
; <--   RES:    Anzahl verfügbare Zeichen
        calr    debug
        calr    host_lock
        ld      |host_command|, #hc_terminstat
        calr    host_transact
        ld      RES, |host_size|
        calr    host_unlock
        calr    debug
        ret


; **** TERMOUTSTAT ****
sc_termoutstat:
; <--   RES:    freie Zeichen
        calr    debug
        calr    host_lock
        ld      |host_command|, #hc_termoutstat
        calr    host_transact
        ld      RES, |host_size|
        calr    host_unlock
        calr    debug
        ret


;******************************************
; Hilfsfunktionen Systemaufrufe           *
;******************************************

sc_copyin:
        calr    debug
        test    N
        ret     z

        ld      TEMPOFF, BP(#SC_FCW)    ; FCW
        and     TEMPOFF, #fcw_segmented ; segmentiert?
        jr      nz, .copyin

        ld      PTRSEG, BP(#SC_PCSEG)   ; Segment PC

.copyin:
        lda     TEMPPTR, host_payload
        ld      RES, N
        ldirb   @TEMPPTR, @PTR, RES
        ret


sc_copyout:
        calr    debug
        ld      RES, |host_size|
        test    RES
        ret     z

        cp      N, RES
        jr      uge, .ok

        ld      RES, N

.ok:
        ld      TEMPOFF, BP(#SC_FCW)    ; FCW
        and     TEMPOFF, #fcw_segmented ; segmentiert?
        jr      nz, .copyout

        ld      PTRSEG, BP(#SC_PCSEG)   ; Segment PC

.copyout:
        lda     TEMPPTR, host_payload
        ldirb   @PTR, @TEMPPTR, RES
        ret


;******************************************
; SC                                      *
;******************************************

sc_handler:
        calr    debug
        push    @SP, BP
        ld      BP, SP
        push    @SP, TEMPPTR
        clr     TEMPSEG                 ; immer 0
        ld      TEMPOFF, BP(#SC_IDENT)  ; Funktionskode
        and     TEMPOFF, #0FFh          ; 0..255
        ld      |last_sc_code|, TEMPOFF
        cp      TEMPOFF, #sc_jumptable_entries
        jr      uge, .nop               ; undefinierter Funktionskode

        sll     TEMPOFF, #1             ; Worte
        ld      TEMPOFF, sc_jumptable(TEMPOFF)

        call    @TEMPPTR

        clr     TEMPOFF
        ex      TEMPOFF, |deferred_break|
        test    TEMPOFF
        jr      z, .done

        pop     TEMPPTR, @SP
        pop     BP, @SP
        ld      |trap_code|, #hc_breakpoint
        jp      trap_handler

.done:
        pop     TEMPPTR, @SP
        pop     BP, @SP
        iret

.nop:
        calr    debug
        ld      RES, #ENOSYS
        jr      .done


;******************************************
; Verteiler                               *
;******************************************

        align   2

sc_jumptable:
        dw      sc_exit
sc_jumptable1:
        dw      sc_breakpoint
        dw      sc_termin
        dw      sc_terminnowait
        dw      sc_termout
        dw      sc_termoutnowait
        dw      sc_termreadline
        dw      sc_terminstat
        dw      sc_termoutstat
sc_jumptable_entries    equ     ($-sc_jumptable)/(sc_jumptable1-sc_jumptable)


;******************************************
; System-Stack                            *
;******************************************

sysstack_bottom dw      1234h


        org     0ffeh

sysstack_top    dw      4321h


        end

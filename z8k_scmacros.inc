; z8k_scmacros.inc


  if MOMCPUNAME = "Z8002"
syscall         macro           SYSC, PTR, N
  ifnb PTR
        lda     r3, PTR
  endif
  ifnb N
        ld      r1, N
  endif
        sc      #SYS_SYSC
        endm
  endif
  if MOMCPUNAME = "Z8001"
syscall         macro           SYSC, PTR, N
  ifnb PTR
        lda     rr2, PTR
  endif
  ifnb N
        ld      r1, N
  endif
        sc      #SYS_SYSC
        endm
  endif


syscall_EXIT            macro   N
        syscall EXIT,, N
        endm


syscall_BREAKPOINT      macro
        syscall BREAKPOINT
        endm


syscall_TERMIN          macro        PTR, N, NW
  ifb NW
        syscall TERMIN, PTR, N
  endif
  ifnb NW
        syscall TERMINNOWAIT, PTR, N
  endif
        endm


syscall_TERMOUT         macro        PTR, N, NW
  ifb NW
        syscall TERMOUT, PTR, N
  endif
  ifnb NW
        syscall TERMOUTNOWAIT, PTR, N
  endif
        endm


syscall_TERMREADLINE    macro        PTR, N
        syscall TERMREADLINE, PTR, N
        endm


syscall_TERMINSTAT      macro
        syscall TERMINSTAT
        endm


syscall_TERMOUTSTAT     macro
        syscall TERMOUTSTAT
        endm




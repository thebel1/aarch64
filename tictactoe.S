            .global main

/***********************************************************************/

            .extern strcmp
            .extern puts
            .extern printf
            .extern scanf
            .extern sscanf
            .extern exit
            
/***********************************************************************/

            .data

gameBoard:
            .quad   0

            /*
             * Command prompt strings
             */
clrStr:
            .asciz  "\033c"
prompt:
            .asciz  "> "
lastCmdFmt:
            .asciz  "%s\n"

            /*
             * ASCII graphics
             */
ruler:
            .asciz  "+---+---+---+\n"
fields:
            .asciz  "| %s | %s | %s |\n"
field_:
            .asciz  " "
fieldX:
            .asciz  "X"
fieldO:
            .asciz  "O"
fieldNums:
            .asciz  "0\0001\0002\0003\0004\0005\0006\0007\0008\000"

            /*
             * Command formats
             */
cmdHelpLong:
            .asciz  "help"
cmdHelpShort:
            .asciz  "h"
cmdQuitLong:
            .asciz  "quit"
cmdQuitShort:
            .asciz  "q"
cmdReset:
            .asciz  "reset"
cmdExit:
            .asciz  "exit"
cmdXLower:
            .asciz  "x%d"
cmdXUpper:
            .asciz  "X%d"
cmdOLower:
            .asciz  "o%d"
cmdOUpper:
            .asciz  "O%d"

            /*
             * Other command-related strings
             */
lastCmd:
            .asciz  "\0                              "  // 32 char command max.
lastErr:
            .quad   0

            /*
             * Error strings
             */
errInvalidCmd:
            .asciz  "Invalid command"
errOutOfRangeCmd:
            .asciz  "Invalid field. Must be 0-8."
errAlreadySetField:
            .asciz  "Already set this field."

            /*
             * Misc. strings
             */
cmdFmt:
            .asciz  "%32s"
newline:
            .asciz  "\n"
welcomeMsg:
            .asciz  "For a list of commands, type `help`"
goodBye:
            .asciz  "Goodbye!"
helpMsg:
            .asciz  "Command syntax: [letter][field]\nE.g. `x4` or `o3`.\nAdditional commands: reset, quit."
gameWonMsg:
            .asciz  "Game won!"

            .text

/*
 **********************************************************************
 *  int main();
 *
 *      Main entry point.
 **********************************************************************
 */
            .type   main, %function
main:
            sub     sp, sp, 16
            str     x30, [sp, 8]
            bl      tictactoe
            mov     w0, 0
            ldr     x30, [sp, 8]
            add     sp, sp, 16
            ret

/*
 **********************************************************************
 *  void tictactoe();
 *
 *      Implementation of the game loop.
 **********************************************************************
 */
            .type   tictactoe, %function
tictactoe:
            sub     sp, sp, 16
            str     x30, [sp]
            //movz    w0, 0b1001100110011001
            //movk    w0, 0b01, lsl 16
            mov     w0, 0
            ldr     x9, =gameBoard
            str     x0, [x9]

            /*
             * The game loop
             */
tictactoe_loop:
            ldr     x0, =gameBoard
            ldr     w0, [x0]
            bl      clearScreen
            bl      printBoard
            ldr     x9, =lastCmd
            ldr     x9, [x9]
            and     x9, x9, 0b11111111
            cmp     x9, 0
            b.eq    tictactoe_firstCmd
            b.ne    tictactoe_lastCmd
tictactoe_loop_reentry:
            ldr     x0, =prompt
            bl      printf
            ldr     x0, =cmdFmt
            ldr     x1, =lastCmd
            bl      scanf
            ldr     x0, =lastCmd
            bl      processCmd
            ldr     x0, =gameBoard
            ldr     w0, [x0]
            bl      checkWin
            cmp     x0, 0
            b.eq    tictactoe_loop
            bl      printBoard
            ldr     x0, =gameWonMsg
            bl      puts
            ldr     x30, [sp]
            add     sp, sp, 16
            ret

            /*
             * Print prompt for when game is started
             */
tictactoe_firstCmd:
            ldr     x0, =newline
            bl      printf
            ldr     x0, =welcomeMsg
            bl      puts
            b       tictactoe_loop_reentry

            /*
             * Print prompt for subsequent commands
             */
tictactoe_lastCmd:
            ldr     x0, =newline
            bl      printf
            ldr     x0, =welcomeMsg
            bl      puts
            ldr     x0, =lastCmdFmt
            ldr     x1, =lastCmd
            bl      printf
            ldr     x0, =lastErr
            ldr     x0, [x0]
            cmp     x0, 0
            b.eq    tictactoe_loop_reentry
            bl      puts
            ldr     x9, =lastErr
            mov     x10, 0
            str     x10, [x9]
            b       tictactoe_loop_reentry

/*
 **********************************************************************
 *  void clearScreen();
 *
 *      Prints bash clear screen character sequence.
 **********************************************************************
 */
            .type   clearScreen, %function
clearScreen:
            sub     sp, sp, 16
            str     x30, [sp, 8]
            ldr     x0, =clrStr
            bl      printf
            ldr     x30, [sp, 8]
            add     sp, sp, 16
            ret

/*
 **********************************************************************
 *  printBoard(uint32_t state);
 *
 *      The lower 18 bits are used for encoding the game state, i.e. two
 *      two bits per field of the game board. The "loop" for printing the
 *      game board squares is unrolled.
 **********************************************************************
 */
            .type   printBoard, %function
printBoard:
            sub     sp, sp, 48
            str     x30, [sp]
            str     x19, [sp, 8]
            str     x20, [sp, 16]
            str     x21, [sp, 24]
            ldr     x19, =gameBoard
            ldr     w19, [x19]
            ldr     x0, =ruler
            bl      printf
            mov     w0, w19
            mov     w1, 0
            bl      getStateChar
            mov     x20, x0
            mov     w0, w19
            mov     w1, 1
            bl      getStateChar
            mov     x21, x0
            mov     w0, w19
            mov     w1, 2
            bl      getStateChar
            mov     x3, x0
            mov     x2, x21
            mov     x1, x20
            ldr     x0, =fields
            bl      printf
            ldr     x0, =ruler
            bl      printf
            mov     w0, w19
            mov     w1, 3
            bl      getStateChar
            mov     x20, x0
            mov     w0, w19
            mov     w1, 4
            bl      getStateChar
            mov     x21, x0
            mov     w0, w19
            mov     w1, 5
            bl      getStateChar
            mov     x3, x0
            mov     x2, x21
            mov     x1, x20
            ldr     x0, =fields
            bl      printf
            ldr     x0, =ruler
            bl      printf
            mov     w0, w19
            mov     w1, 6
            bl      getStateChar
            mov     x20, x0
            mov     w0, w19
            mov     w1, 7
            bl      getStateChar
            mov     x21, x0
            mov     w0, w19
            mov     w1, 8
            bl      getStateChar
            mov     x3, x0
            mov     x2, x21
            mov     x1, x20
            ldr     x0, =fields
            bl      printf
            ldr     x0, =ruler
            bl      printf
            ldr     x21, [sp, 24]
            ldr     x20, [sp, 16]
            ldr     x19, [sp, 8]
            ldr     x30, [sp]
            add     sp, sp, 48
            ret

/*
 **********************************************************************
 *  int checkWinConds(uint32_t gameBoard);
 **********************************************************************
 */
            .type   checkWinConds, %function
checkWinConds:
            /* Row 0 */
            and     w9, w0, 0b111111
            cmp     w9, w1
            b.eq    checkWinConds_ret_win
            /* Row 1 */
            mov     w10, 0b111111
            lsl     w10, w10, 6
            and     w9, w0, w10
            lsr     w9, w9, 6
            cmp     w9, w1
            b.eq    checkWinConds_ret_win
            /* Row 2 */
            mov     w10, 0b111111
            lsl     w10, w10, 12
            and     w9, w0, w10
            lsr     w9, w9, 12
            cmp     w9, w1
            b.eq    checkWinConds_ret_win

            /* Col 0 */
            mov     w10, 0b0011000011000011
            and     w9, w0, w10
            cmp     w9, w2
            b.eq    checkWinConds_ret_win
            /* Col 1 */
            mov     w10, 0b0011000011000011
            lsl     w10, w10, 2
            and     w9, w0, w10
            lsr     w9, w9, 2
            cmp     w9, w2
            b.eq    checkWinConds_ret_win
            /* Col 2 */
            mov     w10, 0b0011000011000011
            lsl     w10, w10, 4
            and     w9, w0, w10
            lsr     w9, w9, 4
            cmp     w9, w2
            b.eq    checkWinConds_ret_win

            /* Diag down */
            movz    w10, 0b1100000011
            movk    w10, 0b11, lsl 16
            and     w9, w0, w10
            cmp     w9, w3
            b.eq    checkWinConds_ret_win
            /* Diag up */
            movz    w10, 0b11001100110000
            and     w9, w0, w10
            cmp     w9, w4
            b.eq    checkWinConds_ret_win
            
            mov     w0, 0
            ret

checkWinConds_ret_win:
            mov     w1, 1
            ret

/*
 **********************************************************************
 *  int checkWin(uint32_t gameBoard);
 **********************************************************************
 */
            .type   checkWin, %function
checkWin:
            sub     sp, sp, 16
            str     x30, [sp]
            str     w0, [sp, 8]

            /* X win conditions */
            mov     w1, 0b010101
            mov     w2, 0b1000001000001
            movz    w3, 0b100000001
            movk    w3, 0b01, lsl 16
            mov     w4, 0b1000100010000
            bl      checkWinConds
            cmp     w0, 0
            b.eq    checkWin_O_conds
            ldr     x30, [sp]
            add     sp, sp, 16
            ret

            /* O win conditions */
checkWin_O_conds:
            ldr     w0, [sp, 8]
            mov     w1, 0b101010
            mov     w2, 0b10000010000010
            movz    w3, 0b1000000010
            movk    w3, 0b10, lsl 16
            mov     w4, 0b10001000100000
            bl      checkWinConds
            ldr     x30, [sp]
            add     sp, sp, 16
            ret

/*
 **********************************************************************
 *  char *getStateChar(uint32_t gameBoard, int field);
 *
 *      Returns the character representation of the supplied field's
 *      value. Fields with the value zero (0) instead return the field's
 *      number in ASCII. Note that this function does not sanity check
 *      `field` to see whether it's in range before converting to ASCII.
 **********************************************************************
 */
            .type   getStateChar, %function
getStateChar:
            mov     w9, 2
            mov     w10, 0b11
            mul     w11, w1, w9
            lsl     w12, w10, w11
            and     w0, w0, w12
            lsr     w0, w0, w11
            cmp     w0, 1
            b.eq    getStateChar_X
            cmp     w0, 2
            b.eq    getStateChar_O
            ldr     x0, =fieldNums
            add     x0, x0, x11
            ret
getStateChar_X:
            ldr     x0, =fieldX
            ret
getStateChar_O:
            ldr     x0, =fieldO
            ret

/*
 **********************************************************************
 *  void setStateChar(uint32_t *gameBoard, int field, int val);
 *
 *      Sets a field on the game board to either X or O. Performing
 *      sanity checks on input parameters is left to the caller.
 **********************************************************************
 */
            .type   setStateChar, %function
setStateChar:        
            
            /*
             * Prep bit mask
             */
            mov     w9, 0b11
            mov     w10, 2
            mul     w1, w1, w10
            lsl     w9, w9, w1
            ldr     w11, [x0]

            /*
             * Sanity check for whether field has already been set. The
             * game won't let you write to the same field twice.
             */
            mov     w13, 0
            mvn     w13, w9
            orr     w14, w11, w13
            eor     w14, w14, w13
            cmp     w14, 0
            b.eq    setStateChar_skip
            ldr     x9, =lastErr
            ldr     x10, =errAlreadySetField
            str     x10, [x9]
            ret
setStateChar_skip:

            /*
             * Mask off bits that will be modified
             */
            orr     w12, w11, w9
            eor     w12, w12, w9

            /*
             * Set bits to be modified
             */
            lsl     w2, w2, w1
            orr     w12, w12, w2

            /*
             * Write the new state to the game board
             */
            str     w12, [x0]

            ret

/*
 **********************************************************************
 *  void setField(int field, int val);
 **********************************************************************
 */
            .type   cmd_X, %function
setField:
            sub     sp, sp, 16
            str     x30, [sp]
            cmp     w0, 0
            b.lt    setField_out_of_range
            cmp     w0, 8
            b.gt    setField_out_of_range
            mov     w2, w1
            mov     w1, w0
            ldr     x0, =gameBoard
            bl      setStateChar
            ldr     x30, [sp]
            add     sp, sp, 16
            ret

setField_out_of_range:
            ldr     x9, =lastErr
            ldr     x10, =errOutOfRangeCmd
            str     x10, [x9]
            ldr     x30, [sp]
            add     sp, sp, 16
            ret

/*
 **********************************************************************
 *  void processCmd(char *cmd);
 **********************************************************************
 */
            .type   processCmd, %function
processCmd:
            sub     sp, sp, 16
            str     x30, [sp]
            str     x19, [sp, 8]
            mov     x19, x0

            /*
             * Help command
             */
            mov     x0, x19 
            ldr     x1, =cmdHelpLong
            bl      strcmp
            cmp     x0, 0
            b.ne    processCmd_help_skip_1
            bl      cmd_Help
            b       processCmd_leave
processCmd_help_skip_1:
            mov     x0, x19
            ldr     x1, =cmdHelpShort
            bl      strcmp
            cmp     x0, 0
            b.ne    processCmd_help_skip_2
            bl      cmd_Help
            b       processCmd_leave
processCmd_help_skip_2:

            /*
             * Quit commands
             */
            mov     x0, x19
            ldr     x1, =cmdQuitLong
            bl      strcmp
            cmp     x0, 0
            b.ne    processCmd_quit_skip_1
            bl      cmd_Quit
            b       processCmd_leave
processCmd_quit_skip_1:
            mov     x0, x19
            ldr     x1, =cmdQuitShort
            bl      strcmp
            cmp     x0, 0
            b.ne    processCmd_quit_skip_2
            bl      cmd_Quit
            b       processCmd_leave
processCmd_quit_skip_2:
            mov     x0, x19
            ldr     x1, =cmdExit
            bl      strcmp
            cmp     x0, 0
            b.ne    processCmd_quit_skip_3
            bl      cmd_Quit
            b       processCmd_leave
processCmd_quit_skip_3:

            /*
             * Reset board command
             */
            mov     x0, x19 
            ldr     x1, =cmdReset
            bl      strcmp
            cmp     x0, 0
            b.ne    processCmd_reset_skip
            bl      cmd_Reset
            b       processCmd_leave
processCmd_reset_skip:

            /*
             * Place X commands
             */
            mov     x0, x19
            ldr     x1, =cmdXLower
            add     x2, sp, 8
            bl      sscanf
            cmp     x0, 0
            b.eq    processCmd_x_skip_1
            ldr     w0, [sp, 8]
            bl      cmd_X
            b       processCmd_leave
processCmd_x_skip_1:
            mov     x0, x19
            ldr     x1, =cmdXUpper
            add     x2, sp, 8
            bl      sscanf
            cmp     x0, 0
            b.eq    processCmd_x_skip_2
            ldr     x0, [sp, 8]
            bl      cmd_X
            b       processCmd_leave
processCmd_x_skip_2:

            /*
             * Place O commands
             */
            mov     x0, x19
            ldr     x1, =cmdOLower
            add     x2, sp, 8
            bl      sscanf
            cmp     x0, 0
            b.eq    processCmd_o_skip_1
            ldr     x0, [sp, 8]
            bl      cmd_O
            b       processCmd_leave
processCmd_o_skip_1:
            mov     x0, x19
            ldr     x1, =cmdOUpper
            add     x2, sp, 8
            bl      sscanf
            cmp     x0, 0
            ldr     x0, [sp, 8]
            b.eq    processCmd_o_skip_2
            bl      cmd_O
            b       processCmd_leave
processCmd_o_skip_2:

            /*
             * Invalid command
             */
            mov     x0, x19
            bl      cmd_Invalid

            /*
             * Au ravioli
             */
processCmd_leave:
            ldr     x19, [sp, 8]
            ldr     x30, [sp]
            add     sp, sp, 16
            ret

/*
 **********************************************************************
 *  void cmd_Help(void);
 *
 *      Print help text.
 **********************************************************************
 */
            .type   cmd_Help, %function
cmd_Help:
            ldr     x10, =lastErr
            ldr     x9, =helpMsg
            str 	x9, [x10]
            ret

/*
 **********************************************************************
 *  void cmd_Quit(void);
 *
 *      Exit the program.
 **********************************************************************
 */
            .type   cmd_Quit, %function
cmd_Quit:
            ldr     x0, =goodBye
            bl      puts
            mov     x0, 1
            bl      exit
            .word   0                                   // NOT REACHED

/*
 **********************************************************************
 *  void cmd_X(int field);
 **********************************************************************
 */
            .type   cmd_X, %function
cmd_X:
            sub     sp, sp, 16
            str     x30, [sp]
            mov     w1, 1
            bl      setField
            ldr     x30, [sp]
            add     sp, sp, 16
            ret

/*
 **********************************************************************
 *  void cmd_O(int field);
 **********************************************************************
 */
            .type   cmd_O, %function
cmd_O:
            sub     sp, sp, 16
            str     x30, [sp]
            mov     w1, 2
            bl      setField
            ldr     x30, [sp]
            add     sp, sp, 16
            ret

/*
 **********************************************************************
 *  void cmd_Reset(void);
 **********************************************************************
 */
            .type   cmd_Reset, %function
cmd_Reset:
            mov     w0, 0
            ldr     x9, =gameBoard
            str     x0, [x9]
            ret

/*
 **********************************************************************
 *  void cmd_Invalid(char *cmd);
 **********************************************************************
 */
            .type   cmd_Invalid, %function
cmd_Invalid:
            ldr     x10, =lastErr
            ldr     x9, =errInvalidCmd
            str 	x9, [x10]
            ret

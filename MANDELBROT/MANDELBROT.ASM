        ID_RADIO1 = 201
        ID_RADIO2 = 202
        ID_RADIO3 = 203

        ID_RADIO4 = 204
        ID_RADIO5 = 205
        ID_RADIO6 = 206

        ID_RADIO7 = 207
        ID_RADIO8 = 208
        ID_RADIO9 = 209

        RB_INDEX0 = 0
        RB_INDEX1 = 1
        RB_INDEX2 = 2

        ID_LIST = 104
        ID_RES = 105

        IDR_ICON = 17
        IDR_MENU = 38

        IDM_OPTIONS = 101
        IDM_EXIT  = 102
        IDM_ABOUT = 901

        DIB_RGB_COLORS = 0
        AC_SRC_OVER = 0

format PE GUI 4.0

entry start

include 'win32ax.inc'

section '.data' data readable writeable

struct RGBQUAD
       rgbRed db ?
       rgbGreen db ?
       rgbBlue db ?
       rgbReserved db ?
ends

struct RGBPOINT
       R db ?
       G db ?
       B db ?
       position dd ?
ends

struct BLENDFUNCTION
       BlendOp db ?
       BlendFlags db ?
       SourceConstantAlpha db ?
       AlphaFormat db ?
ends

struct BITMAPINFO
       bmiHeader BITMAPINFOHEADER ?
       bmiColors RGBQUAD ?
ends

struct SETTINGS
       resolution POINT 800, 600
       maxIter dd 250
ends

struct COMPLEX
       re dq ?
       im dq ?
ends
       maxIterations dd 250
                     dd 700
                     dd 2000

       resolutions POINT 1024, 768
                   POINT 800, 600
                   POINT 640, 480

       settings SETTINGS
       bitmapInfo BITMAPINFO

       btnDownPoint POINT
       currCursorPoint POINT
       isLeftBtnDown dd ?
       allowCloserLook dd ?
       isMainBitmapUpdated dd 0

       rectMarqueeColor dd ?
       rectMarquee RECT 0, 0, 0, 0
       hBufferDC dd ?

       mainBits rd 1000000
       currBits rd 1000000

       mainBitmapBits_ptr dd ?

       gx_max dd 800
       gy_max dd 600

       x_min_start dq -2.4
       x_max_start dq  1.0
       y_min_start dq -1.3
       y_max_start dq  1.3

       h_x_start dq 0.00425
       h_y_start dq 0.00433

       x_min dq -2.4
       x_max dq  1.0
       y_min dq -1.3
       y_max dq  1.3

       h_x dq 0.0
       h_y dq 0.0

       msg         MSG
       hwnd        dd ?
       hdc         dd ?
       ps          PAINTSTRUCT
       rect        RECT

       _error db 'Error', 0
       _class db 'FASMWIN32', 0
       _title db 'Mandelbrot Set Viewer', 0
       _about_title db 'How to...',0
       _about_text db 'To zoom in the image click the left button, drag and release. '
                   db 'To restore the start image click the right button.',0

       hComboBox dd ?

       checked1 dd 202
       checked2 dd 204
       curcelPos dd 0

       ;isBuzy dd 0
       ;mutex dd 0

       arrOfGradHex rd 5000
       startArrIndex dd 0
       colorArrLength dd 2048

       ;========== color set 1 =============
       rgbP1_1 RGBPOINT 255,255,255, 0.0
       rgbP2_1 RGBPOINT 255,204,0, 0.17
       rgbP3_1 RGBPOINT 135,31,19, 0.33
       rgbP4_1 RGBPOINT 76,17,78, 0.49
       rgbP5_1 RGBPOINT 0,0,153, 0.65
       rgbP6_1 RGBPOINT 0,102,255, 0.81
       rgbP7_1 RGBPOINT 255,255,255, 1.0

       ;========== color set 2 =============
       rgbP1_2 RGBPOINT 202, 254, 195, 0.0
       rgbP2_2 RGBPOINT 229, 228, 167, 0.17
       rgbP3_2 RGBPOINT 241, 81, 32, 0.33
       rgbP4_2 RGBPOINT 132, 28, 23, 0.49
       rgbP5_2 RGBPOINT 5, 116, 174, 0.65
       rgbP6_2 RGBPOINT 137, 211, 209, 0.81
       rgbP7_2 RGBPOINT 202, 254, 195, 1.0

       ;========== color set 3 =============
       rgbP1_3 RGBPOINT 232,17,50, 0.0
       rgbP2_3 RGBPOINT 38,254,158, 0.17
       rgbP3_3 RGBPOINT 34,100,198, 0.33
       rgbP4_3 RGBPOINT 242,14,145, 0.49
       rgbP5_3 RGBPOINT 2,238,27, 0.65
       rgbP6_3 RGBPOINT 59,40,162, 0.81
       rgbP7_3 RGBPOINT 232,17,50, 1.0

       ;========== color set 4 =============
       rgbP1_4 RGBPOINT 255,37,0, 0.0
       rgbP2_4 RGBPOINT 251,255,0, 0.17
       rgbP3_4 RGBPOINT 0,255,34, 0.33
       rgbP4_4 RGBPOINT 0,255,244, 0.49
       rgbP5_4 RGBPOINT 7,0,255, 0.65
       rgbP6_4 RGBPOINT 255,0,237, 0.81
       rgbP7_4 RGBPOINT 255,0,11, 1.0

       ;========== color set 5 =============
       rgbP1_5 RGBPOINT 3,249,43, 0.0
       rgbP2_5 RGBPOINT 27,12,18, 0.17
       rgbP3_5 RGBPOINT 11,113,99, 0.33
       rgbP4_5 RGBPOINT 161,239,209, 0.49
       rgbP5_5 RGBPOINT 140,201,55, 0.65
       rgbP6_5 RGBPOINT 98,98,97, 0.81
       rgbP7_5 RGBPOINT 3,247,43, 1.0

       isBuzy dd 0
       mutex dd 0

section '.text' code readable executable

start:
        stdcall  CreateOrResizeMainWindow, hwnd, [settings.resolution.x], [settings.resolution.y], 1

        invoke   InitializeCriticalSection, mutex

        stdcall  GetBackStandardLimits
        stdcall  SetColorPalette, 0
        stdcall  GenerateNewBitmap, mainBits
        mov      [isMainBitmapUpdated], 1

msg_loop:
        invoke   GetMessageA, msg, NULL, 0, 0
        cmp      eax, 1
        jb       end_loop
        jne      msg_loop
        invoke   TranslateMessage, msg
        invoke   DispatchMessageA, msg
        jmp      msg_loop

error:
        invoke   MessageBoxA, NULL, _error, NULL, MB_ICONERROR + MB_OK

end_loop:
        invoke   ExitProcess, 0

proc DialogProc hwnddlg,msg,wparam,lparam
        push     ebx esi edi
        cmp      [msg],WM_INITDIALOG
        je       .wminitdialog
        cmp      [msg],WM_COMMAND
        je       .wmcommand
        cmp      [msg],WM_CLOSE
        je       .wmclose
        xor      eax,eax
        jmp      .finish

  .wminitdialog:
        local halfScreenWidth_l:DWORD, halfScreenHeight_l:DWORD
        local DlgBoxRect_l:RECT
        local DlgBoxRect_l_ptr:DWORD
        local DlgBoxStyles_l:DWORD

        invoke   GetDlgItem,[hwnddlg],ID_LIST
        mov      [hComboBox],eax

        invoke   SendMessageA, [hComboBox], CB_ADDSTRING, 0, 'EarthAndSky'
        invoke   SendMessageA, [hComboBox], CB_ADDSTRING, 0, 'Seashore'
        invoke   SendMessageA, [hComboBox], CB_ADDSTRING, 0, 'Unknown'
        invoke   SendMessageA, [hComboBox], CB_ADDSTRING, 0, 'Rainbow'
        invoke   SendMessageA, [hComboBox], CB_ADDSTRING, 0, 'Weed'
        invoke   SendMessageA, [hComboBox], CB_SETCURSEL, [curcelPos], FALSE

        invoke   CheckRadioButton,[hwnddlg],ID_RADIO1,ID_RADIO3,[checked1]
        invoke   CheckRadioButton,[hwnddlg],ID_RADIO4,ID_RADIO6,[checked2]

        mov      [DlgBoxStyles_l], WS_CAPTION + WS_POPUP + WS_SYSMENU + DS_MODALFRAME

        mov      eax, esp
        add      eax, 20
        mov      [DlgBoxRect_l_ptr], eax

        stdcall  CenterWindow, [DlgBoxRect_l_ptr], [DlgBoxStyles_l], 559, 195

        invoke   SetWindowPos, [hwnddlg], HWND_TOP, [DlgBoxRect_l.left], [DlgBoxRect_l.top], [DlgBoxRect_l.right], [DlgBoxRect_l.bottom], SWP_SHOWWINDOW

        jmp      .processed
  .wmcommand:
        local resIndex:DWORD, maxIterIndex:DWORD, colorPaletteIndex:DWORD
        cmp      [wparam], BN_CLICKED shl 16 + IDOK
        jne      .processed

    .setNewRes:
        mov      [resIndex], RB_INDEX0
        invoke   IsDlgButtonChecked, [hwnddlg], ID_RADIO1
        cmp      eax, BST_CHECKED
        je       .setNewMaxIter

        mov      [resIndex], RB_INDEX1
        invoke   IsDlgButtonChecked, [hwnddlg], ID_RADIO2
        cmp      eax, BST_CHECKED
        je       .setNewMaxIter

        mov      [resIndex], RB_INDEX2
        invoke   IsDlgButtonChecked, [hwnddlg], ID_RADIO3
        cmp      eax, BST_CHECKED
        je       .setNewMaxIter

    .setNewMaxIter:
        mov      [maxIterIndex], RB_INDEX0
        invoke   IsDlgButtonChecked, [hwnddlg], ID_RADIO4
        cmp      eax, BST_CHECKED
        je       .applySettings

        mov      [maxIterIndex], RB_INDEX1
        invoke   IsDlgButtonChecked, [hwnddlg], ID_RADIO5
        cmp      eax, BST_CHECKED
        je       .applySettings

        mov      [maxIterIndex], RB_INDEX2
        invoke   IsDlgButtonChecked, [hwnddlg], ID_RADIO6
        cmp      eax, BST_CHECKED
        je       .applySettings

    .applySettings:
        invoke   SendMessageA, [hComboBox], CB_GETCURSEL, 0, 0
        mov      [colorPaletteIndex], eax
        mov      [curcelPos], eax

        mov      eax, ID_RADIO1
        add      eax, [resIndex]
        mov      [checked1], eax
        mov      eax, ID_RADIO4
        add      eax, [maxIterIndex]
        mov      [checked2], eax

        stdcall  ModifySettings, [resIndex], [maxIterIndex], [colorPaletteIndex]
        stdcall  CreateOrResizeMainWindow, [hwnd], [settings.resolution.x], [settings.resolution.y], 0
        stdcall  GenerateNewBitmap, currBits
        mov      [isMainBitmapUpdated], 0
        invoke   EndDialog, [hwnddlg], 1
        jmp      .processed

  .wmclose:
        invoke   EndDialog, [hwnddlg], 1
        jmp      .processed

  .processed:
        mov      eax, 1

  .finish:
        pop      edi esi ebx
        ret
endp

proc WindowProc uses ebx esi edi, hwnd, wmsg, wparam, lparam
        cmp      [wmsg], WM_ERASEBKGND
        je       .erasebgnd
        cmp      [wmsg], WM_COMMAND
        je       .wmcommand
        cmp      [wmsg], WM_MOUSEMOVE
        je       .mousemove
        cmp      [wmsg], WM_LBUTTONDOWN
        je       .leftbuttondown
        cmp      [wmsg], WM_LBUTTONUP
        je       .leftbuttonup
        cmp      [wmsg], WM_RBUTTONDOWN
        je       .rightbuttondown
        cmp      [wmsg], WM_DESTROY
        je       .wmdestroy
        cmp      [wmsg], WM_PAINT
        je       .wmpaint

    .defwndproc:
        invoke   DefWindowProcA, [hwnd], [wmsg], [wparam], [lparam]
        jmp      .finish

    .wmcommand:
        mov     eax, [wparam]
        and     eax, 0FFFFh
        cmp     eax, IDM_ABOUT
        je      .about
        cmp     eax, IDM_OPTIONS
        je      .options
        cmp     eax, IDM_EXIT
        je      .wmdestroy
        jmp     .defwndproc
      .options:
        invoke   GetModuleHandleA, 0
        invoke   DialogBoxParamA, eax, 37, HWND_DESKTOP, DialogProc, 0
        or       eax,eax
        jz       end_loop
        ret
      .about:
        invoke   MessageBoxA,[hwnd],_about_text,_about_title,MB_OK
        ret
    .wmpaint:
        invoke   BeginPaint, [hwnd], ps
        mov      [hdc], eax
        invoke   GetClientRect, [hwnd], rect

        stdcall  GetBackBuffer, [hwnd]
        mov      [hBufferDC], eax

        stdcall  DrawMainBitmap, [hwnd], [hBufferDC], [mainBitmapBits_ptr]

        cmp      [isLeftBtnDown], 0
        je       .skipRectMarquee

        stdcall  DrawRectMarquee, [hwnd], [hBufferDC]

     .skipRectMarquee:
        invoke   BitBlt, [hdc], 0, 0, [rect.right], [rect.bottom], [hBufferDC], 0, 0, SRCCOPY
        invoke   DeleteDC, [hBufferDC]
        invoke   EndPaint, [hwnd], ps
        ret

    .erasebgnd:
        xor      eax, eax
        mov      eax, 1
        ret

    .mousemove:
        cmp      [isLeftBtnDown], 1
        jne      .ignoreMouseMove

        invoke   GetCursorPos, currCursorPoint
        invoke   ScreenToClient, [hwnd], currCursorPoint

        local    multiplic:DWORD, widthX:DWORD, heightY:DWORD
        mov      [multiplic], 0.75

        mov      eax, [btnDownPoint.x]
        cmp      [currCursorPoint.x], eax
        jge      .rightDirectX
        jmp      .leftDirectX
        ;========================
            .rightDirectX:
                fild     [currCursorPoint.x]
                fist     [rectMarquee.right]
                fild     [btnDownPoint.x]
                fist     [rectMarquee.left]
                fsubp
                fistp    [widthX]
                fild     [widthX]
                fld      [multiplic]
                fmulp
                fild     [btnDownPoint.y]
                fist     [rectMarquee.top]
                faddp
                fistp    [rectMarquee.bottom]
                jmp      .setCloserLookPermission

            .leftDirectX:
                fild     [btnDownPoint.x]
                fist     [rectMarquee.right]
                fild     [currCursorPoint.x]
                fist     [rectMarquee.left]
                fsubp
                fistp    [widthX]
                fild     [widthX]
                fld      [multiplic]
                fmulp
                fist     [heightY]
                fild     [btnDownPoint.y]
                fist     [rectMarquee.bottom]
                fsubrp
                fistp    [rectMarquee.top]
                jmp      .setCloserLookPermission
        ;========================

        .setCloserLookPermission:
        mov      [rectMarqueeColor], 0x001C18FF
        mov      [allowCloserLook], 0

        cmp      [isBuzy], 0
        ja       .dontAllow

        cmp      [widthX], 100d
        jb       .dontAllow

        cmp      [rectMarquee.left], 3
        jl       .dontAllow

        mov      eax, [gx_max]
        sub      eax, 3
        cmp      [rectMarquee.right], eax
        jg       .dontAllow

        mov      eax, [gy_max]
        sub      eax, 3
        cmp      [rectMarquee.bottom], eax
        jge      .dontAllow

        fild     [gy_max]
        fild     [rectMarquee.top]
        fsubp
        fistp    [heightY]
        cmp      [heightY], eax
        jge      .dontAllow

        mov      [rectMarqueeColor], 0x0013AF0B
        mov      [allowCloserLook], 1

        .dontAllow:
        invoke   InvalidateRect, [hwnd], NULL, FALSE

        .ignoreMouseMove:
        ret


    .leftbuttondown:
        invoke   SetCapture, [hwnd]
        mov      [isLeftBtnDown], 1
        mov      [rectMarquee.left], 0
        mov      [rectMarquee.top], 0
        mov      [rectMarquee.right], 0
        mov      [rectMarquee.bottom],0
        invoke   GetCursorPos, btnDownPoint
        invoke   ScreenToClient, [hwnd], btnDownPoint
        ret

    .leftbuttonup:
        mov      [isLeftBtnDown], 0
        invoke   ReleaseCapture
        invoke   InvalidateRect, [hwnd], NULL, FALSE

        cmp      [isBuzy], 0
        ja       .ignoreChoosing
        cmp      [allowCloserLook], 1
        je       .drawNewPhase
        .ignoreChoosing:
        ret

    .drawNewPhase:
        stdcall  SetNewLimits
        stdcall  GenerateNewBitmap, currBits
        ret

    .rightbuttondown:
        cmp      [isLeftBtnDown], 0
        jne      .ignoreRightBtn
        cmp      [isBuzy], 0
        ja       .ignoreRightBtn
        cmp      [isMainBitmapUpdated], 1
        jne      .generateNew

        stdcall  GetBackStandardLimits
        mov      eax, mainBits
        mov      [mainBitmapBits_ptr], eax
        invoke   InvalidateRect, [hwnd], NULL, FALSE
        jmp      .ignoreRightBtn

        .generateNew:
        stdcall  GetBackStandardLimits
        stdcall  GenerateNewBitmap, mainBits
        mov      [isMainBitmapUpdated], 1
        .ignoreRightBtn:
        ret

    .wmdestroy:
        invoke   ReleaseDC, [hwnd], [hdc]
        invoke   DeleteCriticalSection, mutex
        invoke   PostQuitMessage, 0
        xor      eax, eax

    .finish:
        ret
endp

proc GenerateNewBitmap, bitsArr_ptr:DWORD
        stdcall  FillBitmap, [bitsArr_ptr], 0A0A0A0h
        mov      eax, [bitsArr_ptr]
        mov      [mainBitmapBits_ptr], eax

        invoke   CreateThread, NULL, NULL, ThreadProc, 1, NORMAL_PRIORITY_CLASS, NULL
        invoke   CloseHandle, eax
        invoke   CreateThread, NULL, NULL, ThreadProc, 2, NORMAL_PRIORITY_CLASS, NULL
        invoke   CloseHandle, eax
        invoke   CreateThread, NULL, NULL, ThreadProc, 3, NORMAL_PRIORITY_CLASS, NULL
        invoke   CloseHandle, eax
        invoke   CreateThread, NULL, NULL, ThreadProc, 4, NORMAL_PRIORITY_CLASS, NULL
        invoke   CloseHandle, eax
        ret
endp
proc CalcRGBgradientBetweenPoints, point1_ptr:DWORD, point2_ptr:DWORD
        local R_point1_l:BYTE, G_point1_l:BYTE, B_point1_l:BYTE
        local R_point2_l:BYTE, G_point2_l:BYTE, B_point2_l:BYTE
        local R_new_l:BYTE, G_new_l:BYTE, B_new_l:BYTE
        local norm_step_l:QWORD, start_pos_l:QWORD, end_pos_l:QWORD, curr_pos_l:QWORD
        ;== creating an already defined RGB value ==
        xor      ecx, ecx
        mov      ecx, [startArrIndex]

        mov      ebx, [point1_ptr]
        mov      al, [ebx + RGBPOINT.R]
        mov      [R_point1_l], al
        mov      al, [ebx + RGBPOINT.G]
        mov      [G_point1_l], al
        mov      al, [ebx + RGBPOINT.B]
        mov      [B_point1_l], al

        stdcall  RGBtoHEX, dword[R_point1_l], dword[G_point1_l], dword[B_point1_l]

        mov      [arrOfGradHex + ecx], eax
        add      [startArrIndex], 4 ;dword size
        ;===========================================
        finit
        fld1
        fild     [colorArrLength]
        fdivp
        fst      [norm_step_l]
        mov      ebx, [point1_ptr]
        fld      [ebx + RGBPOINT.position]
        fstp     [start_pos_l]
        fld      [start_pos_l]
        faddp
        fstp     [curr_pos_l]
        mov      ebx, [point2_ptr]
        fld      [ebx + RGBPOINT.position]
        fstp     [end_pos_l]

        ;=== creating RGB values in a cycle ===
        xor      ecx, ecx
        mov      ecx, [startArrIndex]

        mov      ebx, [point2_ptr]
        mov      al, [ebx + RGBPOINT.R]
        mov      [R_point2_l], al
        mov      al, [ebx + RGBPOINT.G]
        mov      [G_point2_l], al
        mov      al, [ebx + RGBPOINT.B]
        mov      [B_point2_l], al
nextRGB:
        ;get an RGB value between point 1 and 2
        ;get R
        stdcall  Lerp, dword[curr_pos_l], dword[curr_pos_l+4], dword[start_pos_l],\
        dword[start_pos_l+4], dword[R_point1_l], dword[end_pos_l], dword[end_pos_l+4],\
        dword[R_point2_l]

        mov      [R_new_l], al
        ;get G
        stdcall  Lerp, dword[curr_pos_l], dword[curr_pos_l+4], dword[start_pos_l],\
        dword[start_pos_l+4], dword[G_point1_l], dword[end_pos_l], dword[end_pos_l+4],\
        dword[G_point2_l]

        mov      [G_new_l], al
        ;get B
        stdcall  Lerp, dword[curr_pos_l], dword[curr_pos_l+4], dword[start_pos_l],\
        dword[start_pos_l+4], dword[B_point1_l], dword[end_pos_l], dword[end_pos_l+4],\
        dword[B_point2_l]

        mov      [B_new_l], al

        stdcall  RGBtoHEX, dword[R_new_l], dword[G_new_l], dword[B_new_l];returns the HEX value in the eax register

        mov      [arrOfGradHex + ecx], eax
        add      ecx, 4

        fld      [curr_pos_l]
        fld      [norm_step_l]
        faddp
        fst      [curr_pos_l]

        fld      [end_pos_l]
        fcomip   st1
        ffree    st0
        ja       nextRGB
        ;======================================
        mov      [startArrIndex], ecx
        ret
endp

proc Lerp, norm:QWORD, x1:QWORD, y1:DWORD, x2:QWORD, y2:DWORD
     local y1_l:DWORD, y2_l:DWORD
     local w1_l:QWORD, w2_l:QWORD, y_res:DWORD

        xor      eax, eax
        mov      al, byte[y1]   ;converting a byte value to a dword value for FPU
        mov      [y1_l], eax
        mov      al, byte[y2]
        mov      [y2_l], eax

        finit
        fld1
        fld      [x2]
        fld      [x1]
        fsubp
        fld      [norm]
        fld      [x1]
        fsubp
        fdivrp
        fsubp
        fstp     [w1_l]

        fld1
        fld      [x2]
        fld      [x1]
        fsubp
        fld      [x2]
        fld      [norm]
        fsubp
        fdivrp
        fsubp
        fstp     [w2_l]

        fld      [w2_l]
        fild     [y2_l]
        fmulp

        fld      [w1_l]
        fild     [y1_l]
        fmulp
        faddp

        fistp    [y_res]

        mov      eax, [y_res]
        ret
endp

proc RGBtoHEX stdcall uses ebx edx,\
     R:BYTE, G:BYTE, B:BYTE

     local someConst_16:DWORD
     local byte1:BYTE, byte2:BYTE, byte3:BYTE, byte4:BYTE, byte5:BYTE, byte6:BYTE
        xor      eax, eax
        xor      ebx, ebx
        xor      edx, edx
        mov      [someConst_16], 16d

        ;byte #1,2 of HEX
        mov      al, [R]
        mov      ebx, [someConst_16]
        div      ebx
        mov      [byte1], al
        mov      [byte2], dl
        xor      edx, edx

        ;byte #3,4 of HEX
        mov      al, [G]
        mov      ebx, [someConst_16]
        div      ebx
        mov      [byte3], al
        mov      [byte4], dl
        xor      edx, edx

        ;byte #5,6 of HEX
        mov      al, [B]
        mov      ebx, [someConst_16]
        div      ebx
        mov      [byte5], al
        mov      [byte6], dl
        xor      edx, edx

        xor      eax, eax
        mov      al, [byte1]
        shl      eax, 4
        mov      bl, [byte2]
        or       al, bl
        shl      eax, 4
        mov      bl, [byte3]
        or       al, bl
        shl      eax, 4
        mov      bl, [byte4]
        or       al, bl
        shl      eax, 4
        mov      bl, [byte5]
        or       al, bl
        shl      eax, 4
        mov      bl, [byte6]
        or       al, bl
        ret
endp

proc ThreadProc, Param:DWORD
        inc       [isBuzy]
        stdcall   CreateFractalBitmap, [Param]
        dec       [isBuzy]
        xor       eax,eax
        ret
endp

proc FillBitmap, bitsArray:DWORD, color:DWORD
     local pixelsCount_l:DWORD, const_4:DWORD
        mov       [const_4], 4
        fild      [gx_max]
        fild      [gy_max]
        fild      [const_4]
        fmulp
        fmulp
        fistp     [pixelsCount_l]

        mov       ecx, [bitsArray]
        push      ebx
        xor       ebx, ebx
        mov       ebx, 0
        mov       eax, [color]
     .fillPixel:

        mov       dword[ecx + ebx], eax
        add       ebx, 4
        cmp       ebx, [pixelsCount_l]
        jne       .fillPixel
        pop       ebx
        ret
endp

proc GetBackStandardLimits
        fld      [x_min_start]
        fstp     [x_min]
        fld      [x_max_start]
        fstp     [x_max]
        fld      [y_min_start]
        fstp     [y_min]
        fld      [y_max_start]
        fstp     [y_max]
        fld      [h_x_start]
        fstp     [h_x]
        fld      [h_y_start]
        fstp     [h_y]
        ret
endp

proc SetNewLimits
     local newMinX:DWORD, newMaxX:DWORD, newMinY:DWORD, newMaxY:DWORD
     local StepsToAdd:DWORD, StepsToSub:DWORD, xRightCounter:DWORD
    ;========= x line limits ============
        fild     [rectMarquee.left]
        fldz
        faddp
        fistp    [StepsToAdd]

        fld      [h_x]
        fld      [x_min]
    .incXMin:
        fadd     st0, st1
        dec      [StepsToAdd]
        cmp      [StepsToAdd], 0d
        ja       .incXMin
        fstp     [x_min]
        ffree    st0
    ;------------------------------
        fild     [gx_max]
        fild     [rectMarquee.right]
        fsubp
        fistp    [StepsToSub]

        fld      [h_x]
        fld      [x_max]
    .decXMax:
        fsub     st0, st1
        dec      [StepsToSub]
        cmp      [StepsToSub], 0d
        ja       .decXMax
        fstp     [x_max]
        ffree    st0
    ;========= y line limits ============
        fild     [gy_max]
        fild     [rectMarquee.bottom]
        fsubp
        fistp    [StepsToAdd]

        fld      [h_y]
        fld      [y_min]
    .incYMin:
        fadd     st0, st1
        dec      [StepsToAdd]
        cmp      [StepsToAdd], 0d
        ja       .incYMin
        fstp     [y_min]
        ffree    st0
    ;------------------------------
        fldz
        fild     [rectMarquee.top]
        faddp
        fistp    [StepsToSub]

        fld      [h_y]
        fld      [y_max]
    .decYMax:
        fsub     st0, st1
        dec      [StepsToSub]
        cmp      [StepsToSub], 0d
        ja       .decYMax
        fstp     [y_max]
        ffree    st0
        ret
endp

proc GetBackBuffer stdcall, hWnd:DWORD
     local hDc_l:DWORD, g_hMemDc_l:DWORD, g_hBackBuffer_l:DWORD
     local client_l:RECT
     local bufferToDelete:DWORD

        mov        eax, esp
        add        eax, 12  ;pointer to the rectange var stores on the stack
        invoke     GetClientRect, [hWnd], eax

        invoke     GetDC, [hWnd]
        mov        [hDc_l], eax

        invoke     CreateCompatibleDC, [hDc_l]
        mov        [g_hMemDc_l], eax

        invoke     CreateCompatibleBitmap, [hDc_l], [client_l.right], [client_l.bottom]
        mov        [g_hBackBuffer_l], eax
        mov        [bufferToDelete], eax

        invoke     SelectObject, [g_hMemDc_l], [g_hBackBuffer_l]
        invoke     ReleaseDC, [hWnd], [hDc_l]
        invoke     DeleteObject, [bufferToDelete]
        mov        eax, [g_hMemDc_l]
        ret
endp

proc DrawMainBitmap stdcall, hWnd:DWORD, hDcMemory:DWORD, bitsArr_ptr:DWORD
    local bm_info_l BITMAPINFO

        invoke     FillRect, [hDcMemory], rect, COLOR_BTNFACE

        mov        [bm_info_l.bmiHeader.biSize], sizeof.BITMAPINFOHEADER

        fild       [rect.right]
        fistp      [bm_info_l.bmiHeader.biWidth]

        fldz
        fild       [rect.bottom]
        fsubp
        fistp      [bm_info_l.bmiHeader.biHeight] ;(- height) because windows bitmaps
                                                  ;are stored with the bottom line first
        mov        [bm_info_l.bmiHeader.biPlanes], 1
        mov        [bm_info_l.bmiHeader.biBitCount], 32
        mov        [bm_info_l.bmiHeader.biCompression], BI_RGB
        mov        [bm_info_l.bmiHeader.biSizeImage], 0
        mov        [bm_info_l.bmiHeader.biXPelsPerMeter], 0
        mov        [bm_info_l.bmiHeader.biYPelsPerMeter], 0
        mov        [bm_info_l.bmiHeader.biClrUsed], 0
        mov        [bm_info_l.bmiHeader.biClrImportant], 0

        mov        eax, esp  ;pointer to the BITMAPINFO structure
        invoke     SetDIBitsToDevice, [hDcMemory], 0, 0, [rect.right], [rect.bottom], 0, 0, 0, [rect.bottom], [bitsArr_ptr], eax, DIB_RGB_COLORS
        ret
endp

proc DrawRectMarquee stdcall, hWnd:DWORD, hDcMemory:DWORD
     local blend_func_l:BLENDFUNCTION
     local hMarqueeDc_l:DWORD
     local hMarqueeBitmap_l:DWORD
     local hNewBrush_l:DWORD
     local rectWidth:DWORD, rectHeight:DWORD

        mov      [blend_func_l.SourceConstantAlpha], 100
        mov      [blend_func_l.BlendOp], AC_SRC_OVER
        mov      [blend_func_l.BlendFlags], 0
        mov      [blend_func_l.AlphaFormat], 0

        invoke   CreateCompatibleBitmap, [hDcMemory], [rect.right], [rect.bottom]
        mov      [hMarqueeBitmap_l], eax

        invoke   CreateCompatibleDC, [hDcMemory]
        mov      [hMarqueeDc_l], eax

        invoke   SelectObject, [hMarqueeDc_l], [hMarqueeBitmap_l]

        invoke   CreateSolidBrush, [rectMarqueeColor]
        mov      [hNewBrush_l], eax

        invoke   FillRect, [hMarqueeDc_l], rect, [hNewBrush_l]

        fild     [rectMarquee.right]
        fild     [rectMarquee.left]
        fsubp
        fistp    [rectWidth]

        fild     [rectMarquee.bottom]
        fild     [rectMarquee.top]
        fsubp
        fistp    [rectHeight]

        invoke   AlphaBlend, [hDcMemory], [rectMarquee.left], [rectMarquee.top], [rectWidth], [rectHeight], [hMarqueeDc_l], 0, 0, [rect.right], [rect.bottom], dword[blend_func_l]
        invoke   DeleteDC, [hMarqueeDc_l]

        invoke   DeleteObject, [hNewBrush_l]
        invoke   DeleteObject, [hMarqueeBitmap_l]
        ret

endp

proc CreateFractalBitmap stdcall, quater:DWORD
     local C:COMPLEX
     local currPixel:POINT
     local iterCounter:DWORD
     local Z:COMPLEX
     local Z_next:COMPLEX
     local pixelIndex:DWORD
     local someConst_4:DWORD
     local someConst_2:DWORD
     local start_y_pixel:DWORD
     local end_y_pixel:DWORD

        mov      [someConst_2], 2
        mov      [someConst_4], 4

        finit
        ;-good soup
        fild     [gy_max]
        fild     [someConst_4]
        fdivp
        fild     [quater]
        fmul     st0, st1
        fist     [end_y_pixel]
        fsubrp
        fistp    [start_y_pixel]
        ;--

        ;------
        fild    [start_y_pixel]
        fild    [gx_max]
        fmulp
        fild    [someConst_4]
        fmulp
        fistp   [pixelIndex]
        ;-------

        ;=== set new steps(x, y) for the point ===
        fld      [x_min]
        fld      [x_max]
        fsubp
        fild     [gx_max]
        fdivp
        fabs
        fstp     [h_x]
        ;-----------------------------------------
        fld      [y_min]
        fld      [y_max]
        fsubp
        fild     [gy_max]
        fdivp
        fabs
        fstp     [h_y]
        ;=========================================

        ;=== seting the first point ===
        fld      [x_min]
        fstp     [C.re]

        fld      [y_max]
        fild     [start_y_pixel]
        fld      [h_y]
        fmulp
        fsubp
        fstp     [C.im]
        ;-----------------------------

        fldz
        fistp    [currPixel.x]  ; start x pixel (always 0)

        ;---- setting the new start pixel -------

        fild     [start_y_pixel]
        fistp    [currPixel.y]
        ;===========================

drawLineYn:
   drawLineXn:

        ffree    st0
        ;===== iteration process =========
        fldz
        fldz
        fst      [Z_next.re]
        fst      [Z_next.im]
        fstp     [Z.re]
        fstp     [Z.im]

        xor      eax, eax

    useFormula:
        ;(a+ib)(c+id)= a(c+id)+ib(c+id)
        fld      [Z.im]           ;=
        fld      [Z.re]           ;= st = iB*C
        fmulp                     ;=
        fld      [Z.re]           ;=
        fld      [Z.im]           ;= st = A*iD
        fmulp                     ;=
        faddp                     ;= Im part of mul
        fldz                      ;=
        fld1                      ;= st = (-1)
        fsubp                     ;=
        fld      [Z.im]           ;=
        fld      [Z.im]           ;= st = iB*iD
        fmulp                     ;=
        fmulp                     ;= Xi^2 = X*(-1)
        fld      [Z.re]           ;=
        fld      [Z.re]           ;= st = A*C
        fmulp                     ;=
        faddp                     ;= A*C + Xi^2   or Re part of mul
        fld      [C.re]           ;=
        faddp                     ;= Z+1.Re = Z.Re + C.Re
        fst      [Z_next.re]      ;=
        fstp     [Z.re]           ;=
        fld      [C.im]           ;=
        faddp                     ;= Z+1.Im = Z.Im + C.Im
        fst      [Z_next.im]      ;=
        fstp     [Z.im]           ;=
        ;===========================

        ;== check if stable ========
        fild     [someConst_4]    ;=
        fld      [Z_next.im]      ;=
        fld      [Z_next.im]      ;=
        fmulp                     ;=
        fld      [Z_next.re]      ;=
        fld      [Z_next.re]      ;=
        fmulp                     ;=
        faddp                     ;=
                                  ;=
        fcomip   st1              ;=
        ja       setPointColor    ;= the point is already diverged
        ffree    st0              ;=
        ;==========================

        inc      eax
        cmp      eax, [settings.maxIter]
        jbe      useFormula

;== plotting current point to a new color ==
     setPointColor:                       ;=
        ffree    st0                      ;=
        cmp      eax, [settings.maxIter]  ;=
        jae      useMain                  ;=
        jmp      useCustom                ;=
                                          ;=
     useCustom:                           ;=
        cmp      eax, 0                   ;=
        jne      continue                 ;=
        inc      eax                      ;=
                                          ;=
     continue:                            ;=
        xor      edx, edx                 ;=
        mov      ebx, 4                   ;=
        stdcall  GetColorByIndex, eax, dword[Z_next.re], dword[Z_next.re+4],\
                                       dword[Z_next.im], dword[Z_next.im+4]
        mul      ebx                      ;=
        mov      ebx, arrOfGradHex        ;=
        add      ebx, eax                 ;=
        mov      eax, [ebx]               ;=
        jmp      setPixel                 ;=
                                          ;=
     useMain:                             ;=
        mov      eax, 00h                 ;=
                                          ;=
     setPixel:                            ;=
        mov      edx, [mainBitmapBits_ptr];=
        mov      ecx, [pixelIndex]        ;=
        mov      dword[edx + ecx], eax    ;=
        add      [pixelIndex], 4          ;=
;===========================================

        ;======== update x ============
        fld      [h_x]               ;=
        fld      [C.re]              ;=
        faddp                        ;=
        fstp     [C.re]              ;=
                                     ;=
        inc      [currPixel.x]       ;=
        fild     [gx_max]            ;=
        fild     [currPixel.x]       ;=
                                     ;=
        fcomip   st1                 ;=
        jb       drawLineXn          ;=
        ffree    st0                 ;=
        ;==============================

     invoke    EnterCriticalSection, mutex
     invoke    InvalidateRect, [hwnd], NULL, FALSE
     invoke    LeaveCriticalSection, mutex

     ;=== update y, reset x ========
     fld       [x_min]            ;=
     fstp      [C.re]             ;=
     fldz                         ;=
     fistp     [currPixel.x]      ;=
                                  ;=
     fld       [C.im]             ;=
     fld       [h_y]              ;=
     fsubp                        ;=
     fstp      [C.im]             ;=
                                  ;=
     inc       [currPixel.y]      ;=
     fild      [end_y_pixel]      ;=
     fild      [currPixel.y]      ;=
                                  ;=
     fcomip    st1                ;=
     jb        drawLineYn         ;=
     ffree     st0                ;=
     ;==============================
     ret
endp

proc GetColorByIndex, i:DWORD, re:QWORD, im:QWORD
   ;double smoothed = Math.Log2(Math.Log2(re * re + im * im) / 2);  // log_2(log_2(|p|))
   ;int colorI = (int)(Math.Sqrt(i + 10 - smoothed) * gradient.Scale) % colors.Length;
   ;Color color = colors[colorI];
     local smoothed:QWORD
     local gradientScale:DWORD
     local colorsLength:DWORD
     local someConst_10:DWORD
     local roundedVal:DWORD

        mov     [gradientScale], 256
        mov     eax, [colorArrLength]
        mov     [colorsLength], eax
        mov     [someConst_10], 10
        ;===== calc smoothed =====
        fld1
        fld1
        fld     [re]
        fld     [re]
        fmulp
        fld     [im]
        fld     [im]
        fmulp
        faddp
        fyl2x
        fld1
        fld1
        faddp
        fdivp
        fyl2x
        fstp    [smoothed]
        ;=========================
        fild    [colorsLength]
        fild    [i]
        fild    [someConst_10]
        faddp
        fld     [smoothed]
        fsubp
        fsqrt
        fild    [gradientScale]
        fmulp
        fprem
        ffree   st1
        fistp   [roundedVal]
        mov     eax, [roundedVal]
        ret
endp

proc CreateOrResizeMainWindow stdcall, hwnd_ptr:DWORD, width:DWORD, height:DWORD, toCreate:DWORD
     local  wc_l:WNDCLASS
     local  wc_l_prt:DWORD
     local  client_rect_l:RECT
     local  client_rect_l_ptr:DWORD
     local  window_styles_l:DWORD

     mov      [window_styles_l], WS_VISIBLE + WS_DLGFRAME + WS_SYSMENU + WS_MINIMIZEBOX + WS_BORDER

     mov      eax, [width]
     mov      [gx_max], eax
     mov      eax, [height]
     mov      [gy_max], eax
     mov      eax, esp
     mov      [wc_l_prt], eax
     add      eax, 44
     mov      [client_rect_l_ptr], eax

     stdcall  CenterWindow, [client_rect_l_ptr], [window_styles_l], [width], [height]

     cmp      [toCreate], 1
     jne      resizeWindow

     invoke   GetModuleHandleA, 0
     mov      [wc_l.hInstance], eax
     invoke   LoadIconA, eax, IDR_ICON
     mov      [wc_l.hIcon], eax
     invoke   LoadCursorA, 0, IDC_ARROW
     mov      [wc_l.hCursor], eax
     mov      [wc_l.style], 0
     mov      [wc_l.lpfnWndProc], WindowProc
     mov      [wc_l.cbClsExtra], 0
     mov      [wc_l.cbWndExtra], 0
     mov      [wc_l.hbrBackground], COLOR_BTNFACE
     mov      dword [wc_l.lpszMenuName], NULL
     mov      dword [wc_l.lpszClassName], _class

     invoke   RegisterClassA, [wc_l_prt]

     test     eax, eax
     jz       error

     invoke   LoadMenuA, [wc_l.hInstance], IDR_MENU
     invoke   CreateWindowExA, 0, _class, _title, [window_styles_l], [client_rect_l.left], [client_rect_l.top], [client_rect_l.right],  [client_rect_l.bottom], NULL, eax,[wc_l.hInstance],NULL
     mov      ebx, [hwnd_ptr]
     mov      [ebx], eax

     test     eax, eax
     jz       error
     ret
     resizeWindow:
     invoke   SetWindowPos, [hwnd_ptr], 0, [client_rect_l.left], [client_rect_l.top], [client_rect_l.right],  [client_rect_l.bottom], NULL
    ; SWP_NOMOVE | SWP_NOOWNERZORDER | SWP_NOZORDER);
     ret
endp

proc ModifySettings stdcall, res_index:DWORD, maxIter_index:DWORD, colorPalette_index:DWORD
    setResolution:
     mov      eax, [res_index]
     mov      ebx, 8
     mul      ebx
     mov      ebx, [eax + resolutions.x]
     mov      [settings.resolution.x], ebx
     mov      ebx, [eax + resolutions.y]
     mov      [settings.resolution.y], ebx

     ;edit a start iteration step (depends on the resolution)
     fld      [x_min_start]
     fld      [x_max_start]
     fsubp
     fild     [settings.resolution.x]
     fdivp
     fabs
     fstp     [h_x_start]
     ;-------------------------------------
     fld      [y_min_start]
     fld      [y_max_start]
     fsubp
     fild     [settings.resolution.y]
     fdivp
     fabs
     fstp     [h_y_start]
     ;-------------------------------------

    setMaxIter:
     mov      eax, [maxIter_index]
     mov      ebx, 4
     mul      ebx
     mov      ebx, [eax + maxIterations]
     mov      [settings.maxIter], ebx

     stdcall  SetColorPalette, [colorPalette_index]
     ret
endp

proc SetColorPalette stdcall, palette_index:DWORD
     mov      [startArrIndex], 0 ;reset indexer
     cmp      [palette_index], 0
     je       useSet1
     cmp      [palette_index], 1
     je       useSet2
     cmp      [palette_index], 2
     je       useSet3
     cmp      [palette_index], 3
     je       useSet4
     jmp      useSet5

  useSet1:
     stdcall  CalcRGBgradientBetweenPoints, rgbP1_1, rgbP2_1
     stdcall  CalcRGBgradientBetweenPoints, rgbP2_1, rgbP3_1
     stdcall  CalcRGBgradientBetweenPoints, rgbP3_1, rgbP4_1
     stdcall  CalcRGBgradientBetweenPoints, rgbP4_1, rgbP5_1
     stdcall  CalcRGBgradientBetweenPoints, rgbP5_1, rgbP6_1
     stdcall  CalcRGBgradientBetweenPoints, rgbP6_1, rgbP7_1
     jmp      retLabel

  useSet2:
     stdcall  CalcRGBgradientBetweenPoints, rgbP1_2, rgbP2_2
     stdcall  CalcRGBgradientBetweenPoints, rgbP2_2, rgbP3_2
     stdcall  CalcRGBgradientBetweenPoints, rgbP3_2, rgbP4_2
     stdcall  CalcRGBgradientBetweenPoints, rgbP4_2, rgbP5_2
     stdcall  CalcRGBgradientBetweenPoints, rgbP5_2, rgbP6_2
     stdcall  CalcRGBgradientBetweenPoints, rgbP6_2, rgbP7_2
     jmp      retLabel

  useSet3:
     stdcall  CalcRGBgradientBetweenPoints, rgbP1_3, rgbP2_3
     stdcall  CalcRGBgradientBetweenPoints, rgbP2_3, rgbP3_3
     stdcall  CalcRGBgradientBetweenPoints, rgbP3_3, rgbP4_3
     stdcall  CalcRGBgradientBetweenPoints, rgbP4_3, rgbP5_3
     stdcall  CalcRGBgradientBetweenPoints, rgbP5_3, rgbP6_3
     stdcall  CalcRGBgradientBetweenPoints, rgbP6_3, rgbP7_3
     jmp      retLabel

  useSet4:
     stdcall  CalcRGBgradientBetweenPoints, rgbP1_4, rgbP2_4
     stdcall  CalcRGBgradientBetweenPoints, rgbP2_4, rgbP3_4
     stdcall  CalcRGBgradientBetweenPoints, rgbP3_4, rgbP4_4
     stdcall  CalcRGBgradientBetweenPoints, rgbP4_4, rgbP5_4
     stdcall  CalcRGBgradientBetweenPoints, rgbP5_4, rgbP6_4
     stdcall  CalcRGBgradientBetweenPoints, rgbP6_4, rgbP7_4
     jmp      retLabel

  useSet5:
     stdcall  CalcRGBgradientBetweenPoints, rgbP1_5, rgbP2_5
     stdcall  CalcRGBgradientBetweenPoints, rgbP2_5, rgbP3_5
     stdcall  CalcRGBgradientBetweenPoints, rgbP3_5, rgbP4_5
     stdcall  CalcRGBgradientBetweenPoints, rgbP4_5, rgbP5_5
     stdcall  CalcRGBgradientBetweenPoints, rgbP5_5, rgbP6_5
     stdcall  CalcRGBgradientBetweenPoints, rgbP6_5, rgbP7_5
     retLabel:
     ret
endp
proc CenterWindow stdcall, client_rect_ptr:DWORD, window_styles:DWORD, width:DWORD, height:DWORD
     local  halfScreenWidth_l:DWORD
     local  halfScreenHeight_l:DWORD
     local  halfClientWidth_l:DWORD
     local  halfClientHeight_l:DWORD
     local  window_left_l:DWORD
     local  window_top_l:DWORD

     mov      eax, [client_rect_ptr]
     mov      [eax + RECT.left], 0
     mov      [eax + RECT.top], 0
     mov      ebx, [width]
     mov      [eax + RECT.right], ebx
     mov      ebx, [height]
     mov      [eax + RECT.bottom], ebx

     invoke   AdjustWindowRect, [client_rect_ptr], [window_styles], 1

     mov      eax, [client_rect_ptr]

     fild     [eax + RECT.right]
     fild     [eax + RECT.left]
     fsubp
     fistp    [eax + RECT.right]
     fild     [eax + RECT.bottom]
     fild     [eax + RECT.top]
     fsubp
     fistp    [eax + RECT.bottom]

     invoke   GetSystemMetrics, SM_CXSCREEN
     xor      edx, edx
     mov      ebx, 2
     div      ebx
     mov      [halfScreenWidth_l], eax

     invoke   GetSystemMetrics, SM_CYSCREEN
     xor      edx, edx
     mov      ebx, 2
     div      ebx
     mov      [halfScreenHeight_l], eax

     mov      eax, [client_rect_ptr]

     mov      eax, [eax + RECT.right]
     xor      edx, edx
     mov      ebx, 2
     div      ebx
     mov      [halfClientWidth_l], eax

     mov      eax, [client_rect_ptr]

     mov      eax, [eax + RECT.bottom]
     xor      edx, edx
     mov      ebx, 2
     div      ebx
     mov      [halfClientHeight_l], eax

     fild     [halfScreenWidth_l]
     fild     [halfClientWidth_l]
     fsubp
     fistp    [window_left_l]

     fild     [halfScreenHeight_l]
     fild     [halfClientHeight_l]
     fsubp
     fistp    [window_top_l]

     mov      eax, [client_rect_ptr]
     mov      ebx, [window_left_l]
     mov      [eax + RECT.left], ebx
     mov      ebx, [window_top_l]
     mov      [eax + RECT.top], ebx
     ret
endp

section '.idata' import data readable writeable

  library user32,'USER32.DLL',\
          kernel32,'KERNEL32.DLL',\
          gdi32,'GDI32.DLL',\
          msvcrt,'MSVCRT.DLL',\
          msimg32,'MSIMG32.DLL'

  import msimg32,\
         AlphaBlend, 'AlphaBlend'

  import user32,\
         ReleaseDC,'ReleaseDC',\
         GetCursorPos, 'GetCursorPos',\
         MessageBoxA,'MessageBoxA',\
         LoadCursorA,'LoadCursorA',\
         LoadIconA,'LoadIconA',\
         CreateWindowExA,'CreateWindowExA',\
         RegisterClassA,'RegisterClassA',\
         GetMessageA,'GetMessageA',\
         SendMessageA,'SendMessageA',\
         TranslateMessage,'TranslateMessage',\
         DispatchMessageA,'DispatchMessageA',\
         DefWindowProcA,'DefWindowProcA',\
         PostQuitMessage,'PostQuitMessage',\
         LoadImageA,'LoadImageA',\
         BeginPaint,'BeginPaint',\
         GetClientRect,'GetClientRect',\
         EndPaint,'EndPaint',\
         GetDC,'GetDC',\
         InvalidateRect,'InvalidateRect',\
         RedrawWindow,'RedrawWindow',\
         ScreenToClient,'ScreenToClient',\
         AdjustWindowRect,'AdjustWindowRect',\
         FillRect,'FillRect',\
         GetSystemMetrics,'GetSystemMetrics',\
         DialogBoxParamA,'DialogBoxParamA',\
         EndDialog,'EndDialog',\
         SetWindowPos,'SetWindowPos',\
         CheckRadioButton,'CheckRadioButton',\
         IsDlgButtonChecked,'IsDlgButtonChecked',\
         SetCapture,'SetCapture',\
         ReleaseCapture,'ReleaseCapture',\
         LoadMenuA,'LoadMenuA',\
         GetDlgItem,'GetDlgItem'

  import kernel32,\
         CreateThread,'CreateThread',\
         CloseHandle,'CloseHandle',\
         InitializeCriticalSection,'InitializeCriticalSection',\
         DeleteCriticalSection,'DeleteCriticalSection',\
         EnterCriticalSection,'EnterCriticalSection',\
         LeaveCriticalSection,'LeaveCriticalSection',\
         GetModuleHandleA,'GetModuleHandleA',\
         ExitProcess,'ExitProcess'

  import gdi32,\
         CreateSolidBrush,'CreateSolidBrush' ,\
         CreateCompatibleDC,'CreateCompatibleDC',\
         SelectObject,'SelectObject',\
         BitBlt,'BitBlt',\
         DeleteDC,'DeleteDC',\
         DeleteObject,'DeleteObject',\
         CreateCompatibleBitmap,'CreateCompatibleBitmap',\
         SaveDC,'SaveDC',\
         RestoreDC,'RestoreDC',\
         Rectangle,'Rectangle',\
         SetDIBitsToDevice,'SetDIBitsToDevice'

section '.rsrc' resource data readable

  directory RT_MENU,menus,\
            RT_ICON,icons,\
            RT_GROUP_ICON,group_icons,\
            RT_DIALOG,dialogs

  resource menus,\
           IDR_MENU,LANG_ENGLISH+SUBLANG_DEFAULT,main_menu

  resource icons,\
           1,LANG_NEUTRAL,icon_data

  resource group_icons,\
           IDR_ICON,LANG_NEUTRAL,main_icon

  resource dialogs,\
           37,LANG_ENGLISH+SUBLANG_DEFAULT,demonstration

  menu main_menu
       menuitem '&Options',0,MFR_POPUP
                menuitem '&Set Options',IDM_OPTIONS
                menuseparator
                menuitem '&Exit',IDM_EXIT,MFR_END
       menuitem '&Help',0,MFR_POPUP + MFR_END
                menuitem '&About...',IDM_ABOUT,MFR_END

  icon main_icon,icon_data,'letterm.ico'

  dialog demonstration,'Configuration',100,100,200,200, WS_CAPTION+WS_POPUP+WS_SYSMENU+DS_MODALFRAME
    dialogitem 'BUTTON','&Resolution',-1,10,5,80,70,WS_VISIBLE+BS_GROUPBOX
    dialogitem 'BUTTON','&Max. iterations',-1,100,5,80,70,WS_VISIBLE+BS_GROUPBOX
    dialogitem 'BUTTON','&Color palette',-1,190,5,80,70,WS_VISIBLE+BS_GROUPBOX

    dialogitem 'BUTTON','OK',IDOK,225,85,45,15,WS_VISIBLE+WS_TABSTOP+BS_DEFPUSHBUTTON

    dialogitem 'BUTTON','&1024 x 768',ID_RADIO1,20,22,60,13,WS_VISIBLE+WS_CHILD+BS_AUTORADIOBUTTON+WS_TABSTOP+WS_GROUP
    dialogitem 'BUTTON','&800 x 600',ID_RADIO2,20,35,60,13,WS_CHILD+WS_VISIBLE+BS_AUTORADIOBUTTON
    dialogitem 'BUTTON','&640 x 480',ID_RADIO3,20,48,60,13,WS_CHILD+WS_VISIBLE+BS_AUTORADIOBUTTON

    dialogitem 'BUTTON','&250',ID_RADIO4,110,22,60,13,WS_VISIBLE+WS_CHILD+BS_AUTORADIOBUTTON+WS_TABSTOP+WS_GROUP
    dialogitem 'BUTTON','&700',ID_RADIO5,110,35,60,13,WS_CHILD+WS_VISIBLE+BS_AUTORADIOBUTTON
    dialogitem 'BUTTON','&2000',ID_RADIO6,110,48,60,13,WS_CHILD+WS_VISIBLE+BS_AUTORADIOBUTTON

    dialogitem 'COMBOBOX', '', ID_LIST, 200,22,60,100,\
                WS_VISIBLE+CBS_DROPDOWNLIST+CBS_HASSTRINGS+WS_VSCROLL
  enddialog

;===========================================================
; LED_RamAddr		.equ	0200H
;===========================================================
F_FillScreen:
	lda		#$ff
	bra		L_FillLed
F_ClearScreen:
	lda		#0
L_FillLed:
	sta		$1800
	sta		$1801
	sta		$1802
	sta		$1803
	sta		$1804
	sta		$1805
	sta		$1806
	sta		$1807
	sta		$1808
	sta		$1809
	sta		$180a
	sta		$180b

	rts


;===========================================================
;@brief		显示完整的一个数字
;@para:		A = 0~9
;			X = offset	
;@impact:	P_Temp，P_Temp+1，P_Temp+2，P_Temp+3, X，A
;===========================================================
L_Dis_7Bit_DigitDot:
	stx		P_Temp+1					; 偏移量暂存进P_Temp+2, 腾出X来做变址寻址

	tax
	lda		Table_Digit_7bit,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	lda		#7
	sta		P_Temp+2					; 设置显示段数为7
L_Judge_Dis_7Bit_DigitDot:				; 显示循环的开始
	ldx		P_Temp+1					; 表头偏移量->X
	lda		Led_bit,x					; 查表定位目标段的bit位
	sta		P_Temp+3					; bit位->P_Temp+3
	lda		Led_byte,x					; 查表定位目标段的显存地址
	tax									; 显存地址偏移->X
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_7bit					; 当前段的值若是0则进清点子程序
	lda		LED_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+3					; 将COM和SEG信息与LED RAM地址进行逻辑或操作

	sta		LED_RamAddr,x
	bra		L_Inc_Dis_Index_Digit_7bit	; 跳转到显示索引增加的子程序。
L_CLR_7bit:	
	lda		LED_RamAddr,x				; 加载LED RAM的地址
	ora		P_Temp+3					; 先置1确定状态再异或翻转成0
	eor		P_Temp+3
	sta		LED_RamAddr,x				; 将结果写回LED RAM，清除对应位置。
L_Inc_Dis_Index_Digit_7bit:
	inc		P_Temp+1					; 递增偏移量，处理下一个段
	dec		P_Temp+2					; 递减剩余要显示的段数
	bne		L_Judge_Dis_7Bit_DigitDot	; 剩余段数为0则返回
	rts



; 用于显示星期的七段数显
L_Dis_7Bit_WeekDot:
	stx		P_Temp+1					; 偏移量暂存进P_Temp+1, 腾出X来做变址寻址

	ldx		R_Date_Week					; 取得当前星期数
	lda		Table_Week_7bit,x			; 将显示的星期通过查表找到对应的段码存进A
	bbr2	Calendar_Flag,Now_Week		; 若是需要反显，则显示按位取反值
	eor		#$7f
Now_Week:
	sta		P_Temp						; 暂存段码值到P_Temp

	lda		#7
	sta		P_Temp+2					; 设置显示段数为7
L_Judge_Dis_7Bit_WeekDot:				; 显示循环的开始
	ldx		P_Temp+1					; 取回偏移量作为索引
	lda		Led_bit,x					; 查表定位目标段的bit位
	sta		P_Temp+3
	lda		Led_byte,x					; 查表定位目标段的显存地址
	tax
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_7bit_Week				; 当前段的值若是0则进清点子程序
	lda		LED_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+3
	sta		LED_RamAddr,x
	bra		L_Inc_Dis_Index_Week_7bit	; 跳转到显示索引增加的子程序
L_CLR_7bit_Week:
	lda		LED_RamAddr,x				; 加载LCD RAM的地址
	ora		P_Temp+3					; 先将指定bit用或操作置1
	eor		P_Temp+3					; 然后异或操作翻转置0
	sta		LED_RamAddr,x				; 将结果写回LCD RAM，清除对应位置
L_Inc_Dis_Index_Week_7bit:
	inc		P_Temp+1					; 递增偏移量，处理下一个段
	dec		P_Temp+2					; 递减剩余要显示的段数
	bne		L_Judge_Dis_7Bit_WeekDot	; 剩余段数为0则返回
	rts




;===========================================================
;@brief		显示非数字字符
;@para:		A = 0~9
;			X = offset	
;@impact:	P_Temp，P_Temp+1，P_Temp+2，P_Temp+3, X，A
;===========================================================
L_Dis_7Bit_WordDot:
	stx		P_Temp+1					; 偏移量暂存进P_Temp+2, 腾出X来做变址寻址

	tax
	lda		Table_Word_7bit,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	lda		#7
	sta		P_Temp+2					; 设置显示段数为7
L_Judge_Dis_7Bit_WordDot:				; 显示循环的开始
	ldx		P_Temp+1					; 表头偏移量->X
	lda		Led_bit,x					; 查表定位目标段的bit位
	sta		P_Temp+3					; bit位->P_Temp+3
	lda		Led_byte,x					; 查表定位目标段的显存地址
	tax									; 显存地址偏移->X
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_7bit					; 当前段的值若是0则进清点子程序
	lda		LED_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+3					; 将COM和SEG信息与LED RAM地址进行逻辑或操作

	sta		LED_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_Word	; 跳转到显示索引增加的子程序。
L_CLR_Word_7bit:	
	lda		LED_RamAddr,x				; 加载LED RAM的地址
	ora		P_Temp+3					; 先置1确定状态再异或翻转成0
	eor		P_Temp+3
	sta		LED_RamAddr,x				; 将结果写回LED RAM，清除对应位置。
L_Inc_Dis_Index_Prog_Word:
	inc		P_Temp+1					; 递增偏移量，处理下一个段
	dec		P_Temp+2					; 递减剩余要显示的段数
	bne		L_Judge_Dis_7Bit_WordDot	; 剩余段数为0则返回
	rts



;===========================================================
;@brief		显示1或者不显示
;@para:		A = 0~1
;			X = offset	
;@impact:	X，A
;===========================================================
L_Dis_2Bit_DigitDot:
	bne		One_Digit
	ldx		#led_d4						; 零则不显示
	jsr		F_ClrSymbol
	ldx		#led_d4+1
	jsr		F_ClrSymbol
	rts
One_Digit:
	ldx		#led_d4						; 一则显示bc两段
	jsr		F_DisSymbol
	ldx		#led_d4+1
	jsr		F_DisSymbol
	rts



; 发送显存到5020
L_Send_DRAM:
	LE_SET_LOW							; 发送数据时需要LE拉低锁存5020当前数据
	ldx		#12

?Loop_Start:							; 拷贝显存准备进行显示
	dex
	php
	lda		LED_RamAddr,x				; 12byte的显存全部拷贝
	sta		LED_BakRamAddr,x
	plp
	bne		?Loop_Start

	lda		#12*8
	sta		P_Temp
L_Sending_Loop:							; 5020是MSB，使用左移先发送高位
	ldx		#0
	clc
	php
?Loop_ROL:
	plp
	rol		LED_BakRamAddr,x
	php									; 保存位移出来的C位
	inx
	cpx		#12
	bcc		?Loop_ROL					; 12byte的显存全部左移1位

	plp
	bcc		L_Send_0
	SDI_SET_HIGH						; 判断位移出来的C，1则输出高
	bra		L_CLK_Change
L_Send_0:
	SDI_SET_LOW							; 0则输出低
L_CLK_Change:
	CLK_SET_LOW							; CLK产生一次上升沿使得5020开始位移
	nop									; 延时6个指令周期确保IO口翻转完成
	nop
	nop
	CLK_SET_HIGH
	dec		P_Temp
	bne		L_Sending_Loop

	LE_SET_HIGH							; 5020取消锁存，接收新数据
	nop									; 延时6个指令周期确保IO口翻转完成
	nop
	nop
	LE_SET_LOW							; 锁存数据避免意外改变

	rts



;-----------------------------------------
;@brief:	单独的画点、清点函数,一般用于MS显示
;@para:		X = offset
;@impact:	A, X, P_Temp
;-----------------------------------------
F_DisSymbol:
	jsr		F_DisSymbol_Com
	sta		LED_RamAddr,x				; 画点
	rts

F_ClrSymbol:
	jsr		F_DisSymbol_Com				; 清点
	eor		P_Temp
	sta		LED_RamAddr,x
	rts

F_DisSymbol_Com:
	lda		Led_bit,x					; 查表得知目标段的bit位
	sta		P_Temp
	lda		Led_byte,x					; 查表得知目标段的地址
	tax
	lda		LED_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp
	rts


;============================================================
Table_Digit_7bit:
	.byte	$3f	; 0
	.byte	$06	; 1
	.byte	$5b	; 2
	.byte	$4f	; 3
	.byte	$66	; 4
	.byte	$6d	; 5
	.byte	$7d	; 6
	.byte	$07	; 7
	.byte	$7f	; 8
	.byte	$6f	; 9
	.byte	$00	; undisplay

Table_Word_7bit:
	.byte	$61 ; c 0
	.byte	$71	; F 1
	.byte	$5c	; o 2
	.byte	$37	; N 3
	.byte	$77	; A 4
	.byte	$5e	; d 5
	.byte	$73	; p 6
	.byte	$76	; H 7
	.byte	$50	; r 8
	.byte	$40	; - 9

Table_Week_7bit:
	.byte	$01	; SUN
	.byte	$02	; MON
	.byte	$04	; TUE
	.byte	$08	; WED
	.byte	$10	; THU
	.byte	$20	; FRI
	.byte	$40	; SAT
	.byte	$00	; undisplay


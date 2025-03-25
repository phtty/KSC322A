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
;@brief		��ʾ������һ������
;@para:		A = 0~9
;			X = offset	
;@impact:	P_Temp��P_Temp+1��P_Temp+2��P_Temp+3, X��A
;===========================================================
L_Dis_7Bit_DigitDot:
	stx		P_Temp+1					; ƫ�����ݴ��P_Temp+2, �ڳ�X������ַѰַ

	tax
	lda		Table_Digit_7bit,x			; ����ʾ������ͨ������ҵ���Ӧ�Ķ�����A
	sta		P_Temp						; �ݴ����ֵ��P_Temp

	lda		#7
	sta		P_Temp+2					; ������ʾ����Ϊ7
L_Judge_Dis_7Bit_DigitDot:				; ��ʾѭ���Ŀ�ʼ
	ldx		P_Temp+1					; ��ͷƫ����->X
	lda		Led_bit,x					; ���λĿ��ε�bitλ
	sta		P_Temp+3					; bitλ->P_Temp+3
	lda		Led_byte,x					; ���λĿ��ε��Դ��ַ
	tax									; �Դ��ַƫ��->X
	ror		P_Temp						; ѭ������ȡ��Ŀ�������������
	bcc		L_CLR_7bit					; ��ǰ�ε�ֵ����0�������ӳ���
	lda		LED_RamAddr,x				; ��Ŀ��ε��Դ���ض�bitλ��1������
	ora		P_Temp+3					; ��COM��SEG��Ϣ��LED RAM��ַ�����߼������

	sta		LED_RamAddr,x
	bra		L_Inc_Dis_Index_Digit_7bit	; ��ת����ʾ�������ӵ��ӳ���
L_CLR_7bit:	
	lda		LED_RamAddr,x				; ����LED RAM�ĵ�ַ
	ora		P_Temp+3					; ����1ȷ��״̬�����ת��0
	eor		P_Temp+3
	sta		LED_RamAddr,x				; �����д��LED RAM�������Ӧλ�á�
L_Inc_Dis_Index_Digit_7bit:
	inc		P_Temp+1					; ����ƫ������������һ����
	dec		P_Temp+2					; �ݼ�ʣ��Ҫ��ʾ�Ķ���
	bne		L_Judge_Dis_7Bit_DigitDot	; ʣ�����Ϊ0�򷵻�
	rts



; ������ʾ���ڵ��߶�����
L_Dis_7Bit_WeekDot:
	stx		P_Temp+1					; ƫ�����ݴ��P_Temp+1, �ڳ�X������ַѰַ

	ldx		R_Date_Week					; ȡ�õ�ǰ������
	lda		Table_Week_7bit,x			; ����ʾ������ͨ������ҵ���Ӧ�Ķ�����A
	bbr2	Calendar_Flag,Now_Week		; ������Ҫ���ԣ�����ʾ��λȡ��ֵ
	eor		#$7f
Now_Week:
	sta		P_Temp						; �ݴ����ֵ��P_Temp

	lda		#7
	sta		P_Temp+2					; ������ʾ����Ϊ7
L_Judge_Dis_7Bit_WeekDot:				; ��ʾѭ���Ŀ�ʼ
	ldx		P_Temp+1					; ȡ��ƫ������Ϊ����
	lda		Led_bit,x					; ���λĿ��ε�bitλ
	sta		P_Temp+3
	lda		Led_byte,x					; ���λĿ��ε��Դ��ַ
	tax
	ror		P_Temp						; ѭ������ȡ��Ŀ�������������
	bcc		L_CLR_7bit_Week				; ��ǰ�ε�ֵ����0�������ӳ���
	lda		LED_RamAddr,x				; ��Ŀ��ε��Դ���ض�bitλ��1������
	ora		P_Temp+3
	sta		LED_RamAddr,x
	bra		L_Inc_Dis_Index_Week_7bit	; ��ת����ʾ�������ӵ��ӳ���
L_CLR_7bit_Week:
	lda		LED_RamAddr,x				; ����LCD RAM�ĵ�ַ
	ora		P_Temp+3					; �Ƚ�ָ��bit�û������1
	eor		P_Temp+3					; Ȼ����������ת��0
	sta		LED_RamAddr,x				; �����д��LCD RAM�������Ӧλ��
L_Inc_Dis_Index_Week_7bit:
	inc		P_Temp+1					; ����ƫ������������һ����
	dec		P_Temp+2					; �ݼ�ʣ��Ҫ��ʾ�Ķ���
	bne		L_Judge_Dis_7Bit_WeekDot	; ʣ�����Ϊ0�򷵻�
	rts




;===========================================================
;@brief		��ʾ�������ַ�
;@para:		A = 0~9
;			X = offset	
;@impact:	P_Temp��P_Temp+1��P_Temp+2��P_Temp+3, X��A
;===========================================================
L_Dis_7Bit_WordDot:
	stx		P_Temp+1					; ƫ�����ݴ��P_Temp+2, �ڳ�X������ַѰַ

	tax
	lda		Table_Word_7bit,x			; ����ʾ������ͨ������ҵ���Ӧ�Ķ�����A
	sta		P_Temp						; �ݴ����ֵ��P_Temp

	lda		#7
	sta		P_Temp+2					; ������ʾ����Ϊ7
L_Judge_Dis_7Bit_WordDot:				; ��ʾѭ���Ŀ�ʼ
	ldx		P_Temp+1					; ��ͷƫ����->X
	lda		Led_bit,x					; ���λĿ��ε�bitλ
	sta		P_Temp+3					; bitλ->P_Temp+3
	lda		Led_byte,x					; ���λĿ��ε��Դ��ַ
	tax									; �Դ��ַƫ��->X
	ror		P_Temp						; ѭ������ȡ��Ŀ�������������
	bcc		L_CLR_7bit					; ��ǰ�ε�ֵ����0�������ӳ���
	lda		LED_RamAddr,x				; ��Ŀ��ε��Դ���ض�bitλ��1������
	ora		P_Temp+3					; ��COM��SEG��Ϣ��LED RAM��ַ�����߼������

	sta		LED_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_Word	; ��ת����ʾ�������ӵ��ӳ���
L_CLR_Word_7bit:	
	lda		LED_RamAddr,x				; ����LED RAM�ĵ�ַ
	ora		P_Temp+3					; ����1ȷ��״̬�����ת��0
	eor		P_Temp+3
	sta		LED_RamAddr,x				; �����д��LED RAM�������Ӧλ�á�
L_Inc_Dis_Index_Prog_Word:
	inc		P_Temp+1					; ����ƫ������������һ����
	dec		P_Temp+2					; �ݼ�ʣ��Ҫ��ʾ�Ķ���
	bne		L_Judge_Dis_7Bit_WordDot	; ʣ�����Ϊ0�򷵻�
	rts



;===========================================================
;@brief		��ʾ1���߲���ʾ
;@para:		A = 0~1
;			X = offset	
;@impact:	X��A
;===========================================================
L_Dis_2Bit_DigitDot:
	bne		One_Digit
	ldx		#led_d4						; ������ʾ
	jsr		F_ClrSymbol
	ldx		#led_d4+1
	jsr		F_ClrSymbol
	rts
One_Digit:
	ldx		#led_d4						; һ����ʾbc����
	jsr		F_DisSymbol
	ldx		#led_d4+1
	jsr		F_DisSymbol
	rts



; �����Դ浽5020
L_Send_DRAM:
	LE_SET_LOW							; ��������ʱ��ҪLE��������5020��ǰ����
	ldx		#12

?Loop_Start:							; �����Դ�׼��������ʾ
	dex
	php
	lda		LED_RamAddr,x				; 12byte���Դ�ȫ������
	sta		LED_BakRamAddr,x
	plp
	bne		?Loop_Start

	lda		#12*8
	sta		P_Temp
L_Sending_Loop:							; 5020��MSB��ʹ�������ȷ��͸�λ
	ldx		#0
	clc
	php
?Loop_ROL:
	plp
	rol		LED_BakRamAddr,x
	php									; ����λ�Ƴ�����Cλ
	inx
	cpx		#12
	bcc		?Loop_ROL					; 12byte���Դ�ȫ������1λ

	plp
	bcc		L_Send_0
	SDI_SET_HIGH						; �ж�λ�Ƴ�����C��1�������
	bra		L_CLK_Change
L_Send_0:
	SDI_SET_LOW							; 0�������
L_CLK_Change:
	CLK_SET_LOW							; CLK����һ��������ʹ��5020��ʼλ��
	nop									; ��ʱ6��ָ������ȷ��IO�ڷ�ת���
	nop
	nop
	CLK_SET_HIGH
	dec		P_Temp
	bne		L_Sending_Loop

	LE_SET_HIGH							; 5020ȡ�����棬����������
	nop									; ��ʱ6��ָ������ȷ��IO�ڷ�ת���
	nop
	nop
	LE_SET_LOW							; �������ݱ�������ı�

	rts



;-----------------------------------------
;@brief:	�����Ļ��㡢��㺯��,һ������MS��ʾ
;@para:		X = offset
;@impact:	A, X, P_Temp
;-----------------------------------------
F_DisSymbol:
	jsr		F_DisSymbol_Com
	sta		LED_RamAddr,x				; ����
	rts

F_ClrSymbol:
	jsr		F_DisSymbol_Com				; ���
	eor		P_Temp
	sta		LED_RamAddr,x
	rts

F_DisSymbol_Com:
	lda		Led_bit,x					; ����֪Ŀ��ε�bitλ
	sta		P_Temp
	lda		Led_byte,x					; ����֪Ŀ��εĵ�ַ
	tax
	lda		LED_RamAddr,x				; ��Ŀ��ε��Դ���ض�bitλ��1������
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


IR_ReceiveHandle:
	jsr		RepeatCode_Handle

	lda		IR_ReceivePhase
	clc
	rol
	tax
	lda		Receive_Phase_Table+1,x
	pha
	lda		Receive_Phase_Table,x
	pha
	rts										; ���ݵ�ǰ����׶Σ���ת����Ӧ�����봦����

Receive_Phase_Table:
	dw		IR_Receive_Phase_0-1
	dw		IR_Receive_Phase_1-1
	dw		IR_Receive_Phase_2-1
	dw		IR_Receive_Phase_3-1
	dw		IR_Receive_Phase_4-1
	dw		IR_Receive_Phase_5-1



; ����׶�0������ʱ���У��½��ص���ʱ��ʼ����
IR_Receive_Phase_0:
	lda		PD
	and		#$10
	beq		IR_Turn2Phase1
	rts
IR_Turn2Phase1:
	;lda		#$2c							; �����ã�PA4���
	;sta		PA
	lda		#1
	sta		IR_ReceivePhase					; �������׶�1
	smb3	IR_Flag							; IR��ʼ����

	lda		#0
	sta		IR_Counter						; ��ʼ������
	lda		#32
	sta		Code_Counter
	rts


; ����׶�1�����������/�ظ���ĵ�һ����ƽʱ���Ƿ�Ϸ�
IR_Receive_Phase_1:
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		IR_Counter
	cmp		#60
	bcc		Phase1_Abort					; ���磬��ֹ����
	lda		#80
	cmp		IR_Counter
	bcc		Phase1_Abort					; ���磬��ֹ����
	lda		#2
	sta		IR_ReceivePhase					; �������׶�2
	lda		#0
	sta		IR_Counter
	rts
Phase1_Abort:
;	bbs5	IR_Flag,?No_Mark				; �����ô���
;	smb0	IR_Test
;	lda		IR_Counter
;	sta		Counter_Bak
;	lda		Code_Counter
;	sta		Counter_Bak2
;?No_Mark:
	jmp		Receive_Abort


; ����׶�2�������������뻹���ظ���
IR_Receive_Phase_2:
	IR_FALLING_EDGE_JUGE
	bbs1	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		IR_Counter
	cmp		#30
	bcc		Phase2_NoGuid					; ���������磬�ж��Ƿ�Ϊ�ظ���
	lda		#38
	cmp		IR_Counter
	bcc		Phase2_Abort					; ���������磬��ֹ����
	lda		#3
	sta		IR_ReceivePhase					; �������׶�3
	lda		#0
	sta		IR_Counter
	rts
Phase2_NoGuid:
	lda		IR_Counter
	cmp		#14
	bcc		Phase2_Abort					; �ظ������磬��ֹ����
	lda		#22
	cmp		IR_Counter
	bcc		Phase2_Abort					; �ظ������磬��ֹ����
	lda		Repeat_Counter
	cmp		#19
	bcs		RepeatCounter_NoAdd
	inc		Repeat_Counter					; �յ��ظ�������ظ������������19��
RepeatCounter_NoAdd:
	;lda		#5
	;sta		Interval_Counter				; ˢ���ظ�������ʱ����
	lda		#5
	sta		IR_ReceivePhase					; ���յ��ظ��룬����Ҳ��ɹ�����λ�������Ӧ��Դ
	sta		IR_Counter
	lda		IR_Flag
	and		#%00110000
	sta		IR_Flag
	rts
Phase2_Abort:
;	bbs5	IR_Flag,?No_Mark				; �����ô���
;	smb1	IR_Test
;	lda		IR_Counter
;	sta		Counter_Bak
;	lda		Code_Counter
;	sta		Counter_Bak2
;?No_Mark:
	jmp		Receive_Abort


; ����׶�3�������Ԫ��һ����ƽʱ���Ƿ�Ϸ�
IR_Receive_Phase_3:
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		#7
	cmp		IR_Counter
	bcc		Phase3_Abort					; ���磬��ֹ����
	lda		#4
	sta		IR_ReceivePhase					; �������׶�4
	lda		#0
	sta		IR_Counter
	rts
Phase3_Abort:
;	bbs5	IR_Flag,?No_Mark				; ������
;	smb2	IR_Test
;	lda		IR_Counter
;	sta		Counter_Bak
;	lda		Code_Counter
;	sta		Counter_Bak2
;?No_Mark:
	jmp		Receive_Abort


; ����׶�4������0���1�룬����ӻ�������ͬʱ�жϽ����Ƿ����
IR_Receive_Phase_4:
	IR_FALLING_EDGE_JUGE
	bbs1	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		IR_Counter
	cmp		#2
	bcc		Phase4_No0Code					; ��0��
	lda		#7
	cmp		IR_Counter
	bcc		Phase4_No0Code
	clc										; ���0��
	jmp		Receive_AfterHandle				; ����1bit�ĺ���
Phase4_No0Code:
	lda		IR_Counter
	cmp		#9
	bcc		Phase4_Abort					; Ҳ��1�룬��ֹ����
	lda		#20
	cmp		IR_Counter
	bcc		Phase4_Abort					; Ҳ��1�룬��ֹ����
	sec										; ���1��
	jmp		Receive_AfterHandle				; ����1bit�ĺ���
Phase4_Abort:
;	bbs5	IR_Flag,?No_Mark				; �����ô���
;	smb3	IR_Test
;	lda		IR_Counter
;	sta		Counter_Bak
;	lda		Code_Counter
;	sta		Counter_Bak2
;?No_Mark:
	jmp		Receive_Abort


IR_Receive_Phase_5:							; ��ֹ��׶Σ������ڿ��еȴ��׶�������׶�1
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		#0
	sta		IR_ReceivePhase
	lda		#5
	sta		Interval_Counter
	rts


Receive_Abort:
	lda		#0
	sta		IR_ReceivePhase
	sta		IR_Counter						; ��ռ���
;	lda		#%00100000						; �����ô���
	sta		IR_Flag
L_Clr_CodeBuffer:
	lda		#0
	sta		ID_Code							; ��ս��뻺����
	sta		D_Code
	sta		IA_Code
	sta		A_Code
	sta		Repeat_Counter					; ÿ������ʧ�ܻ�ϵ����������ظ��룬����ظ����������
	rmb4	IR_Flag							; �ر��ظ�������ʱ��ʱ�ͼ�������
	rmb4	Timer_Switch
	rts


; ����1bit�ĺ���
Receive_AfterHandle:
	ror		ID_Code							; �����յ�����Ԫ���
	ror		D_Code
	ror		IA_Code
	ror		A_Code

	dec		Code_Counter
	beq		Receive_Complete				; ���ѽ���32���룬���������
	lda		#3
	sta		IR_ReceivePhase					; ����ص��׶�3��������һ����
	lda		#0
	sta		IR_Counter
	rts
Receive_Complete:
	lda		#5
	sta		IR_ReceivePhase					; ����׶�����Ϊ�׶�0
	sta		IR_Counter						; ��ռ���
	sta		Repeat_Counter					; ÿ������ɹ�Ҳ��ϵ����������ظ��룬����ظ����������
	lda		#%00010100						; ��λ��ر�־λ���򿪽����־λ
	sta		IR_Flag
	smb4	Timer_Switch					; ��32Hz�������أ���ʼ�����ظ��벢����
	rts




RepeatCode_Handle:
	bbr4	IR_Flag,?Handle_Exit			; Ҫͬʱ���ظ�������ʼ������32Hz��־�Ŵ���
	bbs4	Timer_Flag,RepeatCounter_Handle
?Handle_Exit:
	rts
RepeatCounter_Handle:
	rmb4	Timer_Flag
	dec		Interval_Counter				; �ظ����������ݼ�
	beq		Interval_Timeout				; ����0��Ϊ��ʱ
	lda		Repeat_Counter
	cmp		#19
	bcc		L_IR_NoLongPress				; �����յ�19���ظ����򴥷���������
	bbs5	IR_Flag,?Handle_Exit			; ��������ÿ�γ���ֻ��һ��
	smb5	IR_Flag							; �������ܴ�������������лᴦ����
	smb2	Timer_Switch					; ��4Hz��������
?Handle_Exit:
	rts
L_IR_NoLongPress:
	rmb5	IR_Flag							; �ظ������û��19����û�г�������
	rmb2	Timer_Switch					; �ر�4Hz��������
	rts
Interval_Timeout:
	rmb5	IR_Flag							; ��λ���������־
	jmp		L_Clr_CodeBuffer




; ��ѭ����������ʱ������ѭ�����øú�������
; ������ɻ�����ֹʱ�˳�ѭ��
IR_Receive_Loop:
	jsr		IR_ReceiveHandle				; �������
	;bbs4	IR_Flag,No_IR_Receiveing
	;lda		IR_Test
	;bne		No_IR_Receiveing				; �����ô���
	lda		IR_ReceivePhase
	beq		No_IR_Receiveing
	bra		IR_Receive_Loop					; ����ǰ���ս׶η�0����ѭ������ֱ������׶�����Ϊ0
No_IR_Receiveing:
	jsr		F_IR_Decode						; �������
	rts




; ������յ�NEC��ִ�ж�Ӧ�Ĺ��ܺ���
F_IR_Decode:
	bbr5	IR_Flag,L_No_LongPress
	bbr2	Timer_Flag,L_No_LongPress
	rmb2	Timer_Flag
	bra		IR_Decode_Start					; ���г�����־ʱ��4Hz��һ�ν������ִ�й���
L_No_LongPress:
	bbs2	IR_Flag,IR_Decode_Start
	rts
IR_Decode_Start:
	rmb2	IR_Flag							; ÿ��������ɺ�ֻ����1��
	lda		D_Code
	eor		ID_Code							; У�������룬��У��ʧ���򲻽��벢��ջ�����
	cmp		#$ff
	beq		IR_Code_CheckOK
	jsr		Receive_Abort
	rts

IR_Code_CheckOK:
	ldx		#0
Compare_DCode_Loop:
	lda		Table_IR_KeyCode,x
	cmp		D_Code
	beq		IR_KeyHandle					; �ȶԽ��յ�������ͱ�����ݣ�����Ӧ�İ�������
	inx
	cpx		#21
	bcc		Compare_DCode_Loop
	rts

; ��ת����Ӧ���ܺ���
IR_KeyHandle:
	jsr		L_ShutDown_Alarm				; ����ʱ�������֣���ر����ӣ�����ִ�а�������

	txa
	clc
	rol
	tax
	lda		IR_Func_JumpTable+1,x
	pha
	lda		IR_Func_JumpTable,x
	pha
	rts

IR_Func_JumpTable:
	dw		L_IR_Func_OnOff-1
	dw		L_IR_Func_12_24-1
	dw		L_IR_Func_Alarm-1
	dw		L_IR_Func_Inc-1
	dw		L_IR_Func_Set-1
	dw		L_IR_Func_Dec-1
	dw		L_IR_Func_LightStaue-1
	dw		L_IR_Func_OK-1
	dw		L_IR_Func_CF-1
	dw		L_IR_Func_TimerUp-1
	dw		L_IR_Func_TimerDown-1
	dw		L_IR_Func_0-1
	dw		L_IR_Func_1-1
	dw		L_IR_Func_2-1
	dw		L_IR_Func_3-1
	dw		L_IR_Func_4-1
	dw		L_IR_Func_5-1
	dw		L_IR_Func_6-1
	dw		L_IR_Func_7-1
	dw		L_IR_Func_8-1
	dw		L_IR_Func_9-1


L_IRCode_NoLongPress:						; �ǳ������ܼ�
	bbs5	IR_Flag,?No_LongPress
	rts
?No_LongPress:
	pla
	pla
	rts


L_ShutDown_Alarm:							; �����ر�����
	bbs2	Clock_Flag,?No_AlarmLouding
	rts
?No_AlarmLouding:
	jsr		L_CloseLoud						; �������
	pla
	pla
	rts



L_IR_Func_OnOff:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON
	rmb1	Backlight_Flag					; �ر�PWM���⿪�أ����ر�����LED
	LED_SET_HIGH
	rts


L_IR_Func_12_24:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%00011
	beq		IR_12_24_Exit					; ��ʾģʽ��Ч
	jmp		DM_SW_TimeMode					; ���ö�Ӧ���ܺ���
IR_12_24_Exit:
	rts


L_IR_Func_Alarm:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%01100
	beq		?No_SetMode
	jmp		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
?No_SetMode:
	bbs4	Sys_Status_Flag,IR_Alarm_Exit	; ��ʱģʽ��Ч
	jmp		SwitchState_AlarmDis			; ��ʾģʽ����������л�
IR_Alarm_Exit:
	rts


L_IR_Func_Inc:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; ֻ�е�һ���а�����
?LongPress_BeepOFF:
	bbr2	Sys_Status_Flag,?No_CS_Mode
	jmp		AddNum_CS						; ʱ��ģʽ����
?No_CS_Mode:
	bbr3	Sys_Status_Flag,?No_AS_Mode
	jmp		AddNum_AS						; ����ģʽ����
?No_AS_Mode:
	bbr4	Sys_Status_Flag,IR_Inc_Exit
	nop										; ��ʱģʽ�İ�������
IR_Inc_Exit:
	rts


L_IR_Func_Set:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������
	lda		Sys_Status_Flag
	and		#%00101							; ʱ��ģʽ�л�������ģʽ
	beq		?No_CS_Mode
	jmp		SwitchState_ClockSet
?No_CS_Mode:
	lda		Sys_Status_Flag
	and		#%01010							; ����ģʽ�л�������ģʽ
	beq		IR_Set_Exit
	jmp		SwitchState_AlarmSet
IR_Set_Exit:
	rts


L_IR_Func_Dec:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; ֻ�е�һ���а�����
?LongPress_BeepOFF:
	bbr2	Sys_Status_Flag,?No_CS_Mode
	jmp		SubNum_CS						; ʱ��ģʽ����
?No_CS_Mode:
	bbr3	Sys_Status_Flag,?No_AS_Mode
	jmp		SubNum_AS						; ����ģʽ����
?No_AS_Mode:
	bbr4	Sys_Status_Flag,IR_Dec_Exit
	nop										; ��ʱģʽ�İ�������
IR_Dec_Exit:
	rts


L_IR_Func_LightStaue:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	jsr		LightLevel_Change
	nop										; ���ȵȼ���ʾ
	rts


L_IR_Func_OK:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%01100
	beq		?No_SetMode
	jmp		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
?No_SetMode:
	bbr4	Sys_Status_Flag,IR_OK_Exit
	nop										; ��ʱģʽ��ʼ��ʱ����
IR_OK_Exit:
	rts


L_IR_Func_CF:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������
	jmp		TemperMode_Change


L_IR_Func_TimerUp:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; ֻ�е�һ���а�����
?LongPress_BeepOFF:

	nop										; ��������ʱģʽ�������˳���ʱ��

	rts


L_IR_Func_TimerDown:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; ֻ�е�һ���а�����
?LongPress_BeepOFF:

	nop										; ���뵹��ʱģʽ�������˳���ʱ��
	rts


L_IR_Func_0:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	nop										; ����ʱ����λ��Ϊ0

	rts


L_IR_Func_1:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	nop										; ����ʱ����λ��Ϊ1

	rts


L_IR_Func_2:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	nop										; ����ʱ����λ��Ϊ2

	rts


L_IR_Func_3:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	nop										; ����ʱ����λ��Ϊ3

	rts


L_IR_Func_4:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	nop										; ����ʱ����λ��Ϊ4

	rts


L_IR_Func_5:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	nop										; ����ʱ����λ��Ϊ5

	rts


L_IR_Func_6:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	nop										; ����ʱ����λ��Ϊ6

	rts


L_IR_Func_7:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	nop										; ����ʱ����λ��Ϊ7

	rts


L_IR_Func_8:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	nop										; ����ʱ����λ��Ϊ8

	rts


L_IR_Func_9:
	jsr		L_IRCode_NoLongPress			; �ð����޳�������
	jsr		L_KeyBeep_ON					; ������

	nop										; ����ʱ����λ��Ϊ9

	rts




;IR_Test_1:
;	bbs4	IR_Flag,Receive_Complete_1
;	rts
;Receive_Complete_1:
;	rmb4	IR_Flag
;
;	ldx		#led_Month
;	jsr		F_ClrSymbol
;	ldx		#led_Date
;	jsr		F_DisSymbol
;
;	lda		A_Code
;	jsr		L_A_DecToHex
;	pha
;	and		#$0f
;	ldx		#led_d1
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d0
;	jsr		L_Dis_7Bit_DigitDot
;
;	lda		IA_Code
;	jsr		L_A_DecToHex
;	pha
;	and		#$0f
;	ldx		#led_d3
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d2
;	jsr		L_Dis_7Bit_DigitDot
;
;	lda		D_Code
;	jsr		L_A_DecToHex
;	pha
;	and		#$0f
;	ldx		#led_d6
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d5
;	jsr		L_Dis_7Bit_DigitDot
;
;	lda		ID_Code
;	jsr		L_A_DecToHex
;	pha
;	and		#$0f
;	ldx		#led_d10
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d9
;	jsr		L_Dis_7Bit_DigitDot
;
;	jsr		L_Send_DRAM
;	rts


;IR_Test_2:
;	lda		IR_Test
;	bne		Receive_Abort_1
;	rts
;Receive_Abort_1:
;	ldx		#led_Month
;	jsr		F_DisSymbol
;
;	bbr0	IR_Test,NoPhase1
;	rmb0	IR_Test
;	ldx		#led_MON1
;	jsr		F_DisSymbol
;	ldx		#led_TUE1
;	jsr		F_ClrSymbol
;	ldx		#led_WED1
;	jsr		F_ClrSymbol
;	ldx		#led_THU1
;	jsr		F_ClrSymbol
;	bra		Juge_Over
;NoPhase1:
;	bbr1	IR_Test,NoPhase2
;	rmb1	IR_Test
;	ldx		#led_MON1
;	jsr		F_ClrSymbol
;	ldx		#led_TUE1
;	jsr		F_DisSymbol
;	ldx		#led_WED1
;	jsr		F_ClrSymbol
;	ldx		#led_THU1
;	jsr		F_ClrSymbol
;	bra		Juge_Over
;NoPhase2:
;	bbr2	IR_Test,NoPhase3
;	rmb2	IR_Test
;	ldx		#led_MON1
;	jsr		F_ClrSymbol
;	ldx		#led_TUE1
;	jsr		F_ClrSymbol
;	ldx		#led_WED1
;	jsr		F_DisSymbol
;	ldx		#led_THU1
;	jsr		F_ClrSymbol
;	bra		Juge_Over
;NoPhase3:
;	rmb3	IR_Test
;	ldx		#led_MON1
;	jsr		F_ClrSymbol
;	ldx		#led_TUE1
;	jsr		F_ClrSymbol
;	ldx		#led_WED1
;	jsr		F_ClrSymbol
;	ldx		#led_THU1
;	jsr		F_DisSymbol
;Juge_Over:
;
;	lda		Counter_Bak
;	jsr		L_A_DecToHex
;	pha
;	txa
;	ldx		#led_d0
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	pha
;	and		#$0f
;	ldx		#led_d2
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d1
;	jsr		L_Dis_7Bit_DigitDot
;
;	lda		#32
;	sec
;	sbc		Counter_Bak2
;	jsr		L_A_DecToHex
;	pha
;	and		#$0f
;	ldx		#led_d6
;	jsr		L_Dis_7Bit_DigitDot
;	pla
;	and		#$f0
;	jsr		L_LSR_4Bit
;	ldx		#led_d5
;	jsr		L_Dis_7Bit_DigitDot
;
;	jsr		L_Send_DRAM
;?Test_Over
;	rts

; ��������
F_KeyHandler:
	bbs2	Key_Flag,L_Key4Hz					; ��ӵ�����4Hzɨһ�Σ����ƿ��Ƶ��
	bbr1	Key_Flag,L_KeyScan					; �״ΰ�������
	rmb1	Key_Flag							; ��λ�״δ���
	jsr		L_KeyDelay
	lda		PA
	eor		#$3c								; �����Ƿ��߼��ģ���ָ���ļ�λ������ȡ��
	and		#$3c
	bne		L_KeyYes							; ����Ƿ��а�������
	jmp		L_KeyNoScanExit
L_KeyYes:
	rmb4	IER									; ����ȷ�������󣬹ر��жϱ����󴥷�
	sta		PA_IO_Backup
	bra		L_KeyHandle							; �״δ����������

L_Key4Hz:
	bbr2	Timer_Flag,L_KeyScanExit
	rmb2	Timer_Flag
L_KeyScan:										; ����������
	bbr0	Key_Flag,L_KeyNoScanExit			; û��ɨ����־��Ϊ�ް��������ˣ��ж��Ƿ�ȡ������RFC����

	bbr4	Timer_Flag,L_KeyScanExit			; û��ʼ���ʱ����16Hzɨ��
	rmb4	Timer_Flag
	lda		PA
	eor		#$3c								; �����Ƿ��߼��ģ���ָ���ļ�λ������ȡ��
	and		#$3c
	cmp		PA_IO_Backup						; ����⵽�а�����״̬�仯���˳�����жϲ�����
	beq		L_4_32Hz_Count
	;jsr		F_SpecialKey_Handle					; ������ֹʱ������һ�����ⰴ���Ĵ���
	bra		L_KeyExit
L_4_32Hz_Count:
	bbs2	Key_Flag,Counter_NoAdd				; �ڿ�Ӵ������ټ������Ӽ���
	inc		QuickAdd_Counter					; ������������ᵼ�²�������������
Counter_NoAdd:
	lda		QuickAdd_Counter
	cmp		#64
	bcs		L_QuikAdd
	rts											; ������ʱ��������2S���п��
L_QuikAdd:
	bbs2	Key_Flag,NoQuikAdd_Beep
NoQuikAdd_Beep:
	smb2	Key_Flag
	rmb2	Timer_Flag
	smb2	Timer_Switch						; ����4Hz��ʱ


L_KeyHandle:
	lda		PA
	eor		#$3c								; �����Ƿ��߼��ģ���ָ���ļ�λ������ȡ��
	and		#$3c
	cmp		#$04
	bne		No_KeySTrigger						; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeySTrigger						; S������
No_KeySTrigger:
	cmp		#$08
	bne		No_KeyUTrigger
	jmp		L_KeyUTrigger						; U������
No_KeyUTrigger:
	cmp		#$10
	bne		No_KeyDTrigger
	jmp		L_KeyDTrigger						; D������
No_KeyDTrigger:
	cmp		#$20
	bne		L_KeyExit
	jmp		L_KeyFTrigger						; F������

L_KeyExit:
	rmb4	Timer_Switch						; �ر�32Hz��4Hz��ʱ
	rmb2	Timer_Switch
	rmb0	Key_Flag							; ����ر�־λ
	rmb2	Key_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
	sta		SpecialKey_Flag
	rmb4	IFR									; ��λ��־λ,�����жϿ���ʱֱ�ӽ����жϷ���
	smb4	IER									; ����������������¿���PA���ж�
L_KeyScanExit:
	rts

L_KeyNoScanExit:								; û��ɨ����������ǿ���״̬����ʱ�ж��Ƿ�ȡ������RFC����
	bbs4	Key_Flag,L_KeyScanExit				; ������������ģʽ�£���ȡ������
	bbs2	Clock_Flag,L_KeyScanExit
	rmb1	RFC_Flag							; ȡ������RFC����						
	rts


F_SpecialKey_Handle:							; ���ⰴ���Ĵ���
	lda		SpecialKey_Flag
	bne		SpecialKey_Handle
	rts
SpecialKey_Handle:
	bbs2	Key_Flag,SpecialKey_NoBeep
	jsr		L_KeyBeep_ON
SpecialKey_NoBeep:
	bbs0	SpecialKey_Flag,L_KeyS_ShortHandle	; �̰������⹦�ܴ���
	bbs1	SpecialKey_Flag,L_KeyU_ShortHandle
	bbs2	SpecialKey_Flag,L_KeyD_ShortHandle
	bbs3	SpecialKey_Flag,L_KeyF_ShortHandle


L_KeyS_ShortHandle:

KeyS_ShortHandle_Exit:
	rts


L_KeyU_ShortHandle:

KeyU_ShortHandle_Exit:
	rts


L_KeyD_ShortHandle:
	rts


L_KeyF_ShortHandle:

No_SwitchState_AlarmSet:
	rts




; ������������������ÿ���������������Ӧ����
L_KeySTrigger:
	jsr		L_Universal_TriggerHandle			; ͨ�ð�������
	jsr		L_Key_ShutdownLoud					; ������������

	lda		Sys_Status_Flag
	and		#%00101								; ʱ��ģʽ�л�������ģʽ
	beq		?No_CS_Mode
	jsr		SwitchState_ClockSet
	jmp		L_KeyExit							; ִֻ��1�ΰ�������
?No_CS_Mode:
	lda		Sys_Status_Flag
	and		#%01010								; ����ģʽ�л�������ģʽ
	beq		L_KeySTrigger_Exit
	jsr		SwitchState_AlarmSet
L_KeySTrigger_Exit:
	jmp		L_KeyExit


L_KeyUTrigger:
	jsr		L_Universal_TriggerHandle			; ͨ�ð�������
	jsr		L_Key_ShutdownLoud					; ������������

	lda		Sys_Status_Flag
	and		#%10011
	beq		Status_NoDisMode_KeyU
	jsr		LightLevel_Change					; ��ʾģʽU�������л�
	jmp		L_KeyExit
Status_NoDisMode_KeyU:
	lda		Sys_Status_Flag
	cmp		#%00100
	bne		StatusCS_No_KeyU
	jmp		AddNum_CS							; ʱ��ģʽ����
StatusCS_No_KeyU:
	cmp		#%01000
	bne		L_KeyUTrigger_Exit
	jmp		AddNum_AS							; ����ģʽ����
L_KeyUTrigger_Exit:
	rts


L_KeyDTrigger:
	jsr		L_Universal_TriggerHandle			; ͨ�ð�������
	jsr		L_Key_ShutdownLoud					; ������������

	lda		Sys_Status_Flag
	and		#%00011
	beq		Status_NoDisMode_KeyD
	jsr		TemperMode_Change					; ��ʾģʽD���¶ȵ�λ�л�
	jmp		L_KeyExit
Status_NoDisMode_KeyD:
	lda		Sys_Status_Flag
	cmp		#%00100
	bne		StatusCS_No_KeyD
	jmp		SubNum_CS							; ʱ��ģʽ����
StatusCS_No_KeyD:
	cmp		#%01000
	bne		L_KeyDTrigger_Exit
	jmp		SubNum_AS							; ����ģʽ����
L_KeyDTrigger_Exit:
	rts


L_KeyFTrigger:
	jsr		L_Universal_TriggerHandle			; ͨ�ð�������
	jsr		L_Key_ShutdownLoud					; ������������

	lda		Sys_Status_Flag
	and		#%01100
	beq		?No_SetMode
	jsr		Return_CD_Mode						; ����ģʽ�᷵��ʱ��
	jmp		L_KeyExit
?No_SetMode:
	bbs4	Sys_Status_Flag,L_KeyFTrigger_Exit	; ��ʱģʽ��Ч
	jsr		SwitchState_AlarmDis				; ��ʾģʽ����������л�
L_KeyFTrigger_Exit
	jmp		L_KeyExit							; ���ʱ�����ظ�ִ�й��ܺ���





; �����������
L_Key_ShutdownLoud:
	bbr2	Clock_Flag,?No_AlarmLouding
	jsr		L_CloseLoud							; �������
	pla
	pla
	jmp		L_KeyExit
?No_AlarmLouding:
	rts


; ��������ͨ�ù��ܣ�������������GPIO״̬���ã�������Ļ
; ͬʱ������Ƿ���ڻ����¼�
L_Universal_TriggerHandle:
	lda		#0
	sta		Return_Counter						; ���÷���ʱ��ģʽ��ʱ

	bbr1	Backlight_Flag,KeyWakeUp_Event			; ����ʱϨ���������ᵼ������
	jsr		L_KeyBeep_ON
	rts
KeyWakeUp_Event:
	bbs4	Sys_Status_Flag,?Timekeep_Mode
	lda		#%00001
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal					; ��������Ϩ�����ص�ʱ����ʾģʽ
?Timekeep_Mode:
	REFLASH_DISPLAY
	smb1	Backlight_Flag
	pla
	pla
	jmp		L_KeyExit							; Ϩ�����ѵ��Ǵΰ�����û�а�������




L_KeyBeep_ON:
	lda		#%10								; ���ð�����ʾ������������
	sta		Beep_Serial
	smb4	Key_Flag							; ��λ������ʾ����־
	jsr		F_RFC_Abort							; �����ѹ���ȶ�����RFC�������
	smb3	Timer_Switch
	lda		#0
	sta		Counter_21Hz
	rts

;L_KeyBeep_OFF:
;	lda		#0									; ���������ʾ������������
;	sta		Beep_Serial
;	rmb4	Key_Flag							; ��λ������ʾ����־
;	rmb3	Timer_Switch
;	rts



L_KeyDelay:
	lda		#0
	sta		P_Temp
DelayLoop:
	inc		P_Temp
	bne		DelayLoop
	
	rts

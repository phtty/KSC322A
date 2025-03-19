; LED显示，没有COM切换，只有SEG线
.MACRO	db_c_s	com,seg
		.byte	com*0+seg/8
.ENDMACRO

.MACRO	db_c_y	com,seg
		.byte	1.shl.(seg-seg/8*8)
.ENDMACRO

Led_byte:							;段码<==>SEG/COM表
led_table1:
led_d0	equ	$-led_table1
	db_c_s	0,68	; 0a
	db_c_s	0,67	; 0b
	db_c_s	0,75	; 0c
	db_c_s	0,77	; 0d
	db_c_s	0,74	; 0e
	db_c_s	0,70	; 0f
	db_c_s	0,73	; 0g

led_d1	equ	$-led_table1
	db_c_s	0,65	; 1a
	db_c_s	0,64	; 1b
	db_c_s	0,79	; 1c
	db_c_s	0,78	; 1d
	db_c_s	0,76	; 1e
	db_c_s	0,66	; 1f
	db_c_s	0,71	; 1g

led_d2	equ	$-led_table1
	db_c_s	0,61	; 2a
	db_c_s	0,59	; 2b
	db_c_s	0,52	; 2c
	db_c_s	0,49	; 2d
	db_c_s	0,51	; 2e
	db_c_s	0,62	; 2f
	db_c_s	0,56	; 2g

led_d3	equ	$-led_table1
	db_c_s	0,60	; 3a
	db_c_s	0,57	; 3b
	db_c_s	0,54	; 3c
	db_c_s	0,50	; 3d
	db_c_s	0,53	; 3e
	db_c_s	0,58	; 3f
	db_c_s	0,55	; 3g

led_d4	equ	$-led_table1
	db_c_s	0,46	; 4b
	db_c_s	0,47	; 4c

led_d5	equ	$-led_table1
	db_c_s	0,44	; 5a
	db_c_s	0,43	; 5b
	db_c_s	0,39	; 5c
	db_c_s	0,38	; 5d
	db_c_s	0,41	; 5e
	db_c_s	0,45	; 5f
	db_c_s	0,42	; 5g

led_d6	equ	$-led_table1
	db_c_s	0,36	; 6a
	db_c_s	0,34	; 6b
	db_c_s	0,33	; 6c
	db_c_s	0,32	; 6d
	db_c_s	0,37	; 6e
	db_c_s	0,40	; 6f
	db_c_s	0,35	; 6g

led_d7	equ	$-led_table1
	db_c_s	0,28	; 7a
	db_c_s	0,26	; 7b
	db_c_s	0,25	; 7c
	db_c_s	0,24	; 7d
	db_c_s	0,30	; 7e
	db_c_s	0,29	; 7f
	db_c_s	0,27	; 7g

led_d8	equ	$-led_table1
	db_c_s	0,5		; 8b
	db_c_s	0,3		; 8c
led_minus	equ	$-led_table1
	db_c_s	0,2		; 8g

led_d9	equ	$-led_table1
	db_c_s	0,12	; 9a
	db_c_s	0,11	; 9b
	db_c_s	0,10	; 9c
	db_c_s	0,6		; 9d
	db_c_s	0,4		; 9e
	db_c_s	0,7		; 9f
	db_c_s	0,9		; 9g

led_d10	equ	$-led_table1
	db_c_s	0,16	; 10a
	db_c_s	0,19	; 10b
	db_c_s	0,18	; 10c
	db_c_s	0,17	; 10d
	db_c_s	0,14	; 10e
	db_c_s	0,13	; 10f
	db_c_s	0,15	; 10g


led_dot:
led_week1	equ	$-led_table1
led_SUN1	equ	$-led_table1
	db_c_s	0,s31	; SUN1
led_MON1	equ	$-led_table1
	db_c_s	0,s30	; MON1
led_TUE1	equ	$-led_table1
	db_c_s	0,s28	; TUE1
led_WED1	equ	$-led_table1
	db_c_s	0,s25	; WED1
led_THU1	equ	$-led_table1
	db_c_s	0,s22	; THU1
led_FRI1	equ	$-led_table1
	db_c_s	0,s19	; FRI1
led_SAT1	equ	$-led_table1
	db_c_s	0,s16	; SAT1

led_week2	equ	$-led_table1
led_SUN2	equ	$-led_table1
	db_c_s	0,s31	; SUN2
led_MON2	equ	$-led_table1
	db_c_s	0,s29	; MON2
led_TUE2	equ	$-led_table1
	db_c_s	0,s26	; TUE2
led_WED2	equ	$-led_table1
	db_c_s	0,s23	; WED2
led_THU2	equ	$-led_table1
	db_c_s	0,s21	; THU2
led_FRI2	equ	$-led_table1
	db_c_s	0,s18	; FRI2
led_SAT2	equ	$-led_table1
	db_c_s	0,s31	; SAT2


led_PM		equ	$-led_table1
	db_c_s	0,s29	; PM
led_AL1		equ	$-led_table1
	db_c_s	0,s29	; AL1
led_AL2		equ	$-led_table1
	db_c_s	0,s30	; AL2
led_AL3		equ	$-led_table1
	db_c_s	0,s30	; AL3
led_COL1	equ	$-led_table1
	db_c_s	0,s22	; COL1
led_COL2	equ	$-led_table1
	db_c_s	0,s22	; COL2
led_TMP		equ	$-led_table1
	db_c_s	0,s10	; TEMP
led_Per1	equ	$-led_table1
	db_c_s	0,s1	; Percent1
led_Per2	equ	$-led_table1
	db_c_s	0,s1	; Percent2

;==========================================================
;==========================================================

Led_bit:
	db_c_y	c0,s27	; 0a
	db_c_y	c1,s26	; 0b
	db_c_y	c2,s26	; 0c
	db_c_y	c2,s27	; 0d
	db_c_y	c2,s28	; 0e
	db_c_y	c1,s28	; 0f
	db_c_y	c1,s27	; 0g

	db_c_y	c0,s24	; 1a
	db_c_y	c1,s23	; 1b
	db_c_y	c2,s23	; 1c
	db_c_y	c2,s24	; 1d
	db_c_y	c2,s25	; 1e
	db_c_y	c1,s25	; 1f
	db_c_y	c1,s24	; 1g

	db_c_y	c0,s20	; 2a
	db_c_y	c1,s19	; 2b
	db_c_y	c2,s19	; 2c
	db_c_y	c2,s20	; 2d
	db_c_y	c2,s21	; 2e
	db_c_y	c1,s21	; 2f
	db_c_y	c1,s20	; 2g

	db_c_y	c0,s17	; 3a
	db_c_y	c1,s16	; 3b
	db_c_y	c2,s16	; 3c
	db_c_y	c2,s17	; 3d
	db_c_y	c2,s18	; 3e
	db_c_y	c1,s18	; 3f
	db_c_y	c1,s17	; 3g

	db_c_y	c0,s15	; 4b
	db_c_y	c2,s15	; 4c
	db_c_y	c1,s15	; 4g

	db_c_y	c0,s13	; 5a
	db_c_y	c0,s12	; 5b
	db_c_y	c2,s13	; 5c
	db_c_y	c2,s14	; 5d
	db_c_y	c1,s14	; 5e
	db_c_y	c0,s14	; 5f
	db_c_y	c1,s13	; 5g

	db_c_y	c0,s11	; 6a
	db_c_y	c1,s10	; 6b
	db_c_y	c2,s10	; 6c
	db_c_y	c2,s11	; 6d
	db_c_y	c2,s12	; 6e
	db_c_y	c1,s12	; 6f
	db_c_y	c1,s11	; 6g

	db_c_y	c1,s7	; 7a
	db_c_y	c2,s7	; 7b
	db_c_y	c2,s8	; 7c
	db_c_y	c2,s9	; 7d
	db_c_y	c1,s9	; 7e
	db_c_y	c0,s9	; 7f
	db_c_y	c1,s8	; 7g

	db_c_y	c0,s5	; 8a
	db_c_y	c0,s4	; 8b
	db_c_y	c2,s5	; 8c
	db_c_y	c2,s6	; 8d
	db_c_y	c1,s6	; 8e
	db_c_y	c0,s6	; 8f
	db_c_y	c1,s5	; 8g

	db_c_y	c0,s3	; 9a
	db_c_y	c1,s2	; 9b
	db_c_y	c2,s2	; 9c
	db_c_y	c2,s3	; 9d
	db_c_y	c2,s4	; 9e
	db_c_y	c1,s4	; 9f
	db_c_y	c1,s3	; 9g

	db_c_y	c2,s31	; SUN1
	db_c_y	c0,s30	; MON1
	db_c_y	c0,s28	; TUE1
	db_c_y	c0,s25	; WED1
	db_c_y	c0,s22	; THU1
	db_c_y	c0,s19	; FRI1
	db_c_y	c0,s16	; SAT1

	db_c_y	c0,s31	; SUN2
	db_c_y	c0,s29	; MON2
	db_c_y	c0,s26	; TUE2
	db_c_y	c0,s23	; WED2
	db_c_y	c0,s21	; THU2
	db_c_y	c0,s18	; FRI2
	db_c_y	c1,s31	; SAT2


	db_c_y	c1,s29	; PM
	db_c_y	c2,s29	; AL1
	db_c_y	c1,s30	; AL2
	db_c_y	c2,s30	; AL3
	db_c_y	c1,s22	; COL1
	db_c_y	c2,s22	; COL2
	db_c_y	c0,s10	; TEMP
	db_c_y	c1,s1	; Percent1
	db_c_y	c2,s1	; Percent2

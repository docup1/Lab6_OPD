; Определение констант
.equ F_CPU = 16000000    ; Частота процессора
.equ BTN_PIN = 3         ; Кнопка подключена к пину 3 (PD3)
.equ RELAY0_PIN = 9      ; Реле 0 подключено к пину 9 (PB1)
.equ RELAY1_PIN = 10     ; Реле 1 подключено к пину 10 (PB2)
.equ RELAY2_PIN = 11     ; Реле 2 подключено к пину 11 (PB3)
.equ RELAY3_PIN = 12     ; Реле 3 подключено к пину 12 (PB4)

; Определение регистров
.def btnState = r16      ; Регистр для состояния кнопки
.def iterator = r17      ; Регистр для итератора
.def btnTimerL = r18     ; Нижний байт таймера кнопки
.def btnTimerH = r19     ; Верхний байт таймера кнопки

.org 0x0000
    rjmp RESET

RESET:
    ; Настройка пинов
    ldi r16, 0b11111101  ; Установить PD3 как вход (с подтягивающим резистором)
    out DDRD, r16
    ldi r16, 0b00011110  ; Установить PB1, PB2, PB3, PB4 как выходы
    out DDRB, r16

    ; Инициализация переменных
    clr iterator
    clr btnTimerL
    clr btnTimerH

MAIN_LOOP:
    ; Считывание состояния кнопки
    sbic PIND, BTN_PIN    ; Пропустить, если кнопка не нажата
    rjmp BTN_NOT_PRESSED

    ; Проверка таймера дребезга
    lds r16, btnTimerL
    lds r17, btnTimerH
    ldi r18, 500 & 0xFF   ; Сравнение с 500 мс (предполагая F_CPU = 16МГц, делитель = 64)
    ldi r19, 500 >> 8
    cp r16, r18
    cpc r17, r19
    brlo BTN_NOT_PRESSED

    ; Переключение состояния реле
    ldi r16, 0b0001       ; Загрузка маски бита для текущего реле
    lsl r16
    add r16, iterator
    in r17, PORTB
    eor r17, r16
    out PORTB, r17

    ; Увеличение итератора
    inc iterator
    cpi iterator, 5
    brlo BTN_HANDLED

    ; Сброс реле, если iterator >= 5
    clr iterator
    ldi r16, 0b00001110   ; Сброс PB1, PB2, PB3, PB4
    out PORTB, r16

BTN_HANDLED:
    ; Обновление таймера дребезга
    ldi r16, 0
    sts btnTimerL, r16
    sts btnTimerH, r16

BTN_NOT_PRESSED:
    ; Обновление таймера (предполагается, что таймер уже настроен и запущен)
    lds r16, TCNT1L
    sts btnTimerL, r16
    lds r17, TCNT1H
    sts btnTimerH, r17

    rjmp MAIN_LOOP

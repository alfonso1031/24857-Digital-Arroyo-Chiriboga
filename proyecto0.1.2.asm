org 100h
.data
    notas         db 10 dup(0)      ; Array para almacenar notas
    suma          dw 0              ; Suma total de notas
    promedio      db 0              ; Promedio calculado
    max           db 0              ; Nota máxima
    min           db 20             ; Nota mínima
    contador      db 0              ; Contador de notas ingresadas
    
    msg_pedir     db 'Ingrese nota (0-20) para estudiante $'
    msg_num       db ' : $'
    msg_error     db 13,10,'Error: Nota debe estar entre 0 y 20!',13,10,'$'
    msg_prom      db 13,10,'Promedio: $'
    msg_max       db 13,10,'Maxima:  $'
    msg_min       db 13,10,'Minima:  $'
    salto_linea   db 13,10,'$'
    buffer        db 4, ?, 3 dup('$') ; Buffer para entrada

.code

    mov ax, @data
    mov ds, ax
    
    mov si, offset notas     ; SI apunta al array de notas
    
ingresar_notas:
    ; Mostrar mensaje "Ingrese nota..."
    mov dx, offset msg_pedir
    mov ah, 09h
    int 21h
    
    ; Mostrar número de estudiante (1-10)
    mov al, contador
    add al, '1'
    mov dl, al
    mov ah, 02h
    int 21h
    
    mov dx, offset msg_num
    mov ah, 09h
    int 21h
    
    ; Leer entrada del usuario
    mov dx, offset buffer
    mov ah, 0Ah
    int 21h
    
    ; Validar entrada
    call validar_nota
    cmp al, 0FFh           ; AL=FFh si hubo error
    je error
    
    ; Guardar nota válida
    mov [si], al
    inc si
    
    ; Actualizar suma (CORREGIDO: limpiar AH antes de sumar)
    xor ah, ah             ; Limpiar AH (AX = AL)
    add suma, ax           ; Sumar a total
    
    ; Actualizar min/max
    call actualizar_minmax
    
    ; Incrementar contador
    inc contador
    
    ; Salto de línea después de nota válida (CORRECCIÓN SOLICITADA)
    mov dx, offset salto_linea
    mov ah, 09h
    int 21h
    
    ; Verificar si se han ingresado 10 notas
    cmp contador, 10
    jb ingresar_notas
    
    ; Calcular promedio
    call calcular_promedio
    
    ; Mostrar resultados
    call mostrar_resultados
    
    ; Salir
    mov ax, 4C00h
    int 21h
    
error:
    mov dx, offset msg_error
    mov ah, 09h
    int 21h
    jmp ingresar_notas

; =============================================
; VALIDAR_NOTA - Convierte y valida la entrada
; Salida: AL = Nota (0-20) o FFh si error
; =============================================
validar_nota proc
    mov al, buffer[1]      ; Longitud de la entrada
    cmp al, 0
    je invalido            ; Si no se ingresó nada
    cmp al, 2
    ja invalido            ; Si tiene más de 2 dígitos
    
    mov bx, offset buffer+2
    mov al, [bx]
    sub al, '0'            ; Convertir primer dígito
    cmp al, 0
    jl invalido
    cmp al, 9
    jg invalido
    
    ; Verificar si es de un solo dígito
    cmp buffer[1], 1
    je validar_rango
    
    ; Procesar segundo dígito
    inc bx
    mov ah, [bx]
    sub ah, '0'
    cmp ah, 0
    jl invalido
    cmp ah, 9
    jg invalido
    
    ; Combinar dígitos (AL*10 + AH)
    mov dl, 10
    mul dl
    add al, ah
    
validar_rango:
    cmp al, 20
    jg invalido
    ret
    
invalido:
    mov al, 0FFh
    ret
validar_nota endp

; =============================================
; ACTUALIZAR_MINMAX - Actualiza min y max
; Entrada: AL = Nueva nota
; =============================================
actualizar_minmax proc
    ; Actualizar máximo
    cmp al, max
    jle check_min
    mov max, al
    
check_min:
    ; Actualizar mínimo
    cmp al, min
    jge fin_minmax
    mov min, al
    
fin_minmax:
    ret
actualizar_minmax endp

; =============================================
; CALCULAR_PROMEDIO - Calcula el promedio (CORREGIDO)
; =============================================
calcular_promedio proc
    mov ax, suma      ; Cargar suma total en AX
    mov bl, 10        ; 10 estudiantes
    div bl            ; AL = AX / 10 (cociente)
    mov promedio, al  ; Guardar promedio
    ret
calcular_promedio endp

; =============================================
; MOSTRAR_NUMERO - Muestra un número (0-99)
; Entrada: AL = Número a mostrar
; =============================================
mostrar_numero proc
    aam                ; Convierte a dígitos (AH=decenas, AL=unidades)
    mov bx, ax
    mov dl, bh
    cmp dl, 0
    je mostrar_unidad  ; Saltar si no hay decenas
    
    add dl, '0'
    mov ah, 02h
    int 21h
    
mostrar_unidad:
    mov dl, bl
    add dl, '0'
    mov ah, 02h
    int 21h
    ret
mostrar_numero endp

; =============================================
; MOSTRAR_RESULTADOS - Muestra todas las stats
; =============================================
mostrar_resultados proc
    ; Mostrar promedio
    mov dx, offset msg_prom
    mov ah, 09h
    int 21h
    mov al, promedio
    call mostrar_numero
    
    ; Mostrar nota máxima
    mov dx, offset msg_max
    mov ah, 09h
    int 21h
    mov al, max
    call mostrar_numero
    
    ; Mostrar nota mínima
    mov dx, offset msg_min
    mov ah, 09h
    int 21h
    mov al, min
    call mostrar_numero
    
    ; Salto de línea final
    mov dx, offset salto_linea
    mov ah, 09h
    int 21h
    ret
mostrar_resultados endp

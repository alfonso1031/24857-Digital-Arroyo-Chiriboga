org 100h
    jmp start

    ; Variables y mensajes
    notas         db 10 dup(0)
    suma          dw 0
    promedio_entero   db 0
    promedio_decimal  db 0
    max           db 0
    min           db 20
    contador      db 0
    msg_pedir     db 'Ingrese nota (0-20) para estudiante $'
    msg_num       db ' : $'
    msg_error     db 13,10,'Error: Nota debe estar entre 0 y 20!',13,10,'$'
    msg_notas     db 13,10,'Notas ingresadas: $'
    msg_prom      db 13,10,'Promedio: $'
    msg_comma     db ',$'        ; Coma para decimales
    msg_max       db 13,10,'Maxima:  $'
    msg_min       db 13,10,'Minima:  $'
    salto_linea   db 13,10,'$'
    espacio       db ' $'         ; Espacio para separar notas
    buffer        db 4, ?, 3 dup('$')

start:
    push cs
    pop  ds
    mov si, offset notas

ingresar_notas:
    ; Mostrar mensaje
    mov dx, offset msg_pedir
    mov ah, 09h
    int 21h
    
    ; Mostrar número de estudiante (1-10)
    mov al, contador
    inc al                   ; AL = número de estudiante (1-10)
    
    ; Manejar números de 1-9 vs 10
    cmp al, 10
    je mostrar_10            ; Saltar si es el estudiante 10
    
    ; Mostrar número de 1 dígito
    add al, '0'              ; Convertir a carácter
    mov dl, al
    mov ah, 02h
    int 21h
    jmp mostrar_dospuntos
    
mostrar_10:
    ; Mostrar "10"
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '0'
    int 21h
    
mostrar_dospuntos:
    mov dx, offset msg_num
    mov ah, 09h
    int 21h
    
    ; Leer entrada
    mov dx, offset buffer
    mov ah, 0Ah
    int 21h
    
    ; Validar entrada
    call validar_nota
    cmp al, 0FFh
    je error
    
    ; Guardar nota válida
    mov [si], al
    inc si
    xor ah, ah
    add suma, ax
    call actualizar_minmax
    inc contador
    
    ; Salto de línea
    mov dx, offset salto_linea
    mov ah, 09h
    int 21h
    
    cmp contador, 10
    jb ingresar_notas
    
    ; Mostrar todas las notas ingresadas
    call mostrar_todas_notas
    
    ; Calcular y mostrar estadísticas
    call calcular_promedio
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
; VALIDAR_NOTA
; =============================================
validar_nota:
    mov cl, buffer[1]      ; Longitud de entrada
    cmp cl, 0
    je invalido
    cmp cl, 2
    ja invalido
    
    mov bx, offset buffer+2
    mov al, [bx]            ; Primer carácter
    sub al, '0'             ; Convertir a número
    cmp al, 0
    jl invalido
    cmp al, 9
    jg invalido
    
    ; Si es un solo dígito
    cmp cl, 1
    je validar_rango        ; Saltar si solo un dígito
    
    ; Guardar primer dígito en DL
    mov dl, al
    
    ; Procesar segundo dígito
    inc bx
    mov al, [bx]            ; Segundo carácter
    sub al, '0'
    cmp al, 0
    jl invalido
    cmp al, 9
    jg invalido
    
    ; Combinar dígitos (DL*10 + AL)
    xchg al, dl             ; Intercambiar AL y DL
    mov ah, 10
    mul ah                  ; AX = AL * 10
    add al, dl             ; AL = (primer dígito * 10) + segundo dígito
    
validar_rango:
    cmp al, 20
    ja invalido
    ret
    
invalido:
    mov al, 0FFh
    ret

; =============================================
; ACTUALIZAR_MINMAX
; =============================================
actualizar_minmax:
    cmp al, max
    jle check_min
    mov max, al
check_min:
    cmp al, min
    jge fin_minmax
    mov min, al
fin_minmax:
    ret

; =============================================
; CALCULAR_PROMEDIO - Ahora calcula decimales
; =============================================
calcular_promedio:
    mov ax, suma          ; Cargar suma total
    mov bx, 10            ; 10 estudiantes
    
    ; Calcular promedio con decimales
    xor dx, dx            ; Limpiar DX para división
    div bx                ; AX = cociente (parte entera), DX = residuo (parte decimal)
    
    mov promedio_entero, al  ; Guardar parte entera
    
    ; Calcular primer decimal: (residuo * 10) / 10
    mov ax, dx            ; Mover residuo a AX
    mov bx, 10
    mul bx                ; AX = residuo * 10
    div bx                ; AL = (residuo * 10) / 10 (primer decimal)
    mov promedio_decimal, al ; Guardar parte decimal
    
    ret

; =============================================
; MOSTRAR_NUMERO
; =============================================
mostrar_numero:
    aam
    mov bx, ax
    mov dl, bh
    cmp dl, 0
    je mostrar_unidad
    add dl, '0'
    mov ah, 02h
    int 21h
mostrar_unidad:
    mov dl, bl
    add dl, '0'
    mov ah, 02h
    int 21h
    ret

; =============================================
; MOSTRAR_DECIMAL - Muestra un solo dígito decimal
; Entrada: AL = Dígito decimal (0-9)
; =============================================
mostrar_decimal:
    add al, '0'          ; Convertir a carácter
    mov dl, al
    mov ah, 02h
    int 21h
    ret

; =============================================
; MOSTRAR_RESULTADOS - Ahora muestra decimales
; =============================================
mostrar_resultados:
    ; Mostrar promedio
    mov dx, offset msg_prom
    mov ah, 09h
    int 21h
    
    ; Mostrar parte entera del promedio
    mov al, promedio_entero
    call mostrar_numero
    
    ; Mostrar coma decimal
    mov dx, offset msg_comma
    mov ah, 09h
    int 21h
    
    ; Mostrar parte decimal del promedio
    mov al, promedio_decimal
    call mostrar_decimal
    
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

; =============================================
; MOSTRAR_TODAS_NOTAS
; =============================================
mostrar_todas_notas:
    ; Mostrar encabezado
    mov dx, offset msg_notas
    mov ah, 09h
    int 21h
    
    ; Configurar para recorrer notas
    mov cx, 10             ; 10 notas
    mov si, offset notas   ; Puntero al array

mostrar_nota_loop:
    ; Cargar nota
    mov al, [si]
    inc si
    
    ; Mostrar número
    push cx                ; Guardar contador
    push si                ; Guardar puntero
    call mostrar_numero
    
    ; Mostrar espacio (excepto después de la última nota)
    pop si                 ; Recuperar puntero
    pop cx                 ; Recuperar contador
    cmp cx, 1
    je no_espacio          ; Si es la última, no mostrar espacio
    
    mov dx, offset espacio
    mov ah, 09h
    int 21h
    
no_espacio:
    loop mostrar_nota_loop
    
    ; Salto de línea después de mostrar todas las notas
    mov dx, offset salto_linea
    mov ah, 09h
    int 21h
    ret
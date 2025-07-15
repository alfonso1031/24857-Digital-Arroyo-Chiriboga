org 100h

inicio:
    mov dx, offset msg_inicio
    mov ah, 9
    int 21h
    call nueva_linea
    mov dx, offset msg_num_students
    mov ah, 9
    int 21h
    call leer_numero
    mov bl, al
    cmp bl, 1
    jb error_num
    cmp bl, 10
    ja error_num
    mov num_students, bl
    ; Reset variables for new run
    mov si, 0
    mov cx, 10
reset_notas:
    mov notas[si], 0
    inc si
    loop reset_notas
    mov word ptr suma, 0
    mov nota_max, 0
    mov nota_min, 20
    mov byte ptr contador, 0
    jmp ingresar_notas

error_num:
    mov dx, offset msg_error_num
    mov ah, 9
    int 21h
    call nueva_linea
    jmp inicio

ingresar_notas:
    mov cl, num_students
    mov si, 0
    mov byte ptr contador, 0

bucle_estudiantes:
    mov dx, offset msg_grade
    mov ah, 9
    int 21h
    mov al, contador
    inc al
    call imprimir_num_estudiante
    mov dx, offset msg_colon
    mov ah, 9
    int 21h

leer_nota:
    call leer_numero
    mov bl, al
    cmp bl, 20
    ja error_nota
    mov notas[si], bl
    mov ax, 0
    mov al, bl
    add suma, ax
    cmp bl, nota_max
    jbe no_max
    mov nota_max, bl
no_max:
    cmp bl, nota_min
    jae no_min
    mov nota_min, bl
no_min:
    inc si
    inc contador
    dec cl
    jnz bucle_estudiantes
    jmp mostrar_menu

error_nota:
    mov dx, offset msg_error_nota
    mov ah, 9
    int 21h
    call nueva_linea
    jmp leer_nota

mostrar_menu:
    call nueva_linea
    mov dx, offset msg_menu
    mov ah, 9
    int 21h
    mov ah, 1
    int 21h
    sub al, '0'
    cmp al, 1
    je opcion_estadisticas
    cmp al, 2
    je opcion_mostrar_notas
    cmp al, 3
    je reiniciar
    cmp al, 4
    je salir
    mov dx, offset msg_error_opcion
    mov ah, 9
    int 21h
    call nueva_linea
    jmp mostrar_menu

opcion_estadisticas:
    call nueva_linea
    mov dx, offset msg_promedio
    mov ah, 9
    int 21h
    mov ax, suma
    mov bl, num_students
    xor dx, dx
    div bl
    mov cociente, al
    mov residuo, ah
    mov al, cociente
    call imprimir_dos_digitos
    mov dl, '.'
    mov ah, 2
    int 21h
    mov al, residuo
    mov ah, 0
    mov bl, 10
    mul bl
    div num_students
    mov bl, al
    cmp bl, 10
    jae decimal_cero
    add bl, '0'
    mov dl, bl
    mov ah, 2
    int 21h
    jmp fin_decimal
decimal_cero:
    mov dl, '0'
    mov ah, 2
    int 21h
fin_decimal:
    call nueva_linea
    mov dx, offset msg_max
    mov ah, 9
    int 21h
    mov al, nota_max
    call imprimir_dos_digitos
    call nueva_linea
    mov dx, offset msg_min
    mov ah, 9
    int 21h
    mov al, nota_min
    call imprimir_dos_digitos
    call nueva_linea
    jmp mostrar_menu

opcion_mostrar_notas:
    call nueva_linea
    mov dx, offset msg_lista_notas
    mov ah, 9
    int 21h
    mov cl, num_students
    mov si, 0
    mov byte ptr contador, 0

bucle_mostrar_notas:
    mov dx, offset msg_estudiantes
    mov ah, 9
    int 21h
    mov al, contador
    inc al
    call imprimir_num_estudiante
    mov dx, offset msg_colon
    mov ah, 9
    int 21h
    mov al, notas[si]
    call imprimir_dos_digitos
    call nueva_linea
    inc si
    inc contador
    dec cl
    jnz bucle_mostrar_notas
    jmp mostrar_menu

reiniciar:
    jmp inicio

salir:
    mov ah, 4Ch
    int 21h

leer_numero PROC
    mov ah, 1
    int 21h
    sub al, '0'
    mov bl, al
    mov ah, 1
    int 21h
    sub al, '0'
    mov bh, al
    mov al, bl
    mov bl, 10
    mul bl
    add al, bh
    ret
leer_numero ENDP

imprimir_dos_digitos PROC
    mov ah, 0
    mov bl, 10
    div bl
    add al, '0'
    add ah, '0'
    push ax
    mov dl, al
    mov ah, 2
    int 21h
    pop ax
    mov dl, ah
    mov ah, 2
    int 21h
    ret
imprimir_dos_digitos ENDP

imprimir_num_estudiante PROC
    cmp al, 10
    je mostrar_10
    add al, '0'
    mov dl, al
    mov ah, 2
    int 21h
    ret
mostrar_10:
    mov dl, '1'
    mov ah, 2
    int 21h
    mov dl, '0'
    int 21h
    ret
imprimir_num_estudiante ENDP

nueva_linea PROC
    mov dl, 0Dh
    mov ah, 2
    int 21h
    mov dl, 0Ah
    int 21h
    ret
nueva_linea ENDP

num_students db 0
contador db 0
notas db 10 dup(0)
suma dw 0
nota_max db 0
nota_min db 20
cociente db 0
residuo db 0
msg_inicio db 13,10, "======== Bienvenidos al Sistema de Ingreso y calculo de notas ======== $"
msg_num_students db 13,10, "Ingrese el numero de estudiantes (1-10): $"
msg_grade db 13,10, "Ingrese la nota del estudiante $"
msg_estudiantes db "Estudiante $"
msg_colon db ": $"
msg_error_num db 13,10, "El numero debe estar entre 1-10$"
msg_error_nota db 13,10, "La nota debe estar entre 0 y 20$"
msg_promedio db "Promedio: $"
msg_max db "Nota mas alta: $"
msg_min db "Nota mas baja: $"
msg_menu db 13,10, "Menu:", 13,10, "1. Mostrar estadisticas", 13,10, "2. Mostrar notas", 13,10, "3. Reiniciar", 13,10, "4. Salir", 13,10, "Seleccione una opcion (1-4): $"
msg_error_opcion db 13,10, "Opcion invalida, seleccione 1, 2, 3 o 4$"
msg_lista_notas db 13,10, "Lista de notas:", 13,10, "$"
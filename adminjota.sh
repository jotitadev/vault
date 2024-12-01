#!/bin/bash

# Verificar si el usuario "jota" existe
if id "jota" &>/dev/null; then
    echo "El usuario 'jota' ya existe."
else
    echo "El usuario 'jota' no existe, creando el usuario..."
    sudo useradd -m jota
    sudo passwd jota
fi

# Agregar el usuario "jota" al grupo "sudo"
echo "Agregando al usuario 'jota' al grupo sudo..."
sudo usermod -aG sudo jota

# Configuración de sudoers para que no pida contraseña
echo "Configurando sudo para no requerir contraseña para el usuario 'jota'..."

# Modificar el archivo sudoers
echo "jota ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/jota

# Verificar si la configuración fue exitosa
if sudo -l -U jota | grep -q "NOPASSWD"; then
    echo "Configuración completada. El usuario 'jota' ahora es administrador sin pedir contraseña."
else
    echo "Hubo un problema configurando sudo para 'jota'."
fi
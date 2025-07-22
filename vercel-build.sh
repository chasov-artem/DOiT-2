#!/bin/bash
set -e

# Встановлюємо Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Перевіряємо версію
flutter --version

# Збираємо web
flutter build web 
# Bitácora Sísmica CEET (P1)

Proyecto móvil full-stack con Flutter, Node.js y Sensores del dispositivo.

## 📥 Evidencias del Proyecto

Para la evaluación y sustentación del proyecto, las evidencias solicitadas se encuentran en los siguientes enlaces:

1. **[Descargar APK (Android)](evidencias/BitacoraSismicaCEET-debug-arm64.apk)** 📱
   *Haz clic en el enlace para descargar el APK de la aplicación e instalarla en tu dispositivo físico.*
2. **[Documento de Decisiones Técnicas (Umbrales)](docs/decisiones.md)** 📄
   *Justificación de los tiempos de reposo y la magnitud mínima de detección.*
3. **[Migraciones de Base de Datos](api/prisma/migrations/init.sql)** 💾

---

## 🛠️ Tecnologías Utilizadas

- **Frontend:** Flutter + Riverpod (Provider)
- **Backend:** Node.js + Express
- **Persistencia Local:** `sqflite` (SQLite)
- **Sensores:** Acelerómetro, Geolocalización, Motor de Vibración

## 🚀 Cómo ejecutar localmente

### 1. Backend (API)
```bash
cd api
npm install
node index.js
```

### 2. Frontend (App Móvil)
Asegúrate de cambiar la IP en el archivo `app/.env` a la IP de tu computadora en la red Wi-Fi local antes de correr la aplicación en un dispositivo físico.

```bash
cd app
flutter run
```

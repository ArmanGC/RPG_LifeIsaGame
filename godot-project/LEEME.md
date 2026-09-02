# Tablero de Misiones — proyecto de Godot

Un mapa 2D donde caminas con tu personaje entre tus proyectos ("misiones"),
ganas XP al completar tareas, subes de nivel, y puedes crear/editar/eliminar
misiones y objetivos en cualquier momento (para cuando un cliente cambie el
alcance).

## 1. Instalar Godot (una sola vez)

1. Entra a **godotengine.org/download** y descarga **Godot 4** (versión
   estándar, no la de ".NET" — no la necesitas para esto).
2. Es un solo archivo ejecutable, no requiere instalación tradicional:
   en Windows descomprime el .zip y abre el .exe; en Mac arrastra la app
   a Aplicaciones; en Linux dale permisos de ejecución y ábrelo.

## 2. Abrir este proyecto

1. Abre Godot. Verás el "Gestor de proyectos".
2. Click en **Importar**.
3. Navega hasta esta carpeta (`godot-project`) y selecciona el archivo
   `project.godot`.
4. Click en **Importar y Editar**. Se abrirá el editor con el proyecto cargado.
5. Arriba a la derecha, presiona el botón de **Play** (▶) o la tecla **F5**
   para ejecutar el juego.

## 3. Controles

| Tecla | Acción |
|---|---|
| Flechas del teclado | Mover al personaje |
| Espacio / Enter | Interactuar con una misión cercana (abre el panel) |
| N | Crear una misión nueva en tu posición actual |
| Esc | Cerrar el panel de misión |

## 4. Cómo funciona

- Cada misión es un rombo de color en el mapa: **dorado** = en curso,
  **verde** = completada, **gris** = en pausa.
- Acércate a un rombo y presiona **Espacio** para abrir su panel: ahí
  puedes cambiar el título, cliente, fecha límite, dificultad, estado,
  y agregar, renombrar, marcar o eliminar objetivos.
- Cada objetivo completado te da **+10 XP**. Al llenar la barra de
  experiencia subes de nivel (verás un aviso en pantalla).
- La estrella junto a cada objetivo lo marca como "prioridad de hoy" —
  puedes usarlo como referencia visual mental, o extenderlo más adelante
  para tener una vista "Hoy" como en la versión web.
- Todo se guarda automáticamente en un archivo local
  (`user://savegame.json`), así que tu progreso persiste la próxima vez
  que abras el juego.

## 5. Estructura del proyecto (por si quieres modificarlo)

- `GameData.gd` — el "cerebro": guarda jugador y misiones, calcula XP y
  niveles, guarda/carga el archivo de progreso. Todo pasa por aquí.
- `Main.gd` — arma el mundo: fondo, personaje, marcadores de misión,
  detecta cuándo estás cerca de una misión.
- `Player.gd` — movimiento del personaje.
- `HUD.gd` — la barra superior de nivel/XP/racha.
- `QuestPanel.gd` — el panel emergente para ver y editar una misión.

Ideas para seguir construyendo: sonidos al completar objetivos
(`AudioStreamPlayer`), animación de "level up" más vistosa, un sistema de
categorías por color de misión, o exportar el juego como app de
escritorio desde **Proyecto > Exportar** una vez que tengas todo listo.

# Flutter Dynamic Particles Menu

Un **menú radial animado** con partículas dinámicas construido con **Flutter**.
Combina animaciones, física simple, efectos de blur y deformaciones matemáticas para lograr un comportamiento **natural e independiente**.

---

## Características principales

- Animación fluida al abrir y cerrar el menú.
- Partículas que flotan, se deforman y cambian de color.
- Simulación física con rebotes y oscilaciones independientes de los frames.
- Efectos visuales con `CustomPainter`, `BackdropFilter` y blur radial.
- Arquitectura modular dividida en tres archivos principales:

- main.dart # Punto de entrada de la aplicación
- animate_menu_screen.dart # Widget principal (UI + lógica)
- blob_painter.dart # CustomPainter que dibuja las partículas
- particle_model.dart # Modelo de la partícula

---

## Conceptos generales del proyecto

1. **Física:**
   Cada partícula tiene una posición, velocidad, tamaño y color.
   Su estado se actualiza en cada frame para simular movimiento realista.

2. **Oscilaciones:**  
   Se usan funciones trigonométricas (`sin`, `cos`) para generar movimientos aleatorios y naturales.

3. **Posicionamiento del menú:**  
   Los botones del menú se distribuyen con **coordenadas polares** (`r * cos(θ)`, `r * sin(θ)`) para formar un patrón circular.

---

## Funcionamiento general

### Generación de partículas

Cada partícula se crea con posición, velocidad, color y tamaño aleatorios:

```dart
Particle(
  Offset(rnd.nextDouble() * maxWidth, rnd.nextDouble() * maxHeight),
  Offset((rnd.nextDouble() - 0.5) * 2.5, (rnd.nextDouble() - 0.5) * 2.5),
  randomColor,
  rnd.nextDouble() * 40 + 20,
);

///2.Movimiento y deformación
en cada frame se recalculan las posiciones con fórmulas trigonométricas:
final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
p.position = p.position + p.velocity;

final dx = sin(t + p.hashCode * 0.0003) * 0.8;
final dy = cos(t + p.hashCode * 0.0005) * 0.8;
p.position = p.position.translate(dx, dy);


Explicación:
-sin() y cos() → generan oscilaciones suaves.
-p.hashCode → da una fase única a cada partícula (movimiento independiente).
-0.0003 y 0.8 → controlan frecuencia y amplitud del movimiento.

 

///3.Rebote y ruido aleatorio
if (p.position.dx < 0 || p.position.dx > maxWidth)
  p.velocity = Offset(-p.velocity.dx, p.velocity.dy);

p.velocity = p.velocity + Offset(
  (rnd.nextDouble() - 0.5) * 0.6,
  (rnd.nextDouble() - 0.5) * 0.6,
);


Explicación:
-rebote simple de la particula al llegar a los bordes.



///4️.Efecto Blob
-el renderizado con CustomPainter deforma cada partícula dinámicamente:

final scale = 1.1 + sin(t * 0.8 + blob.hashCode * 0.002) * 0.15;
final hueShift = (sin(t + blob.hashCode * 0.001) * 0.05).clamp(-0.1, 0.1);
paint.color = hsl
  .withHue((hsl.hue + hueShift * 360) % 360)
  .toColor()
  .withOpacity(0.4);


Explicación:
-scale → pulsación periódica
-hueShift → cambia sutilmente el tono..
-maskFilter.blur → bordes suaves para un efecto mas natural.



///5.Menú radial animado
los botones se distribuyen en círculo usando coordenadas polares:

final offsetX = radius * cos(angle) * _menuAnimation.value;
final offsetY = radius * sin(angle) * _menuAnimation.value;


Explicación:
x = r·cos(θ) y y = r·sin(θ) → transforman coordenadas polares en cartesianas.
multiplicar por _menuAnimation.value → permite animar la expansión del menú.



///6.Efectos de blur y gradiente
AnimatedContainer(
  decoration: BoxDecoration(
    gradient: RadialGradient(
      colors: [Colors.deepPurpleAccent, Colors.black],
      radius: isOpen ? 1.5 : 0.5,
    ),
  ),
).blurred(blur: isOpen ? 60.0 : 0.0);


Explicación:
-aumentar el radio del gradiente → sensación de expansión.
-incrementar el blur → enfoque visual en el menú y partículas.


▶️ Cómo ejecutar
git clone https://github.com/Makfront0123/flutter_demos.git
cd flutter_demos/animations/flutter_animation_01
flutter pub get
flutter run

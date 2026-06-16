# Entorno de Verificación UVM para un Alineador de Bus de 32 bits con Interfaz APB y RAL

> Entorno de verificación funcional completo, modular y automatizado en SystemVerilog bajo la metodología UVM para la validación del módulo `cfs_aligner`, integrando un modelo de registros (RAL) y un esquema de verificación basado en transacciones.

---

## 📋 Descripción General

Este proyecto consiste en el diseño e implementación de un entorno de verificación sólido y estructurado bajo el estándar **UVM (Universal Verification Methodology)** para validar el comportamiento funcional de un alineador de bus de 32 bits (`cfs_aligner`) bajo múltiples escenarios operativos y de estrés de protocolo.

El Dispositivo Bajo Verificación (DUT) recibe paquetes a través de una interfaz de memoria de datos (MD) de 32 bits organizada en 4 *lanes*, alinea el flujo según la configuración dinámica de sus registros de control, y los transmite por una interfaz de salida equivalente. El acceso a los registros internos del módulo se realiza mediante el protocolo **APB (Advanced Peripheral Bus)**, cuya abstracción en el entorno se implementa a través de un modelo **RAL (Register Abstraction Layer)** generado a partir de una descripción en formato RDL.

A diferencia de los entornos tradicionales, el sistema fue diseñado con un enfoque modular, desacoplado y guiado por eventos (TLM). El entorno integra de manera coordinada cuatro agentes de verificación independientes: un agente RX activo, un agente APB activo, un monitor TX pasivo y un monitor IRQ pasivo. Toda la información converge en un **Scoreboard** centralizado que aloja un modelo de referencia matemático para verificar en tiempo real la correcta alineación de datos, el conteo exacto de transferencias descartadas (*drops*) y el comportamiento del sistema de interrupciones.

---

## 📊 Arquitectura

El siguiente diagrama ilustra la jerarquía de componentes y el flujo de transacciones estructurado bajo la metodología UVM para este proyecto:

<p align="center">
  <img src="https://github.com/Gael-Aguero/Proyecto-2-Verificacion-funcional/blob/main/Documentaci%C3%B3n/Imagenes/Imagen1.png" alt="Arquitectura Top Level" width="550px">
</p>

El flujo de verificación e infraestructura de datos sigue el modelo estándar de UVM:

**Secuencias (Test) → Agentes/Sequencers → Drivers → Interfaz Virtual (aligner_if) → DUT → Monitores → Scoreboard**

### Notas de Infraestructura:
* **Conexión TLM:** A diferencia de un entorno clásico basado en *Mailboxes*, este entorno utiliza puertos de análisis de UVM (`uvm_analysis_port`) para comunicar de manera limpia y concurrente los monitores de los agentes (`rx_agt`, `tx_mon`, `irq_mon`) con el `Scoreboard`.
* **Modelo RAL:** Se integra un modelo de registros (`reg_model + adapter`) acoplado al agente APB, permitiendo rastrear el estado interno de la configuración y contadores del DUT en tiempo real.
* **Validación:** Este esquema permite una validación de tipo *grey-box*, combinando estímulos aleatorios restringidos en las interfaces y un modelo de referencia matemático preciso dentro del Scoreboard.

---

## 🚀 Guía de Uso

El proyecto está diseñado para ejecutarse en un entorno con soporte para SystemVerilog, utilizando un script de regresión automatizada.

### Flujo de Ejecución

1. Acceder al servidor o entorno de simulación
2. Ubicarse en la carpeta del proyecto
3. Ejecutar el script de regresión:

```bash
./aligner_regression.sh
```
Por defecto, el script ejecuta 5 pruebas automatizadas. Es posible especificar la cantidad de iteraciones como argumento de entrada:
```bash
./aligner_regression.sh 100
```

---
## 🛠️ Requisitos

- Simulador compatible con SystemVerilog (QuestaSim / ModelSim / Vivado / VCS)
- Soporte para interfaces virtuales
- Entorno Linux recomendado
- Resolución de tiempo: `1ns / 1ps`
---

## 📂 Documentación

Para un análisis detallado de cada componente, consulte el reporte técnico completo:

🔗 **Reporte:** [Ver documento](./Documentacion/Documentación%20Proyecto%201%20Verificación-%20AgueroG.AriasK..pdf)

---

## 👥 Estudiantes

| Nombre        | Rol                                 |
|---------------|-------------------------------------|
| Gael Agüero   | Estudiante de Ingeniería Electrónica |
| Kendy Arias   | Estudiante de Ingeniería Electrónica |

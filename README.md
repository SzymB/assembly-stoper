# Assembly x86 MS-DOS Stoper

Niskopoziomowa implementacja stopera stworzona w języku Asembler (x86) dla środowiska MS-DOS. Projekt realizuje podstawowe funkcje pomiaru czasu przy użyciu przerwań BIOS/DOS, zarządzania stanem systemu oraz bezpośredniej manipulacji pamięcią.

## Funkcjonalności
* **Dynamiczny pomiar czasu:** Pobieranie aktualnego czasu systemowego za pomocą przerwania `INT 21h` (funkcja 2Ch).
* **Obsługa zdarzeń:** Uruchamianie i zatrzymywanie stopera za pomocą zdefiniowanych klawiszy (V - start/stop, B - wyjście).
* **Logika czasu:** Autorski algorytm obliczania różnicy czasów z obsługą przeniesień (przeliczanie jednostek sekunda/minuta/godzina).
* **Interfejs tekstowy:** Wyświetlanie aktualnego czasu oraz wyników pomiaru w formacie 2-cyfrowym za pomocą funkcji BIOS `INT 21h`.

## Opis techniczny
Projekt wykorzystuje architekturę `.COM` (model pamięci Tiny), w której kod, dane i stos znajdują się w jednym segmencie 64KB.

**Kluczowe zagadnienia:**
* **Zarządzanie stanem (State Machine):** Implementacja zmiennej `czyStoper` kontrolującej logikę aplikacji.
* **Arytmetyka czasu:** Własne procedury (`obliczCzas`, `sprDodajSek`) obsługujące matematykę czasu (np. dodawanie 60 sekund przy „pożyczaniu” jednostki w obliczeniach).
* **Komunikacja z OS:** Wykorzystanie przerwań `INT 16h` (odczyt klawiatury) oraz `INT 21h` (obsługa terminala i czasu systemowego).

## Jak uruchomić?
1. Zainstaluj emulator **DOSBox**.
2. Zamontuj folder z plikiem:
   
   ```bash
   mount c C:\sciezka\do\projektu
   c:
   ```

3. Uruchom program:
   
  ```bash
  stoper.com
  ```


Użyj klawisza 'v', aby wystartować/zatrzymać stoper, oraz 'b', aby wyjść z programu.

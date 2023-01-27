# Group Purchase

 [Funkcjonalność.webm](https://user-images.githubusercontent.com/105966932/214914551-ed69c167-542a-4bc2-829a-a142c3fec4c1.webm)

## Co to za apka?
Aplikacja Gruop Purchase pozwala na tworzenie i edycję list zakupów, które mogą być dzielone z innymi użytkownikami. Dzięki temu, użytkownicy mogą współpracować przy tworzeniu list zakupów, np. dla zakupów grupowych, uzytkownicy mogą ją edytować

## Wymagania
* Flutter
* Firebase
* Paczki flutterowe: firebase_auth, cloud_firestore

## Instalacja
1. Pobierz lub sklonuj projekt na swój komputer.
2. Zainstaluj język pakiet Flutter w swoim edytorze kodu
3. Otwórz plik pubspec.yaml i zainstaluj wymagane pakiety.
4. Skonfiguruj Firebase dla swojej aplikacji.
5. Uruchom aplikację na swoim emulatorze lub urządzeniu.
6. Ciesz się funckjonalnością aplikacji

## Funkcje
* Tworzenie list zakupowych bez konieczności tworzenia konta,
* Tworzenie i edycja list zakupów,
* Dodawanie użytkowników do listy znajomych,
* Dzielenie list zakupów z innymi zalogowanymi użytkownikami,
* Synchronizacja danych z Firebase,
* Logowanie za pomocą maila.

## Jak korzystać z aplikacji
* Zaloguj się za pomocą swojego maila, bądź pozostań użytkownikiem niezalogowanym
* Stwórz nową listę zakupów, wprowadzając nazwę.
* Dodaj produkty do listy, wprowadzając ich nazwy.
* Możesz również dzielić listę z innymi użytkownikami, wprowadzając ich adresy e-mail.
* Oznacz jako zakupione lub usuń produkty z listy, klikając na odpowiedni przycisk.
* Wszystkie listy, do których dany użytkownik ma dostęp wyświetlają się na głównej stronie palikacji.

## Wykorzystane technologie
### Dart
* stworzony przez firmę Google, obiektowy język programowania, implementowany między innymi we frameworku Flutter,
### Flutter
* jest to otwartoźródłowy zestaw narzędzi dla programistów przeznaczony do tworzenia natywnych, wieloplatformowych aplikacji mobilnych, komputerowych oraz internetowych. Framework ten posiada oficjalny menedżer pakietów pod adresem pub.dev:
  - #### Stateless Widget
    jest to widżet, który nie wymaga zmiennego stanu. Opsiuje część interfejsu użytkownika poprzez zbudowanie konstelacji innych widżetów. Proces ten kontynuwany jest rekurencyjnie,
  - #### Statefull Widget
    widżet cechujący się zmiennym stanem. Stan jest informacją, która może być odczyta synchronicznie podczas budowania widżetu lub asynchronicznie. Zastosowanie tej klasy pozwala na dynamiczną aktualizację interfejsu użytkownika,
  -  #### Device Info Plus
     jest to pakiet pobierający informacje na temat urządzenia użytkownika, w aplikacji zastosowany w celu przypisania unikatowego adresu dla listy zakupowej stworzonej przez niezalogowanego użytkownika,
  - #### Connectivity Plus
    wtyczka ta umożliwia aplikacji wykrycie łączności sieciowej. Zastosowana w celu wyświetlenia komunikatu gdy użytkownik straci połączenie,
  - #### Flutter Native Splash
    pakiet pozwalający na wyświetlenie własnego logo podczas uruchamiania aplikacji,
### Google Firebase:
* to platforma do tworzenia aplikacji mobilnych i internetowych. Udostępnia szereg ściśle zintegrowanych funkcji, które można ze sobą łączyć:
  - #### Firebase Authentication
    zapewnia usługi backendowe, pakiety SDK oraz gotowe biblioteki interfejsu użytkownika do uwierzytelniania użytkowników aplikacji,
  - #### Cloud Firestore
    jest to baza danych NoSQL, która pozwala łatwo przechowywać, synchronizować i wyszukiwać dane dla aplikacji mobilnych i internetowych.


## Bezpieczeństwo
Aplikacja korzysta z Firebase - Cloud Firestore, co oznacza, że wszystkie dane są przechowywane w chmurze i szyfrowane podczas transmisji. Jest to gwarancja bezpieczeństwa Twoich danych i informacji o zakupach.

## Znane problemy
Apikacja stworzona wyłącznie na teleofny z systemem Android.

## Dalszy rozwój
Aplikacja jest stale rozwijana i planujemy dodanie nowych funkcji takich jak:
* Możlwość podpwiadania produktu po wpisaniu początkowych liter,
* Tworzenie kategorii produktów,
* Dodawanie ilości produktów,
* Integracja z API aby mieć wizualny podgląd produktów,
* Czat grupowy wewnątrz współdzielonej listy zakupowej,
* Kompatybilność aplikacji z systemami iOS.

## Kontakt
Jeśli masz pytania lub sugestie dotyczące aplikacji, skontaktuj się z nami pod adresem email: patryk.orzechowski.96@gmail.com bądź maciejsamol98@gmail.com

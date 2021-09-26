## SwiftGen Plugin
#### Важно: пример реализован на нестабильной версии Swift ([swift-DEVELOPMENT-SNAPSHOT-2021-09-18-a](https://swift.org/builds/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2021-09-18-a/swift-DEVELOPMENT-SNAPSHOT-2021-09-18-a-osx.pkg)). Перед тем, как выполнять указанные далее шаги, необходимо убедиться, что версия Swift не ниже 5.6

В этом примере рассматривается создание SPM-плагина для генерации доступа к ресурсам с помощью SwiftGen.

### Шаг 1. Подготовка SwiftGen к распространению через SPM
Для того, чтобы запускаемые файлы SwiftGen могли быть автоматически загружены средствами SwiftPM, необходимо упаковать его в специальный контейнер `artifactbundle` <br>
Для этого необходимо создать следующую директорию (В примере используется [этот релиз SwiftGen](https://github.com/SwiftGen/SwiftGen/releases/tag/6.4.0)):
```bash
swiftgen.artifactbundle
├── info.json
└── swiftgen
    ├── bin
    │   └── swiftgen
    ├── lib
    └── templates
```
В `info.json` необходимо внести метаданные артифакта - название, версию, путь до исполняемого файла и поддерживаемые системы:
```json
{
    "schemaVersion": "1.0",
    "artifacts": {
        "swiftgen": {
            "type": "executable",
            "version": "6.4.0",
            "variants": [
                {
                    "path": "swiftgen/bin/swiftgen",
                    "supportedTriples": ["x86_64-apple-macosx", "arm64-apple-macosx"]
                }
            ]
        }
    }
}
```
Полученную директорию необходимо заархивировать:
```
zip swiftgen.artifactbundle.zip swiftgen.artifactbundle
```
После чего сгенерировать контрольную сумму (`swift package compute-checksum swiftgen.artifactbundle.zip` - она понадобится при подключении зависимости) и загрузить файл на любое хранилище, поддерживающее https, либо положить локально

### Шаг 2. Создание пакета с плагином
Сперва создаем нужную структуру в директории:
```bash
swiftgen-spm-plugin
├── Package.swift
└── Plugins
    └── SwiftGenPlugin
        └── plugin.swift
```
Начнем с `Package.swift`. Он будет иметь следующий вид:
```swift
// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "SwiftGenPlugin",
    products: [
        .plugin(name: "SwiftGenPlugin", targets: ["SwiftGenPlugin"])
    ],
    dependencies: [],
    targets: [
        .plugin(
            name: "SwiftGenPlugin",
            capability: .buildTool(),
            dependencies: ["swiftgen"]),
        .binaryTarget(
            name: "swiftgen",
            url: "path/to/swiftgen.artifactbundle.zip",
            checksum: "checksum" // контрольная сумма была посчитана на шаге №1
        )
    ]
)
```
Далее, реализуем сам плагин:
```swift
import Foundation
import PackagePlugin

@main struct SwiftGenPlugin: BuildToolPlugin {
    func createBuildCommands(context: TargetBuildContext) throws -> [Command] {
        /// Получаем путь до файла конфигурации
        let swiftGenConfigFile = context.targetDirectory.appending("Resources/swiftgen.yml")
        /// Получаем путь до папки, в которую плагин имеет право записывать
        let outputDirectory = context.pluginWorkDirectory
        
        return [
            .prebuildCommand(
                 // Произвольная строка, выводящаяся при запуске
                displayName: "[SPM SwiftGen Plugin] Generating Resources",
                // Путь к запускаемому файлу. context.tool(named:) работает, так как исполняемый файл SwiftGen подключен в качестве зависимости
                executable: try context.tool(named: "swiftgen").path,
                // Аргументы запуска исполняемого файла SwiftGen
                arguments: [
                    "config", "run",
                    "--config", "\(swiftGenConfigFile)"
                ],
                // Переменные окружения
                environment: [
                    "SWIFTGEN_OUTPUT": "\(outputDirectory)",
                ],
                // Директория с выходными файлами
                outputFilesDirectory: outputDirectory
            )
        ]
    }
}
```
### Шаг 3. Создание клиента
В качестве клиента плагина будет выступать GUI-приложение для macOS, использующее SwiftUI для отрисовки и использующее локализацию, доступ к которой и должен обеспечить swiftgen <br>
Ресурсы в приложении располагаются следующим образом:
```bash
Client
├── Package.swift
└── Sources
    └── Client
        └── Resources
            ├── swiftgen.yml
            └── Localization
                └── en.lproj
                    └── Localizable.strings
```
Содержимое `swiftgen.yml` (Так как плагин имеет доступ на запись только в свою собственную директорию внутри директории с результатами сборки, нам необходимо передать путь до нее через переменную окружения `SWIFTGEN_OUTPUT`):
```yaml
strings:
  inputs: Localization/en.lproj/Localizable.strings
  outputs:
    templateName: structured-swift4
    output: ${SWIFTGEN_OUTPUT}/LocalizedStrings.swift
```
Содержимое файла локализации `Localizable.strings`:
```
"Common.hello" = "Hello World!";
```
Подключаем плагин в `Package.swift`:
```swift
// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Client",
    defaultLocalization: "en",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/ReQEnoxus/swiftgen-spm-plugin.git", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "Client",
            exclude: ["Resources/swiftgen.yml"],
            plugins: [.plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")]
        ),
    ]
)
```
После этого можем обращаться к локализованным строкам через `SwiftGen` внутри приложения:
```swift
import SwiftUI

struct MainView: View {
   var body: some View {
       Text(L10n.Common.hello) // "Common.hello" from Localizable.strings
           .font(
               .system(
                   size: 72,
                   weight: .bold
                )
           )
   }
}
```
После выполнения всех предыдущих шагов выполнение в корневой директории проекта команды `swift build && swift run` должно привести к успешной сборке и запуску приложения, которое выводит строку `"Hello World!"` на экран

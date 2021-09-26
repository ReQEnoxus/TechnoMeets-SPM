# Swift Package Manager в iOS разработке
Репозиторий с дополнительными материалами по [докладу](https://docs.google.com/presentation/d/1sP0-NpSrEmUlcMtR851eROxPeVwT6Gf6LqUP_u9xMXo/edit?usp=sharing) о Swift Package Manager с iOS-митапа в Технократии
## [Пример 1. Simple Dependency](https://github.com/ReQEnoxus/SwiftPM/tree/master/Projects/1.%20Simple%20Dependency)
В этом примере рассматривается подключение к проекту зависимости `SwiftNotificationBanner` через SPM. Эта библиотека позволяет отображать на экране баннеры следующим образом: <br>
<p align="center">
  <img src="Projects/1.%20Simple%20Dependency/.github/Application.png" width="30%" height="30%"/>
</p>

### Шаг 1. Добавление зависимости
<p align="center">
  <img src="Projects/1.%20Simple%20Dependency/.github/Step1.png"/>
</p>

### Шаг 2. Выбор версии
<p align="center">
  <img src="Projects/1.%20Simple%20Dependency/.github/Step2.png"/>
</p>

### Шаг 3. Добавление библиотеки к таргету
<p align="center">
  <img src="Projects/1.%20Simple%20Dependency/.github/Step3.png"/>
</p>

### Шаг 4. Использование
```swift
import UIKit
import NotificationBannerSwift

class ViewController: UIViewController {
    @IBAction func buttonTouchUpInside(_ sender: Any) {
        NotificationBanner(
            title: "NotificationBannerSwift",
            subtitle: "imported by spm",
            leftView: nil,
            rightView: nil,
            style: .success,
            colors: nil
        )
        .show(
            queuePosition: .front,
            bannerPosition: .top,
            queue: .default
        )
    }
}
```
## [Пример 2. Bundle With Resources](https://github.com/ReQEnoxus/SwiftPM/tree/master/Projects/2.%20Bundle%20with%20resources)
В этом примере рассматривается создание библиотеки, использующей статические ресурсы в виде картинок и локализации. Библиотека предоставляет пользователю экран с изображением рамки и кнопкой загрузки картинки. При этом название кнопки зависит от локализации.
<p align="center">
  <img src="Projects/2.%20Bundle%20with%20resources/.github/Lib1.png"/ width="40%" height="40%">
  <img src="Projects/2.%20Bundle%20with%20resources/.github/Lib2.png"/ width="40%" height="40%">
</p>

### Шаг 1. Инициализация
Шаблон библиотеки можно создать с помощью консольной команды:
```bash
swift package init --type library
```

### Шаг 2. Package.swift
При составлении манифеста добавляем:
* `defaultLocalization: "en"`, так как при использовании файлов локализации необходимо указать, какую локализацию нужно использовать по умолчанию
* `platforms: [.iOS(.v11)]`, так как наша библиотека использует `UIKit`
* `dependencies: [.package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))]`, так как для верстки используется `SnapKit`
```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Lib",
    defaultLocalization: "en",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "Lib",
            targets: ["Lib"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "Lib",
            dependencies: ["SnapKit"]
        ),
    ]
)
```

### Шаг 3. Реализация
Общий вид файловой структуры таргета:
```bash
Lib
├── RandomPictureController
│   └── RandomPictureController.swift
└── Resources
    ├── Images.xcassets
    │   ├── Contents.json
    │   └── frame.imageset
    │       ├── Contents.json
    │       └── frame.png
    └── Localization
        ├── en.lproj
        │   └── Localizable.strings
        └── ru.lproj
            └── Localizable.strings
```

Так как статические ресурсы находятся в папке `Resources`, а их предназначение очевидно по их расширениям - `.lproj`, `.xcassets`, мы не должны особым образом указывать их в `Package.swift`. <br> <br>
Также необходимо помнить, что для доступа к локальным ресурсам модуля нужно использовать конструкцию `Bundle.module`, доступную начиная со Swift 5.3:
```swift
//
//  RandomPictureController.swift
//  

public final class RandomPictureController: UIViewController {
    
    private lazy var getNewPictureButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle(
            NSLocalizedString(
                "button.title",
                bundle: .module, // <-- Bundle.module
                comment: "Title of the button"
            ),
            for: .normal
        )

        return button
    }()
    
    private lazy var frameImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(
            named: "frame",
            in: .module, // <-- Bundle.module
            compatibleWith: nil
        )

        return imageView
    }()
}
```

## [Пример 3. Binary Frameworks](https://github.com/ReQEnoxus/SwiftPM/tree/master/Projects/3.%20Binary%20Frameworks)
В этом примере разбирается создание простейшего бинарного фреймворка для двух платформ и его упаковка в контейнер `XCFramework`

### Шаг 1. Создание проекта в XCode
При создании проекта выбираем в верхней части окна платформу `iOS`, и темплейт `Framework`
<p align="center">
  <img src="Projects/3.%20Binary%20Frameworks/.github/project-template.png"/>
</p>
После этого вводим название и сохраняем в удобное место
<p align="center">
  <img src="Projects/3.%20Binary%20Frameworks/.github/project-name.png"/>
</p>
Устанавливаем ограничения по платформе в настрйках проекта:
<p align="left">
  <img src="Projects/3.%20Binary%20Frameworks/.github/platfrom-requirements.png"/>
</p>
Устанавливаем значение флага `Build Libraries for Distribution` в значение `YES`, для того, чтобы позже работать с XCFramework
<p align="center">
  <img src="Projects/3.%20Binary%20Frameworks/.github/build-for-distribution.png"/>
</p>
Итоговая файловая структура имеет следующий вид:
<p align="left">
  <img src="Projects/3.%20Binary%20Frameworks/.github/file-structure.png"/>
</p>

### Шаг 2. Добавляем исходный код
Добавим следующий Swift-файл в директорию фреймворка:
```swift
//
//  IntExtension.swift
//  HandyExtensionsFramework
//
//  Created by Enoxus on 09.03.2021.
//

import Foundation

public extension Int {
    var string: String {
        return "\(self)"
    }
}
```
### Шаг 3. Сборка фреймворков
Осуществим сборку фреймворков под платформы `iOS` и `iOS Simulator`. Для этого воспользуемся командой `xcodebuild archive`, передав в аргументах название таргета, конфигурацию,
целевую платформу, путь выходного файла и необходимые флаги. <br> <br>
Сборка для симулятора:
```bash
xcodebuild archive \
-scheme HandyExtensionsFramework \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/HandyExtensionsFramework.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
```
Сборка для iOS:
```bash
xcodebuild archive \
-scheme HandyExtensionsFramework \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/HandyExtensionsFramework.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
```

### Шаг 4. Упаковка в XCFramework
Для упаковки скомпилированных фреймворков выполняем следующую команду:
```bash
xcodebuild -create-xcframework \
-framework './build/HandyExtensionsFramework.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/HandyExtensionsFramework.framework' \
-framework './build/HandyExtensionsFramework.framework-iphoneos.xcarchive/Products/Library/Frameworks/HandyExtensionsFramework.framework' \
-output './build/HandyExtensionsFramework.xcframework'
```
В итоге получаем следующую структуру файлов:
```bash
HandyExtensionsFramework.xcframework
├── Info.plist
├── ios-arm64_armv7
│   └── HandyExtensionsFramework.framework
└── ios-arm64_i386_x86_64-simulator
    └── HandyExtensionsFramework.framework
```
### Шаг 5. Интеграция с SPM
Архивируем полученный XCFramework:
```bash
zip HandyExtensionsFramework.xcframework.zip HandyExtensionsFramework.xcframework
```
Загружаем полученный архив на любой хостинг, после чего создаем манифест пакета Package.swift:
```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "HandyExtensionsFramework",
    products: [
        .library(
            name: "HandyExtensionsFramework",
            targets: ["HandyExtensionsFramework"]
        ),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
          name: "HandyExtensionsFramework",
          url: "https://url.to/HandyExtensionsFramework.xcframework.zip",
          checksum: "" // TODO
        )
    ]
)
```
На данном этапе нам необходима контрольная сумма пакета, чтобы убедиться в том, что пользователи получат действительно верный артефакт. Вычисляем ее следующим образом:
```bash
swift package compute-checksum HandyExtensionsFramework.xcframework.zip
```
Полученное значение устанавливаем в соответствующее поле:
```swift
targets: [
    .binaryTarget(
      name: "HandyExtensionsFramework",
      url: "https://url.to/HandyExtensionsFramework.xcframework.zip",
      checksum: "3074c78131724148e57503c82f8dae97cd76862a0d7776da674bfd1c7705f80c"
    )
]
```
После этого можем разместить полученный Package.swift на любом git-хостинге и подключать библиотеку с помощью XCode или через dependencies в Package.swift
### Шаг 6. Использование
После подключения библиотеки и добавления ее к таргету приложения, можем импортировать ее и использовать предоставляемый ей метод:
```swift
//
//  ViewController.swift
//  FrameworkClient
//
//  Created by Enoxus on 09.03.2021.
//

import UIKit
import HandyExtensionsFramework

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(25.string) // "25"
    }
}
```
А [здесь](https://github.com/ReQEnoxus/HandyExtensionsFramework) можно найти загруженную на GitHub версию фреймворка для теста

## [Пример 4. Modular Architecture](https://github.com/ReQEnoxus/SwiftPM/tree/master/Projects/4.%20Modular%20Architecture%20with%20Storyboards)
В этом примере разбирается рефакторинг существующего монолитного приложения на отдельные модули. Приложение состоит из двух экранов: `Main`, содержащий список пользователей и `UserDetail`, позволяющий просмотреть детальную информацию о пользователе. Положение осложнено тем, что у нас уже есть 2 зависимости, подключенные через CocoaPods, а верстка реализована с помощью Storyboard:
<p align="center">
  <img src="Projects/4.%20Modular%20Architecture%20with%20Storyboards/.github/modular.png"/>
</p>

### Шаг 1. Отключение CocoaPods
Приложение содержит зависимости `RxSwift` и `Moya`, подключенные с помощью CocoaPods:
```ruby
target 'Modular' do
  use_frameworks!

  pod 'RxSwift', '~> 5.0.0'
  pod 'Moya', '~> 14.0'
end
```
Для того чтобы их удалить, нужно выполнить в корневой папке следующую команду:
```bash
pod deintegrate
```
После ее выполнения файл `Modular.xcworkspace` останется нетронутым, что позволит нам использовать его вместо создания собственного Workspace

### Шаг 2. Определение итоговой архитектуры
Целью проводимого рефакторинга является построение архитектуры, в которой каждый экран будет являться отдельным модулем со своими зависимостями. Аналогичным образом в отдельный модуль будут вынесены классы предметной области. Это позволит добиться более удобного переиспользования кода, а также ускорит сборку проекта, так как повторной сборке будут подвергнуты лишь те модули, которые реально были изменены. Схематично новую архитектуру можно изобразить в виде следующего графа:
<p align="center">
  <img src="Projects/4.%20Modular%20Architecture%20with%20Storyboards/.github/modular-graph.png"/ width="70%">
</p>

### Шаг 3. Создание модуля `Models`
Проще всего начать разделение именно отсюда, так как этот модуль не имеет зависимостей. Для создания нового модуля в текущем Workspace нужно выбрать следующую опцию, нажав на `+` в левом нижнем углу XCode:
<p align="center">
  <img src="Projects/4.%20Modular%20Architecture%20with%20Storyboards/.github/new-package.png"/ width="50%">
</p>

После этого нужно просто переместить файлы в созданную папку `Sources`, исправив, где нужно, модификаторы доступа на `public`
. `Package.swift` для этого модуля также будет выглядеть достаточно просто: <br>

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Models",
    products: [
        .library(
            name: "Models",
            targets: ["Models"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Models",
            dependencies: []
        ),
    ]
)
```

### Шаг 4. Создание модуля `UserDetail`
Здесь и далее не будем останавливаться на том, что уже рассматривалось в предыдущих шагах, отметим лишь то, что так как мы используем Storyboards, мы должны явно указать модуль, где содержится нужный нам кастомный класс для контроллера:

<p align="center">
  <img src="Projects/4.%20Modular%20Architecture%20with%20Storyboards/.github/class-module.png"/ width="50%">
</p>

Также, некоторые изменения нужно внести и в `Package.swift`. Из нерассмотренного ранее можно выделить подключение локального пакета в качестве зависимости:

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "UserDetail",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "UserDetail",
            targets: ["UserDetail"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
        .package(path: "../Models")  // <-- Подключение локального пакета
    ],
    targets: [
        .target(
            name: "UserDetail",
            dependencies: [
                "RxSwift",
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                "Models"
            ]),
    ]
)
```

### Шаг 5. Создание модуля `Main`
Здесь все аналогично, отличается он только тем, что в нем больше зависимостей:

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Main",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Main",
            targets: ["Main"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "14.0.0")),
        .package(path: "../Models"),
        .package(path: "../UserDetail")
    ],
    targets: [
        .target(
            name: "Main",
            dependencies: [
                "RxSwift",
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                "Moya",
                "Models",
                "UserDetail"
            ]
        ),
    ]
)
```
### Шаг 6. Подключение модуля `Main`
Исходя из построенной схемы, единственной прямой зависимостью приложения является модуль `Main`. Все остальные зависимости будут являться транзитивными. Для подключения модуля добавим его в `Frameworks, Libraries, and Embedded Content` нашего таргета:
<p align="center">
  <img src="Projects/4.%20Modular%20Architecture%20with%20Storyboards/.github/add-main.png"/ width="70%">
</p>

### Шаг 7. Установка rootViewController
Так как Storyboard модуля `Main` больше не находится в основном бандле приложения, мы больше не можем просто указывать его имя в `Info.plist` для установки стартового экрана. Воспользуемся следующим хелпером, чтобы установить его:

```swift
public class MainViewController: UIViewController {  
    public static func instantiate() -> UIViewController? {
        return UIStoryboard(name: "Main", bundle: .module).instantiateInitialViewController()
    }
}
```

После этого в `SceneDelegate`:
```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = MainViewController.instantiate()
        window?.makeKeyAndVisible()
    }
}
```
### Шаг 8. Настройка Segue
Переход между модулями `Main` и `UserDetail` осуществляется с помощью Segue:
<p align="center">
  <img src="Projects/4.%20Modular%20Architecture%20with%20Storyboards/.github/st-ref.png"/>
</p>

Для того, чтобы этот способ работал в модульной архитектуре, нам нужно вручную указать идентификатор бандла для объекта `Storyboard Reference`. Идентификатор бандла модуля в SPM формируется следующим образом: `[Package Name]-[Target Name]-resources`:
<p align="center">
  <img src="Projects/4.%20Modular%20Architecture%20with%20Storyboards/.github/bundle-id.png"/>
</p>

Кроме того, одно лишь указание бандла в этом объекте не гарантирует его доступность в runtime. Для того, чтобы не получить краш при выполнении перехода на экран деталки необходимо вручную загрузить соответствующий бандл. Для этого создадим следующий хэлпер в модуле `UserDetail`:
```swift
//
//  BundleUtil.swift
//  

import Foundation

public class UserDetailBundle {
    public static func load() {
        Bundle.module.load()
    }
}
```

И вызовем его в `AppDelegate`:
```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDetailBundle.load()
        return true
    }
}
```
<br>
На этом шаге рефакторинг завершается, приложение готово к использованию

## [Пример 5. SwiftGen Plugin](https://github.com/ReQEnoxus/TechnoMeets-SPM/tree/master/Projects/5.%20SwiftGen%20Plugin)

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

# Полезные ссылки
* [Официальная документация](https://swift.org/package-manager)
* [Extensible Build Tools Proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0303-swiftpm-extensible-build-tools.md)
* [Binary Targets Improvements](https://github.com/apple/swift-evolution/blob/main/proposals/0305-swiftpm-binary-target-improvements.md)
* [WWDC - Обзор SPM](https://developer.apple.com/videos/play/wwdc2018/411)
* [WWDC - Использование пакетов](https://developer.apple.com/videos/play/wwdc2019/408)
* [WWDC - Создание пакетов](https://developer.apple.com/videos/play/wwdc2019/410)
* [WWDC - Ресурсы в SPM](https://developer.apple.com/videos/play/wwdc2020/10169)
* [WWDC - Package Collections](https://developer.apple.com/videos/play/wwdc2021/10197/)
* [WWDC - Swift Algorithms & Swift Collections](https://developer.apple.com/videos/play/wwdc2021/10256/)

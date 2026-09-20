# new-branch.ps1 — создаёт правильную ветку и напоминает о процессе
# new-branch.ps1 — создаёт правильную ветку и напоминает о процессе
# Запуск: .\new-branch.ps1
 
Write-Host ""
Write-Host "Создание новой ветки" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
 
# 1. Проверить незакоммиченные изменения ДО любых переключений
$changes = git status --porcelain
if ($changes) {
    Write-Host "Есть незакоммиченные изменения:" -ForegroundColor Red
    git status --short
    Write-Host ""
    Write-Host "Сначала закоммить их или убери в stash:" -ForegroundColor Yellow
    Write-Host "  git add . && git commit -m 'feat: ...' " -ForegroundColor DarkGray
    Write-Host "  git stash" -ForegroundColor DarkGray
    exit 1
}
 
# 2. Убедиться что мы на main
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "Ты не на main (сейчас: $currentBranch)" -ForegroundColor Yellow
    $switch = Read-Host "Переключиться на main? (y/n)"
    if ($switch -eq "y") {
        git switch main
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Не удалось переключиться на main." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Отменено. Новую ветку нужно создавать от актуального main." -ForegroundColor Red
        exit 1
    }
}
 
# 3. Обновить main
Write-Host "📥 Обновляю main..." -ForegroundColor DarkGray
git pull origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "Не удалось обновить main. Проверь интернет или доступ к репозиторию." -ForegroundColor Red
    exit 1
}
 
Write-Host ""
 
# 4. Выбор типа ветки
Write-Host "Тип задачи:" -ForegroundColor White
Write-Host "  1. feature  — новая функциональность"
Write-Host "  2. fix      — исправление бага"
Write-Host "  3. chore    — конфигурация, зависимости"
Write-Host "  4. docs     — документация"
Write-Host "  5. test     — тесты"
Write-Host "  6. refactor — рефакторинг"
Write-Host ""
$typeChoice = Read-Host "Выбери тип (1-6)"
 
$branchType = switch ($typeChoice) {
    "1" { "feature" }
    "2" { "fix" }
    "3" { "chore" }
    "4" { "docs" }
    "5" { "test" }
    "6" { "refactor" }
    default {
        Write-Host "Неверный выбор" -ForegroundColor Red
        exit 1
    }
}
 
Write-Host ""
Write-Host "Короткое описание на английском (слова через дефис):" -ForegroundColor White
Write-Host "Пример: batch-download-endpoint" -ForegroundColor DarkGray
$description = Read-Host "→"
 
# Убрать пробелы, перевести в нижний регистр
$description = $description.Trim().ToLower() -replace '\s+', '-'
 
if ($description -eq "") {
    Write-Host "Описание не может быть пустым" -ForegroundColor Red
    exit 1
}
 
$branchName = "$branchType/$description"
 
Write-Host ""
Write-Host "Ветка будет называться: " -NoNewline -ForegroundColor White
Write-Host $branchName -ForegroundColor Green
 
$confirm = Read-Host "Создать? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Отменено." -ForegroundColor DarkGray
    exit 0
}
 
git switch -c $branchName
if ($LASTEXITCODE -ne 0) {
    Write-Host "Не удалось создать ветку. Возможно она уже существует." -ForegroundColor Red
    exit 1
}
 
Write-Host ""
Write-Host "Ветка создана и активна: $branchName" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "Напоминание о процессе работы:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Пиши код небольшими логичными кусками"
Write-Host "  2. Коммить часто: git add . && git commit -m 'feat: ...'"
Write-Host "  3. Формат: feat|fix|chore|docs|test|refactor: описание"
Write-Host "  4. Когда фича готова: git push origin $branchName"
Write-Host "  5. Создай Pull Request на GitHub → в main"
Write-Host "  6. После merge: вернись на main и запусти этот скрипт снова"
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
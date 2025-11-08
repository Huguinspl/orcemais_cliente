# Script de Deploy - Gestorfy Cliente

Write-Host "🚀 Iniciando deploy do Gestorfy Cliente..." -ForegroundColor Cyan

# Navegar para o diretório do projeto
Set-Location -Path "c:\Users\hugui\desenvolvimento\gestorfy_cliente"

# Verificar se o build existe
if (Test-Path "gestorfy_cliente\build\web") {
    Write-Host "✅ Build encontrado!" -ForegroundColor Green
    
    # Deploy para Firebase Hosting
    Write-Host "📤 Fazendo deploy para Firebase Hosting..." -ForegroundColor Yellow
    firebase deploy --only hosting:gestorfy-cliente
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Deploy concluído com sucesso!" -ForegroundColor Green
        Write-Host "🌐 Seu site está disponível em: https://gestorfy-cliente.web.app" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Erro no deploy!" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Build não encontrado! Execute: flutter build web --release" -ForegroundColor Red
}

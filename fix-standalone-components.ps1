# PowerShell script to remove standalone: true from all component files
# This fixes the Angular module vs standalone component conflict

Write-Host "🔧 Fixing standalone components in custom theme..." -ForegroundColor Yellow

# Get all component TypeScript files in the custom theme
$componentFiles = Get-ChildItem -Path "src\themes\custom\app" -Recurse -Filter "*.component.ts"

$totalFiles = $componentFiles.Count
$processedFiles = 0
$modifiedFiles = 0

Write-Host "📁 Found $totalFiles component files to process..." -ForegroundColor Cyan

foreach ($file in $componentFiles) {
    $processedFiles++
    $content = Get-Content $file.FullName -Raw
    
    # Check if file contains standalone: true
    if ($content -match "standalone:\s*true") {
        Write-Host "[$processedFiles/$totalFiles] 🔄 Processing: $($file.Name)" -ForegroundColor White
        
        # Remove standalone: true and its imports line
        $newContent = $content -replace "standalone:\s*true,?\s*", ""
        
        # Remove imports line if it exists (for standalone components)
        $newContent = $newContent -replace "imports:\s*\[[^\]]*\],?\s*", ""
        
        # Clean up any double commas or trailing commas
        $newContent = $newContent -replace ",\s*,", ","
        $newContent = $newContent -replace ",\s*\}", "}"
        
        # Write the modified content back
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        $modifiedFiles++
        
        Write-Host "    ✅ Removed standalone from $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "[$processedFiles/$totalFiles] ⏭️  Skipping: $($file.Name) (not standalone)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "🎉 COMPLETED!" -ForegroundColor Green
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "   • Total files processed: $totalFiles" -ForegroundColor White
Write-Host "   • Files modified: $modifiedFiles" -ForegroundColor White
Write-Host "   • Files unchanged: $($totalFiles - $modifiedFiles)" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Run 'npx yarn build' to test the build" -ForegroundColor White
Write-Host "   2. Fix any remaining import issues" -ForegroundColor White
Write-Host "   3. Test the application functionality" -ForegroundColor White

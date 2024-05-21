
## In powershell

### 1. To find files with CRLF line endings

```pwsh
Get-ChildItem -Recurse | Select-String -Pattern "`r`n" -List
```

### To convert files in the project directory from CRLF to LF
```pwsh 
Get-ChildItem -Recurse | ForEach-Object {
    (Get-Content $_.FullName) | Set-Content $_.FullName -NoNewline
}
```

### To convert a specific file 
```pwsh
(Get-Content entrypoint.sh -Raw) -replace "\r\n", "`n" | Set-Content -NoNewline converted_entrypoint.sh
```



## in UBUNTU:

Check the file data: 
```bash
file entrypoint.sh
```

### To convert all files in a directory from CRLF to LF on Unix-like systems

```bash
dos2unix root_or_other_directory/*
```

### To convert them back from LF to CRLF:

```bash
unix2dos root_or_other_directory/*
```
# Unix to Windows Conversion for AKS Deployments

Most Azure Kubernetes Service (AKS) clusters use Linux-based virtual machines for running containers. As a Windows user, I needed to ensure that the files I configure have Unix-style line endings (LF) to avoid errors during container creation.

## Approaches for Line Ending Conversion:

## 1. Use Git

Git automatically converts line endings when files are committed, simplifying the process for Windows users.

![image](https://github.com/ZCHAnalytics/K8s-resume-with-tf-azure-pwsh/assets/146954022/e73090dc-8494-4e14-a635-1eb305b2dae5)

## 2. Use dos2unix tool

A `dos2unix` tool. The commands are self-explanatory and convert both ways with `dos2unix <folder>/*` and `unix2dos <folder>/*`.

## 3. Use native shell commands

## 3.1 PowerShell 
Convert all files in a root directory to LF:
```pwsh 
Get-ChildItem -Recurse | ForEach-Object { (Get-Content $_.FullName) | Set-Content $_.FullName -NoNewline }
```
Convert using a specific file name:
```pwsh
(Get-Content <entrypoint.sh> -Raw) -replace "\r\n", "`n" | Set-Content -NoNewline <converted_entrypoint.sh>
```

## 3.2. Bash
Convert all files in a directory to LF:
```bash
for file in <challenge-steps>/*; do
  sed -i 's/\r$//' "$file"
done
```
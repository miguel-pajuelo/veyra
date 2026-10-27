#requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Path)

$ErrorActionPreference='Stop'
if (-not ('Veyra.NativePath' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Text;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
namespace Veyra {
    public static class NativePath {
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern uint GetFinalPathNameByHandle(SafeFileHandle handle, StringBuilder path, uint size, uint flags);
    }
}
'@
}
$resolved=(Resolve-Path -LiteralPath $Path).Path
$stream=[IO.File]::Open($resolved,[IO.FileMode]::Open,[IO.FileAccess]::Read,([IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete))
try {
    $buffer=New-Object Text.StringBuilder 1024
    $length=[Veyra.NativePath]::GetFinalPathNameByHandle($stream.SafeFileHandle,$buffer,[uint32]$buffer.Capacity,0)
    if($length -ge $buffer.Capacity){
        $buffer=New-Object Text.StringBuilder ([int]$length+1)
        $length=[Veyra.NativePath]::GetFinalPathNameByHandle($stream.SafeFileHandle,$buffer,[uint32]$buffer.Capacity,0)
    }
    if($length -eq 0){throw (New-Object ComponentModel.Win32Exception)}
    $result=$buffer.ToString()
    if($result.StartsWith('\\?\UNC\')){return '\\'+$result.Substring(8)}
    if($result.StartsWith('\\?\')){return $result.Substring(4)}
    return $result
} finally {$stream.Dispose()}

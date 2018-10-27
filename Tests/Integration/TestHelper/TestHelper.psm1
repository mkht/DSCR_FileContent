function Test-BOM {
    param(
        $Path
    )

    [Byte[]]$bytes = gc -LiteralPath $Path -Encoding Byte | select -First 3
    [string]$bom = ($bytes | % {$_.ToString()}) -join ';'
    switch ($bom) {
        '239;187;191' {
            'utf8BOM'
            break;
        }
    }
}


function Test-NewLineCode {
    param(
        $Path
    )

    $con = Get-Content -LiteralPath $Path -Raw

    if ($con -match "`r`n") {
        'CRLF'
    }
    elseif ($con -match "`n") {
        'LF'
    }
    else {
        'NOLINE'
    }
}


# This code obtained from http://d.hatena.ne.jp/junjun777/20150223/powershell_get_encoding
function Get-TestEncoding {
    Param(
        $Path,
        [switch]$List,
        [int]$Max = 10
    )

    $namespaceName = 'Mlang'
    $className = 'Encoding'
    $classFullName = '{0}.{1}' -f $namespaceName, $className
    if (-not ($classFullName -as [type])) {
        Add-Type @"
using System;
using System.Runtime.InteropServices;

namespace $namespaceName
{
    public class $className
    {
        public static DetectEncodingInfo[] Detect(byte[] bytes, int max)
        {
            DetectEncodingInfo[] ret = null;
            IMultiLanguage2 lang = (IMultiLanguage2)new MultiLanguage();
            int len = bytes.Length, scores = max, i;
            DetectEncodingInfo[] infos = new DetectEncodingInfo[scores];
            for (i = 0; i < scores; i++) infos[i] = new DetectEncodingInfo();

            // bytes to IntPtr
            GCHandle hbytes = GCHandle.Alloc(bytes, GCHandleType.Pinned);
            IntPtr pbytes = Marshal.UnsafeAddrOfPinnedArrayElement(bytes, 0);
            GCHandle hinfos = GCHandle.Alloc(infos, GCHandleType.Pinned);
            IntPtr pinfos = Marshal.UnsafeAddrOfPinnedArrayElement(infos, 0);
            try
            {
                if (lang.DetectInputCodepage(0, 0, pbytes, ref len, pinfos, ref scores) == 0 && scores >= 0)
                {
                    ret = new DetectEncodingInfo[scores];
                    for (i = 0; i < scores; i++) ret[i] = infos[i];
                }
            }
            finally
            {
                if (hinfos.IsAllocated) hinfos.Free();
                if (hbytes.IsAllocated) hbytes.Free();
            }

            return ret;
        }
    }

    public struct DetectEncodingInfo
    {
        public UInt32 nLangID;
        public UInt32 nCodePage;
        public Int32 nDocPercent;
        public Int32 nConfidence;
    };

    [ComImport, Guid("275c23e2-3747-11d0-9fea-00aa003f8646")]
    public class MultiLanguage { }

    [Guid("DCCFC164-2B38-11D2-B7EC-00C04F8F5D9A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMultiLanguage2
    {
        void GetNumberOfCodePageInfo();
        void GetCodePageInfo();
        void GetFamilyCodePage();
        void EnumCodePages();
        void GetCharsetInfo();
        void IsConvertible();
        void ConvertString();
        void ConvertStringToUnicode();
        void ConvertStringFromUnicode();
        void ConvertStringReset();
        void GetRfc1766FromLcid();
        void GetLcidFromRfc1766();
        void EnumRfc1766();
        void GetRfc1766Info();
        void CreateConvertCharset();
        void ConvertStringInIStream();
        void ConvertStringToUnicodeEx();
        void ConvertStringFromUnicodeEx();
        void DetectCodepageInIStream();
        int  DetectInputCodepage(
            [In] UInt32 dwFlag,
            [In] UInt32 dwPrefWinCodePage,
            [In] IntPtr pSrcStr,
            [In, Out] ref Int32 pcSrcSize,
            [In] IntPtr lpEncoding,
            [In, Out] ref Int32 pnScores);
        void ValidateCodePage();
        void GetCodePageDescription();
        void IsCodePageInstallable();
        void SetMimeDBSource();
        void GetNumberOfScripts();
        void EnumScripts();
        void ValidateCodePageEx();
    }
}
"@
    }
    $encoding = $classFullName -as [type]
    if ($Path -is [string]) {
        $infos = $encoding::Detect([System.IO.File]::ReadAllBytes($Path), $Max)
    }
    else {
        $infos = $encoding::Detect($Path, $Max)
    }
    $ret = $null
    if ($List) {
        $ret = $infos
    }
    else {
        for ($i = 0; $i -lt $infos.Count; $i++) {
            $ret = [System.Text.Encoding]::GetEncoding([int]$infos[$i].nCodePage)
            if ($infos[$i].nLangID -eq 0xffffffff) { break }
        }
    }
    return $ret
}


Export-ModuleMember -Function *

Param($targetAppConfigPath, $sourceAppConfigPath, $outputPath, $projectName)

Add-Type -AssemblyName System.Configuration

if (!(Test-Path $targetAppConfigPath) -or !(Test-Path $sourceAppConfigPath)) {
    return
}

# ファイル読込
[xml]$targetAppConfig = Get-Content $targetAppConfigPath -Encoding UTF8
[xml]$sourceAppConfig = Get-Content $sourceAppConfigPath -Encoding UTF8

function main() {

    copySettings "configuration/applicationSettings/$projectName.My.MySettings"
    copySettings "configuration/userSettings/$projectName.My.MySettings"
    copyConnectionStrings "configuration/connectionStrings"
    copyAppConfigs "configuration/appSettings"

    $targetAppConfig.Save($outputPath)
}

<#
    設定、および接続文字列をコピーする。
#>
function copySettings($xpath) {
    [System.Xml.XmlNode]$target = $targetAppConfig.SelectSingleNode($xpath)
    [System.Xml.XmlNode]$source = $sourceAppConfig.SelectSingleNode($xpath)

    if ($source -eq $null) {
        # コピー元が無いなら、何もしない
        return
    } elseif ($target -eq $null) {
        # コピー先がない場合も何もしない(基本的にあり得ないと思いたい)
         return
    }

    foreach ($s in $source.ChildNodes) {
        if ($source.NodeType -eq [System.Xml.XmlNodeType]::Element) {
            $sname = $s.name
            $t = $target.SelectSingleNode("setting[@name='${sname}']")

            if ($t -eq $null) {
                cloneElement $target $s
            
            } else {
                copyElement $t $s
            }
        }
    }
}

<#
    appConfigをコピーする。
#>
function copyAppConfigs($xpath) {
    [System.Xml.XmlNode]$target = $targetAppConfig.SelectSingleNode($xpath)
    [System.Xml.XmlNode]$source = $sourceAppConfig.SelectSingleNode($xpath)

    if ($source -eq $null) {
        # コピー元が無いなら、何もしない
        return
    } elseif ($target -eq $null) {
        # コピー先がない場合も何もしない(基本的にあり得ないと思いたい)
         return
    }

    foreach ($s in $source.ChildNodes) {
        if ($source.NodeType -eq [System.Xml.XmlNodeType]::Element) {
            $stagname = $s.LocalName
            $skey = $s.key
            $t = $target.SelectSingleNode("${stagname}[@key='${skey}']")

            if ($t -eq $null) {
                cloneElement $target $s
            
            } else {
                copyElement $t $s
            }
        }
    }
}

<#
    接続文字列をコピーする。
#>
function copyConnectionStrings($xpath) {
    [System.Xml.XmlNode]$target = $targetAppConfig.SelectSingleNode($xpath)
    [System.Xml.XmlNode]$source = $sourceAppConfig.SelectSingleNode($xpath)

    if ($source -eq $null) {
        # コピー元が無いなら、何もしない
        return
    } elseif ($target -eq $null) {
        # コピー先がない場合も何もしない(基本的にあり得ないと思いたい)
         return
    }

    foreach ($s in $source.ChildNodes) {
        if ($source.NodeType -eq [System.Xml.XmlNodeType]::Element) {
            $stagname = $s.LocalName
            $sname = $s.name
            $t = $target.SelectSingleNode("${stagname}[@name='${sname}']")

            if ($t -eq $null) {
                cloneElement $target $s
            
            } else {
                copyElement $t $s
            }
        }
    }
}

<#
    $sourceElementの内容を、$targetElementに複製する
#>
function copyElement([System.Xml.XmlElement]$targetElement, [System.Xml.XmlElement]$sourceElement) {
    $targetElement.InnerXml = $sourceElement.InnerXml

    # 属性値のコピー
    foreach($attr in $sourceElement.Attributes) {
        $targetElement.SetAttribute($attr.Name, $attr.Value)
    }
}

<#
    $sourceElementを複製して、$targetParentの子に追加する
#>
function cloneElement([System.Xml.XmlNode]$targetParent, [System.Xml.XmlElement]$sourceElement) {
    $created = $targetAppConfig.CreateElement($sourceElement.LocalName)
    $created.InnerXml = $sourceElement.InnerXml

    # 属性値のコピー
    foreach($attr in $sourceElement.Attributes) {
        $created.SetAttribute($attr.Name, $attr.Value)
    }

    $dummy = $targetParent.AppendChild($created)
}

main

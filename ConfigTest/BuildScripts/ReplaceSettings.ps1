Param($targetAppConfigPath, $sourceAppConfigPath, $outputPath, $projectName)

Add-Type -AssemblyName System.Configuration

if (!(Test-Path $targetAppConfigPath) -or !(Test-Path $sourceAppConfigPath)) {
    return
}

# �t�@�C���Ǎ�
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
    �ݒ�A����ѐڑ���������R�s�[����B
#>
function copySettings($xpath) {
    [System.Xml.XmlNode]$target = $targetAppConfig.SelectSingleNode($xpath)
    [System.Xml.XmlNode]$source = $sourceAppConfig.SelectSingleNode($xpath)

    if ($source -eq $null) {
        # �R�s�[���������Ȃ�A�������Ȃ�
        return
    } elseif ($target -eq $null) {
        # �R�s�[�悪�Ȃ��ꍇ���������Ȃ�(��{�I�ɂ��蓾�Ȃ��Ǝv������)
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
    appConfig���R�s�[����B
#>
function copyAppConfigs($xpath) {
    [System.Xml.XmlNode]$target = $targetAppConfig.SelectSingleNode($xpath)
    [System.Xml.XmlNode]$source = $sourceAppConfig.SelectSingleNode($xpath)

    if ($source -eq $null) {
        # �R�s�[���������Ȃ�A�������Ȃ�
        return
    } elseif ($target -eq $null) {
        # �R�s�[�悪�Ȃ��ꍇ���������Ȃ�(��{�I�ɂ��蓾�Ȃ��Ǝv������)
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
    �ڑ���������R�s�[����B
#>
function copyConnectionStrings($xpath) {
    [System.Xml.XmlNode]$target = $targetAppConfig.SelectSingleNode($xpath)
    [System.Xml.XmlNode]$source = $sourceAppConfig.SelectSingleNode($xpath)

    if ($source -eq $null) {
        # �R�s�[���������Ȃ�A�������Ȃ�
        return
    } elseif ($target -eq $null) {
        # �R�s�[�悪�Ȃ��ꍇ���������Ȃ�(��{�I�ɂ��蓾�Ȃ��Ǝv������)
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
    $sourceElement�̓��e���A$targetElement�ɕ�������
#>
function copyElement([System.Xml.XmlElement]$targetElement, [System.Xml.XmlElement]$sourceElement) {
    $targetElement.InnerXml = $sourceElement.InnerXml

    # �����l�̃R�s�[
    foreach($attr in $sourceElement.Attributes) {
        $targetElement.SetAttribute($attr.Name, $attr.Value)
    }
}

<#
    $sourceElement�𕡐����āA$targetParent�̎q�ɒǉ�����
#>
function cloneElement([System.Xml.XmlNode]$targetParent, [System.Xml.XmlElement]$sourceElement) {
    $created = $targetAppConfig.CreateElement($sourceElement.LocalName)
    $created.InnerXml = $sourceElement.InnerXml

    # �����l�̃R�s�[
    foreach($attr in $sourceElement.Attributes) {
        $created.SetAttribute($attr.Name, $attr.Value)
    }

    $dummy = $targetParent.AppendChild($created)
}

main

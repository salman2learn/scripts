<#
	Author: http://github.com/salman2learn
	Date: 2016-08-11
	Version: 20161007.0
	
	Description: 
	This script generates AppDynamics APM agent configuration file when 
	executed on a IIS web server. It uses iterates through each site and 
	web application and places them in config.
	
	How to use:
	Update server name and password guid in top two lines.
	Copy to web server, open a powershell console and run:
		.\appdynamics-getconfig.ps1 > config.xml
	Copy the config file to web server folder:
		\ProgramData\AppDynamics\DotNetAgent\Config
	
	License:
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	"AppDynamics APM" is copyright of AppDynamics, Inc.
#>

$appdynhost = "your-appdynamics-server-name.com"
$password = "11111111-1111-1111-1111-111111111111"
$tierName = "App-tier"

[Void][Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration")

$sm = New-Object Microsoft.Web.Administration.ServerManager

function log($msg)
{
    write-output $msg
    #write-host $msg 
}



$xmlHeader = 
@"
<?xml version="1.0" encoding="utf-8"?>
<appdynamics-agent xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <controller host="$appdynhost" port="443" ssl="true" enable_tls12="true">
        <account name="customer1" password="$password" />
            <applications>
"@
$xmlMiddle = 
@"
            </applications>
    </controller>
    <machine-agent />
    <app-agents>
        <IIS>
            <automatic enabled="false"/>
            <applications>
"@
$xmlFooter = 
@"
            </applications>
        </IIS>
    </app-agents>
</appdynamics-agent>
"@

log $xmlHeader
$sm.Sites | %{ Get-WebApplication -Site $_.name} | %{  log "`t`t`t`t<application name=""$($_.path.replace("/",""""))"" />"}
log $xmlMiddle
$sm.Sites | %{ $sn = $_.name; Get-WebApplication -Site $_.name} | %{  log "`t`t`t`t<application path=""$($_.path)"" site=""$($sn)"" controller-application=""$($_.path.replace("/",""""))""> <tier name=""$($tierName)"" /> </application>" }
log $xmlFooter
#================================================================================================================
#
# Author 		 : Daniel Sjogren 
# A lot of inspiration from "About my PC" https://github.com/damienvanrobaeys/About_my_device
#
#================================================================================================================

# Get Last modified date of the Script file and set it in the Title
Function Get-ScriptLastModifiedDate {
    if ($psise) {
        $($(Get-ChildItem $psise.CurrentFile.FullPath).LastWriteTime).ToString("yyyy-MM-dd HH:mm") 
    }
    else {
        $($(Get-ChildItem $PSCommandPath).LastWriteTime).ToString("yyyy-MM-dd HH:mm")
    }
}
$ScriptVersion = Get-ScriptLastModifiedDate

# Get Current script directory
Function Get-ScriptDirectory {
    if ($psise) {
        Split-Path $psise.CurrentFile.FullPath
    }
    else {
        $global:PSScriptRoot
    }
}
$Global:Current_Folder = Get-ScriptDirectory

# Load Assemblies
If ($True) {
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null
    [System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
    [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | out-null
    [System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | out-null
    [System.Reflection.Assembly]::LoadFrom("$($current_folder)\assembly\MahApps.Metro.dll") | out-null
    [System.Reflection.Assembly]::LoadFrom("$($current_folder)\assembly\LiveCharts.dll") | out-null  	
    [System.Reflection.Assembly]::LoadFrom("$($current_folder)\assembly\LiveCharts.Wpf.dll") | out-null  
    [System.Reflection.Assembly]::LoadFrom("$($current_folder)\assembly\MahApps.Metro.IconPacks.dll") | out-null  
    [System.Reflection.Assembly]::LoadFrom("$($current_folder)\assembly\LoadingIndicators.WPF.dll") | out-null
}

Function LoadXml ($global:filename) {
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow XAML
If ($True) {
    $XamlMainWindow=LoadXml("$($current_folder)\MainWindow.xaml")
    $Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
    $Form=[Windows.Markup.XamlReader]::Load($Reader)
}

# MainWindow Initialization
If ($True) {
    $Tab_Control = $form.FindName("Tab_Control")
    $Tab_Overview = $form.FindName("Tab_Overview")
    $Tab_Details = $form.FindName("Tab_Details")
    $Tab_Links = $form.FindName("Tab_Links")
    $Tab_Monitors = $form.FindName("Tab_Monitors")
    $Tab_Support = $form.FindName("Tab_Support")
    $Tab_Tools = $form.FindName("Tab_Tools")
    $Tab_Troubleshooting = $form.FindName("Tab_Troubleshooting")
    $Tab_VPN = $form.FindName("Tab_VPN")

    $TitleScriptVersion = $form.FindName("ScriptVersion")
    $TitleScriptVersion.Content = "Version: $ScriptVersion"
}

# Functions
If ($True) {

Function TextFormatting {  
   [CmdletBinding(  
     ConfirmImpact='Medium',  
     HelpURI='http://vcloud-lab.com'  
   )]  
   Param (  
     [parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]  
     [String]$Text,  
     [Switch]$Bold, #https://docs.microsoft.com/en-us/uwp/api/windows.ui.text.fontweights  
     [Switch]$Italic, #https://docs.microsoft.com/en-us/uwp/api/windows.ui.text.fontstyle  
     [String]$TextDecorations, #https://docs.microsoft.com/en-us/uwp/api/windows.ui.text.textdecorations  
     [Int]$FontSize,  
     [String]$Foreground,  
     [String]$Background,  
     [Switch]$NewLine  
   )  
   Begin {  
     #https://docs.microsoft.com/en-us/uwp/api/windows.ui.text  
     $ObjRun = New-Object System.Windows.Documents.Run  
     function TextUIElement {  
       Param (  
           [parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]  
           [String]$PropertyName  
         )  
       $Script:PropValue = $PropertyName  
       Switch ($PropertyName) {  
         'Bold' {'FontWeight'} #Thin, SemiLight, SemiBold, Normal, Medium, Light, ExtraLight, ExtraBold, ExtraBlack, Bold, Black  
         'Italic' {'FontStyle'} #Italic, Normal, Oblique  
         'TextDecorations' {'TextDecorations'} #None, Strikethrough, Underline  
         'FontSize' {'FontSize'}  
         'Foreground' {'Foreground'}  
         'Background' {'Background'}  
         'NewLine' {'NewLine'}  
       }  
     }  
   }  
   Process {  
     if ($PSBoundParameters.ContainsKey('NewLine')) {  
       $ObjRun.Text = "`n$Text "  
     }  
     else {  
       $ObjRun.Text = $Text  
     }  
       
     $AllParameters = $PSBoundParameters.Keys | Where-Object {$_ -ne 'Text'}  
   
     foreach ($SelectedParam in $AllParameters) {  
       $Prop = TextUIElement -PropertyName $SelectedParam  
       if ($PSBoundParameters[$SelectedParam] -eq [System.Management.Automation.SwitchParameter]::Present) {  
         $ObjRun.$Prop = $PropValue  
       }  
       else {  
         $ObjRun.$Prop = $PSBoundParameters[$Prop]  
       }  
     }  
     $ObjRun  
   }  
 } 
  
Function Format-RichTextBox {  
   #https://msdn.microsoft.com/en-us/library/system.windows.documents.textelement(v=vs.110).aspx#Propertiesshut  
   param (  
     [parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]  
     [System.Windows.Controls.RichTextBox]$RichTextBoxControl,  
     [String]$Text,  
     [String]$ForeGroundColor = 'Black',  
     [String]$BackGroundColor = 'White',  
     [String]$FontSize = '12',  
     [String]$FontStyle = 'Normal',  
     [String]$FontWeight = 'Normal',  
     [Switch]$NewLine  
   )  
   $ParamOptions = $PSBoundParameters  
   $RichTextRange = New-Object System.Windows.Documents.TextRange(<#$RichTextBoxControl.Document.ContentStart#>$RichTextBoxControl.Document.ContentEnd, $RichTextBoxControl.Document.ContentEnd)  
   if ($ParamOptions.ContainsKey('NewLine')) {  
     $RichTextRange.Text = "`n$Text"  
   }  
   else {  
     $RichTextRange.Text = $Text  
   }  
   
   $Defaults = @{ForeGroundColor='Black';BackGroundColor='White';FontSize='12'; FontStyle='Normal'; FontWeight='Normal'}  
   foreach ($Key in $Defaults.Keys) {  
     if ($ParamOptions.Keys -notcontains $Key) {  
       $ParamOptions.Add($Key, $Defaults[$Key])  
     }  
   }   
   
   $AllParameters = $ParamOptions.Keys | Where-Object {@('RichTextBoxControl','Text','NewLine') -notcontains $_}  
   foreach ($SelectedParam in $AllParameters) {  
     if ($SelectedParam -eq 'ForeGroundColor') {$TextElement = [System.Windows.Documents.TextElement]::ForegroundProperty}  
     elseif ($SelectedParam -eq 'BackGroundColor') {$TextElement = [System.Windows.Documents.TextElement]::BackgroundProperty}  
     elseif ($SelectedParam -eq 'FontSize') {$TextElement = [System.Windows.Documents.TextElement]::FontSizeProperty}  
     elseif ($SelectedParam -eq 'FontStyle') {$TextElement = [System.Windows.Documents.TextElement]::FontStyleProperty}  
     elseif ($SelectedParam -eq 'FontWeight') {$TextElement = [System.Windows.Documents.TextElement]::FontWeightProperty}  
     $RichTextRange.ApplyPropertyValue($TextElement, $ParamOptions[$SelectedParam])  
   }  
 }  

Function CreateNewChildRunSpace {
$Global:syncProgress = [hashtable]::Synchronized(@{})
$Global:childRunspace = [runspacefactory]::CreateRunspace()
$childRunspace.ApartmentState = "STA"
$childRunspace.ThreadOptions = "ReuseThread"         
$childRunspace.Open()
$childRunspace.SessionStateProxy.SetVariable("syncProgress",$syncProgress)          
$Global:PsChildCmd = [PowerShell]::Create().AddScript({   
    [xml]$xaml = @"
	<Controls:MetroWindow 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		xmlns:i="http://schemas.microsoft.com/expression/2010/interactivity"				
		xmlns:Controls="clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"	
		xmlns:loadin="clr-namespace:LoadingIndicators.WPF;assembly=LoadingIndicators.WPF"				
        Name="WindowProgress" 
		WindowStyle="None" 
		AllowsTransparency="True" 
		UseNoneWindowStyle="True"	
		Width="1024" 
		Height="600" 
		WindowStartupLocation ="CenterScreen"
		Topmost="true"
		BorderBrush="Gray"
		>

<Window.Resources>
	<ResourceDictionary>
		<ResourceDictionary.MergedDictionaries>
			<!-- LoadingIndicators resources -->
			<ResourceDictionary Source="pack://application:,,,/LoadingIndicators.WPF;component/Styles.xaml"/>	
			<!-- Mahapps resources -->
			<ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml" />
			<ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml" />
			<ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Colors.xaml" />
			<ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Accents/Cobalt.xaml" />
			<ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Accents/BaseDark.xaml" />		
		</ResourceDictionary.MergedDictionaries>
	</ResourceDictionary>
</Window.Resources>			

	<Window.Background>
		<SolidColorBrush Opacity="0.7" Color="#0077D6"/>
	</Window.Background>	
		
	<Grid>	
		<StackPanel Orientation="Vertical" VerticalAlignment="Center" HorizontalAlignment="Center">		
			<StackPanel Orientation="Vertical" HorizontalAlignment="Center" Margin="0,0,0,0">	
			<!--	<Controls:ProgressRing IsActive="True" Margin="0,0,0,0"  Foreground="White" Width="50"/> -->
				<loadin:LoadingIndicator Margin="0,5,0,0" Name="ArcsRing" SpeedRatio="1" Foreground="White" IsActive="True" Style="{DynamicResource LoadingIndicatorArcsRingStyle}"/>
			</StackPanel>								
			
			<StackPanel Orientation="Vertical" HorizontalAlignment="Center" Margin="0,20,0,0">				
				<Label Name="ProgressStep" Content="Getting information about your device" FontSize="17" Margin="0,0,0,0" Foreground="White"/>	
			</StackPanel>			
		</StackPanel>		
		
	</Grid>
</Controls:MetroWindow>
"@
  
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $syncProgress.Window=[Windows.Markup.XamlReader]::Load( $reader )
    $syncProgress.Label = $syncProgress.window.FindName("ProgressStep")	

    $syncProgress.Window.ShowDialog() #| Out-Null
    $syncProgress.Error = $Error
})
}

Function Launch_modal_progress {    
    $PsChildCmd.Runspace = $childRunspace
    $Global:Childproc = $PsChildCmd.BeginInvoke()
    #$Script:Childproc = $PsChildCmd.BeginInvoke()
	
}

Function Close_modal_progress {
    $syncProgress.Window.Dispatcher.Invoke([action]{$syncProgress.Window.close()})
    $PsChildCmd.EndInvoke($Script:Childproc) | Out-Null
}

Function Create-StackPanel { 
 [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string] $StackPanelName,
        [Parameter(Position=1,Mandatory=$true)]
        [string] $StackPanelMarign,
        [Parameter(Position=2,Mandatory=$true)]
        [string] $StackPanelOrientation,
        [Parameter(Position=3)]
        [string] $StackPanelAlignment)

 
    $StackPanel = New-Object System.Windows.Controls.StackPanel
    $StackPanel.Name        = $StackPanelName 
    $StackPanel.Orientation = $StackPanelOrientation
    $StackPanel.Margin      = $StackPanelMarign
    $StackPanel.VerticalAlignment   = "Stretch"
    if($StackPanelMarign -eq "") {$StackPanel.HorizontalAlignment = "Center"}
    else{$StackPanel.HorizontalAlignment = $StackPanelAlignment} 

    return $StackPanel
}

Function Create-Label { 
 [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string] $LabelName,
        [Parameter(Position=1,Mandatory=$true)]
        [string] $LabelMargin)
 
    $Label = New-Object System.Windows.Controls.Label
    $Label.Name        = $LabelName 
    $Label.Margin      = $LabelMargin
    $Label.FontSize="16"
    
    return $Label
}

Function Create-Image { 
 [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string] $ImageName,
        [Parameter(Position=1,Mandatory=$true)]
        [string] $ImageSize,
        [Parameter(Position=2)]
        [string] $ImageMargin)
 
    $Image = New-Object System.Windows.Controls.Image
    $Image.Name        = $RadioButtonName
    if($ImageMargin -ne "") {$Image.Margin  = $ImageMargin }
    $Image.Width =$ImageSize.Split(",")[0]
    $Image.Height=$ImageSize.Split(",")[1]
    $Image.HorizontalAlignment="Center"
    $Image.VerticalAlignment="Top" 
    
    return $Image
}

Function Create-Border { 
 [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string] $BorderName,
        [Parameter(Position=1,Mandatory=$true)]
        [string] $Margin,
        [Parameter(Position=2)]
        [string] $Background)
 
    $Border = New-Object System.Windows.Controls.Border
    $Border.Name           = $BorderName 
    if(($Background -ne "") -and ($Background -ne $null)){$Border.Background     = $Background}
    $Border.HorizontalAlignment = "Stretch"
    $Border.VerticalAlignment="Stretch"
    $Border.BorderBrush = "WhiteSmoke"
    $Border.CornerRadius    = 5
    $Border.BorderThickness = 1
    $Border.Margin     = $Margin 
    return $Border
}

Function Get_Details_Infos {
		# Get printer infos
		$Win32_Printer = Get-WmiObject -Query " SELECT * FROM Win32_Printer WHERE Default=$true"
		$Printer.Content = $Win32_Printer.name	
	
		# Get BIOS infos
		$Win32_BIOS = Get-WmiObject Win32_BIOS 
		$BIOS_Version.Content = $Win32_BIOS.SMBIOSBIOSVersion

		# Check drivvers part
		$Check_Drivers_Block.Visibility = "Collapsed"
		$Missing_Drivers_Block.Visibility = "Collapsed"

		################# Test if Domain or Network	#################
		If (($Win32_ComputerSystem.partofdomain -eq $True))
			{		
				$Domain_WKG_Label.Content = "Domain:"	
				$Domain_test = $env:USERDNSDOMAIN;
			}
		Else
			{
				$Domain_WKG_Label.Content = "Workgroup name :"		
				$Domain_test = $Win32_ComputerSystem.Workgroup 	
				$AD_Site_Name = "None"	
				$Domain_part_label.Visibility = "Collapsed"
				$Domain_part_Infos.Visibility = "Collapsed"
				$My_Site_Name.Visibility = "Collapsed"		
			}	

		# Get network infos
		$win32_networkadapterconfiguration = Get-WmiObject -class "Win32_NetworkAdapterConfiguration"  | Where {$_.IPEnabled -Match "True"}
		If ($win32_networkadapterconfiguration -eq $null)
			{
				$My_IP.content = "Not connected"
			}
		Else
			{	
				Foreach ($obj in $win32_networkadapterconfiguration)
					{
						$MAC_Address = $obj.MACAddress	
						$IP_Subnet = $obj.IPsubnet[0]	
						$IP_Address = $obj.IPAddress[0]	
					}
			}
			
		# Get default printer	
		$Win32_Printer = Get-WmiObject -Query " SELECT * FROM Win32_Printer WHERE Default=$true"	
		$Default_printer = $Win32_Printer.name
			
		# Get installed antivirus	
		$Get_Antivirus = Get-WmiObject -Namespace root/SecurityCenter2 -Class AntiVirusProduct
		ForEach ($antivirus in $Get_Antivirus)
			{
				$Antivirus_list = $Antivirus_list + $antivirus.displayname 	+ " "					
			}
			
		# Get defender antivirus options
		$Get_WinDefender = Get-MpComputerStatus	
		If((($Get_WinDefender.AntispywareEnabled) -ne $True) -and (($Get_WinDefender.AntivirusEnabled) -ne $True))
			{
				$antivirus_Status_Label.Content = "Antispyware and Antivirus disabled"
				$antivirus_Status_Label.Foreground = "yellow"	
				$antivirus_Status_Label.Fontweight = "bold"				
			}
		ElseIf((($Get_WinDefender.AntispywareEnabled) -eq $True) -and (($Get_WinDefender.AntivirusEnabled) -eq $True))
			{
				$antivirus_Status_Label.Content = "Antispyware and Antivirus enabled"
			}	
		Else
			{
				If(($Get_WinDefender.AntispywareEnabled) -ne $True)
					{
						$antivirus_Status_Label.Content = "Antispyware disabled"
						$antivirus_Status_Label.Foreground = "yellow"	
						$antivirus_Status_Label.Fontweight = "bold"					
					}
				ElseIf(($Get_WinDefender.AntivirusEnabled) -ne $True)
					{
						$antivirus_Status_Label.Content = "Antivirus disabled"
						$antivirus_Status_Label.Foreground = "yellow"	
						$antivirus_Status_Label.Fontweight = "bold"					
					}			
			}
			
		If((($Get_WinDefender.AntispywareSignatureAge) -gt "3") -and (($Get_WinDefender.AntivirusSignatureAge) -gt "3"))
			{
				$antivirus_Last_Update_Label.Content = "Antispyware and Antivirus not up to date"		
				$antivirus_Last_Update_Label.Foreground = "yellow"	
				$antivirus_Last_Update_Label.Fontweight = "bold"				
			}
		ElseIf((($Get_WinDefender.AntispywareSignatureAge) -lt 3) -and (($Get_WinDefender.AntivirusSignatureAge) -lt 3))
			{
				$antivirus_Last_Update_Label.Content = "Antispyware and Antivirus up to date"
				$antivirus_Last_Update_Label.Fontweight = "Normal"						
			}	
		Else
			{
				If(($Get_WinDefender.AntispywareEnabled) -ne $True)
					{
						$antivirus_Last_Update_Label.Content = "Antispyware not up to date"
						$antivirus_Last_Update_Label.Foreground = "yellow"	
						$antivirus_Last_Update_Label.Fontweight = "bold"				
					}
				ElseIf(($Get_WinDefender.AntivirusEnabled) -ne $True)
					{
						$antivirus_Last_Update_Label.Content = "Antivirus not up to date"
						$antivirus_Last_Update_Label.Foreground = "yellow"	
						$antivirus_Last_Update_Label.Fontweight = "bold"				
						
					}			
			}	
						
		$antivirus_Last_Scan_Block.Visibility = "Collapsed"	
		$Check_LastScan_Block.Visibility = "Collapsed"		
				
		If( (($Get_WinDefender.QuickScanAge) -gt "10")) # (($Get_WinDefender.FullScanAge) -gt "10") -and
			{
				$antivirus_Last_Scan_Label.Content = "Last antivirus check > 10 days"		
				$antivirus_Last_Scan_Label.Foreground = "yellow"	
				$antivirus_Last_Update_Label.Fontweight = "normal"	
				$antivirus_Last_Scan_Block.Visibility = "Visible"	
				$Check_LastScan_Block.Visibility = "Visible"	
			}
		ElseIf((($Get_WinDefender.FullScanAge) -lt 1) -or (($Get_WinDefender.QuickScanAge) -lt 1))
			{
				$antivirus_Last_Scan_Block.Visibility = "Collapsed"	
				$Check_LastScan_Block.Visibility = "Collapsed"		
			}			
		
		$My_IP.content = "$IP_Address" + " / " + "$IP_Subnet"
		$My_MAC.content = "$MAC_Address"
		$Domain_name.content = "$Domain_test"

        If ($false) {
		    $Chart.Visibility = "Visible"
		    $Bar.Visibility = "Collapsed"
        }
		# $Get_MECM_Client_Version = (Get-WMIObject -Namespace root\ccm -Class SMS_Client  -ea silentlycontinue).ClientVersion

	# }
	
	# Get Graphic Cards info
	$Graphic_Card = (Get-CimInstance CIM_VideoController).caption	
	$Graphic_Card_info = (Get-CimInstance CIM_VideoController)
	If(($Graphic_Card_info.count) -gt 1)
		{
			ForEach ($Card in $Graphic_Card_info) ### Enum Disk 
				{
					$Graphic_Caption = $Card.Caption
					$Graphic_DriverVersion = $Card.DriverVersion
					$Graphic_Cards_with_DriverVersion = $Graphic_Cards + $Graphic_Caption + " ($Graphic_DriverVersion)" + "`n"					
					$Graphic_Cards = $Graphic_Cards + $Graphic_Caption + "`n"
				}		
		}
	Else
		{
			$Graphic_Caption = $Graphic_Card_info.Caption
			$Graphic_DriverVersion = $Graphic_Card_info.DriverVersion			
			$Graphic_Cards_with_DriverVersion = $Graphic_Cards + $Graphic_Caption + " ($Graphic_DriverVersion)" + "`n"
			$Graphic_Cards = $Graphic_Cards + $Graphic_Caption + "`n"			
		}
	$Graphic_Cards = $Graphic_Cards.trim()
	$Graphic_Cards_with_DriverVersion = $Graphic_Cards_with_DriverVersion.trim()	
	$Graphic_Card_details.Content = $Graphic_Cards_with_DriverVersion

	# Get Graphic Wifi info
	$Wifi_Card_Info = (Get-NetAdapter -name wi-fi*)
	If(($Wifi_Card_Info.count) -gt 1)
		{
			ForEach ($Card in $Wifi_Card_Info) ### Enum Disk 
				{
					$Wifi_Caption = $Card.InterfaceDescription
					$Wifi_Driver_Version = $Card.DriverVersion
					$Wifi_Cards = $Wifi_Cards + $Wifi_Caption + " ($Wifi_Driver_Version)" + "`n"
				}		
		}
	Else
		{
			$Wifi_Caption = $Wifi_Card_Info.InterfaceDescription
			$Wifi_Driver_Version = $Wifi_Card_Info.DriverVersion			
			$Wifi_Cards = $Wifi_Cards + $Wifi_Caption + " ($Wifi_Driver_Version)" + "`n"
			
		}
	$Wifi_Cards = $Wifi_Cards.trim()
	$Wifi_Card.Content = $Wifi_Cards	

    # Batteries
	If (Get-WmiObject win32_battery) {
		$Batteries_info_data = "Current charge: $((Get-WmiObject win32_battery).estimatedChargeRemaining)%" + "`n"
		# Maximum Acceptable Health Perentage
		$MinHealth = "40"

        # Multiple Battery handling
        $BatteryInstances = Get-WmiObject -Namespace "ROOT\WMI" -Class "BatteryStatus" | Select-Object -ExpandProperty InstanceName
		
        $Battery = 1
        ForEach($BatteryInstance in $BatteryInstances){

            # Set Variables for health check
            $BatteryDeviceName = Get-WmiObject -Namespace "ROOT\WMI" -Class "BatteryStaticData" | Where-Object -Property InstanceName -EQ $BatteryInstance | Select-Object -ExpandProperty DeviceName
            $BatteryDesignSpec = Get-WmiObject -Namespace "ROOT\WMI" -Class "BatteryStaticData" | Where-Object -Property InstanceName -EQ $BatteryInstance | Select-Object -ExpandProperty DesignedCapacity
            $BatteryFullCharge = Get-WmiObject -Namespace "ROOT\WMI" -Class "BatteryFullChargedCapacity" | Where-Object -Property InstanceName -EQ $BatteryInstance | Select-Object -ExpandProperty FullChargedCapacity

            # Fall back WMI class for Microsoft Surface devices
            If ($BatteryDesignSpec -eq $null -or $BatteryFullCharge -eq $null -and ((Get-WmiObject -Class Win32_BIOS | Select-Object -ExpandProperty Manufacturer) -match "Microsoft")) {
	
                # Attempt to call WMI provider
	            If (Get-WmiObject -Class MSBatteryClass -Namespace "ROOT\WMI") {
		            $MSBatteryInfo = Get-WmiObject -Class MSBatteryClass -Namespace "root\wmi" | Where-Object -Property InstanceName -EQ $BatteryInstance | Select-Object FullChargedCapacity, DesignedCapacity
		
		            # Set Variables for health check
                    $BatteryDeviceName = $MSBatteryInfo.DeviceName		            
                    $BatteryDesignSpec = $MSBatteryInfo.DesignedCapacity
		            $BatteryFullCharge = $MSBatteryInfo.FullChargedCapacity
	            }
            }
            
		    If ($BatteryDesignSpec -gt $null -and $BatteryFullCharge -gt $null) {

                # Determine battery replacement required
			    [int]$CurrentHealth = ($BatteryFullCharge/$BatteryDesignSpec) * 100
	            If ($CurrentHealth -gt 100) {
                    $CurrentHealth = 100
                }	
			    # (DesignedCapacity: $BatteryDesignSpec | FullChargedCapacity: $BatteryFullCharge)

               $Batteries_info_data = $Batteries_info_data + "Battery: $Battery | CurrentHealth: $($CurrentHealth)% " + "`n"
		    } Else {
			    # Output battery not present

		    }
            $Battery = $Battery + 1
        }
    } Else {
        $Batteries_Info.Content = "No battery present"

    }
    $Batteries_Info.Content = $Batteries_info_data
	
}

Function Get_Monitor {
		$WMI1_WmiMonitorId = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorId 
		$Global:AllMonitors = ForEach($WMI1 in $WMI1_WmiMonitorId)
			{
				$WMI1_InstanceName = $WMI1.InstanceName
				$WMI1_FriendlyName = $WMI1.UserFriendlyName

				If ($WMI1_FriendlyName -gt 0) 
					{
						$name = ($WMI1.UserFriendlyName -notmatch '^0$' | foreach {[char]$_}) -join ""
					}
				Else 
					{
						$name = 'Internal screen'
					}				
									
				$WMI2_WmiMonitorListedSupportedSourceModes = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorListedSupportedSourceModes 
				ForEach($WMI2 in $WMI2_WmiMonitorListedSupportedSourceModes)
					{
						$WMI2_InstanceName = $WMI2.InstanceName
						If($WMI1_InstanceName -eq $WMI2_InstanceName)
							{
								$maxres = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorListedSupportedSourceModes | Select-Object -ExpandProperty MonitorSourceModes | Sort-Object -Property {$_.HorizontalActivePixels * $_.VerticalActivePixels} -Descending #| Select-Object -First 1												
							}				
					}			
					
				$WMI3_WmiMonitorBasicDisplayParams = Get-WmiObject -Namespace root\wmi -Class WmiMonitorBasicDisplayParams	
				ForEach($WMI3 in $WMI3_WmiMonitorBasicDisplayParams)
					{
						$WMI3_InstanceName = $WMI3.InstanceName
						If($WMI1_InstanceName -eq $WMI3_InstanceName)
							{
								$Monitor_Size = $WMI3 | select  @{N="Computer"; E={$_.__SERVER}},
								@{N="Size";
								E={[System.Math]::Round(([System.Math]::Sqrt([System.Math]::Pow($_.MaxHorizontalImageSize, 2) + [System.Math]::Pow($_.MaxVerticalImageSize, 2))/2.54),2)}}						
							}									
					}

				$Prop = @{
				'Name' = $name
				'Serial' = (($WMI1.SerialNumberID -notmatch '^0$' | foreach {[char]$_}) -join "")
				'Size' = $Monitor_Size.size
				}
				New-Object -Type PSObject -Property $Prop				

			}
	}

Function Show_Tab_Monitor {

	Get_Monitor
	$StackPanelmain = Create-StackPanel "StackPanelAllDisk" "0,0,0,0" "Horizontal" "Center" 

    foreach ($Monitor in $AllMonitors ){             

         $StackPanelparent  = [String]("StackPparent"+$Monitor.Serial)
         $StackforPartition = [String]("StackForPart"+$Monitor.Serial)
         $Borderdisk        = [String]("BorderOf_"+$Monitor.Serial)
         $StackforPartition = Create-StackPanel  $StackforPartition "0,0,0,0" "Horizontal" "Center"
         $StackPanelparent  = Create-StackPanel  $StackPanelparent "0,0,0,0" "Vertical" "Center"  # inside the block
         $Borderdisk        = Create-Border      $Borderdisk  "10,30,0,0"
		 $Borderdisk.BorderThickness = "0"

         #======================= disk_n ==================================  
         $Titre_Label  	  = [String]("Monitor_"+$Monitor.Serial )
         $Monitor_Pic         = [String]("Monitor_"+$Monitor.Serial+"_ico" )
         $ChildSizeInfo   = [String]("Monitor_"+$Monitor.Serial+"_size" )
         $Carte_LabelInfo   = [String]("Monitor_"+$Monitor.Serial+"_size" )		
         $Serial_LabelInfo   = [String]("Monitor_"+$Monitor.Serial+"_size" )		 		 
         $StackPaneldisk  = [String]("Monitor_"+$Monitor.Serial+"_stackP" )
               
         $StackPaneldisk  = Create-StackPanel  $StackPaneldisk  "0,0,0,0" "Vertical" "Center"
         $DiskManagIco    = Create-Image       $Monitor_Pic "100,90" "5,5,0,0"
         $Titre_Label  = Create-Label       $Titre_Label  "5,0,0,0"    #Disk Id
         $Resolution_Label   = Create-Label       $ChildSizeInfo   "5,0,0,0"
         $Carte_Label   = Create-Label       $Carte_LabelInfo   "5,0,0,0"
         $Serial_Label   = Create-Label       $Serial_LabelInfo   "5,0,0,0"

         $DiskManagIco.Source    = "$Current_Folder\images\monitor.png" 
         $Titre_Label.Content = $Monitor.Name
		 $Titre_Label.FontWeight = "Bold"
		 $Titre_Label.FontSize = "20"

		 $Monitor_Size = $Monitor.size
		 $Monitor_Size = [math]::Round($Monitor_Size)
         $Resolution_Label.Content  = "Size: " + $Monitor_Size + " Inch"		 
		 $Resolution_Label.FontSize = "14"
         # $Carte_Label.Content  = $Graphic_Card
		 $Carte_Label.FontSize = "14"		 

         $Serial_Label.Content  = "Serial: " + $Monitor.serial 
		 $Serial_Label.FontSize = "14"			 
		 
         $StackPaneldisk.Children.Add($DiskManagIco)
         $StackPaneldisk.Children.Add($Titre_Label)
         $StackPaneldisk.Children.Add($Carte_Label)
         $StackPaneldisk.Children.Add($Serial_Label)		 
         $StackPaneldisk.Children.Add($Resolution_Label)
        
         $StackPanelparent.Width = 200
         $StackPanelparent.Height = 260
         $StackPanelparent.Children.Add($StackPaneldisk)

		If($my_theme -eq "BaseDark")
			{
				$Titre_Label.Foreground = "black"			
				$Carte_Label.Foreground = "black"			
				$Serial_Label.Foreground = "black"	
				$Resolution_Label.Foreground = "black"				
			}
		Else
 			{
				$Titre_Label.Foreground = "White"
				$Resolution_Label.Foreground = "White"
				$Carte_Label.Foreground = "White"
				$Serial_Label.Foreground = "White"					
			}
            
        $StackforPartition.Children.Add($StackPanelparent) 
        $Borderdisk.Child = $StackforPartition
        $StackPanelmain.Children.Add($Borderdisk)
    }  
    $MonitorList.Children.Add($StackPanelmain)      
}

Function Get_Disk_Infos {

		$Total_size = [Math]::Round(($Win32_LogicalDisk.size/1GB),1)
		$Free_size = [Math]::Round(($Win32_LogicalDisk.Freespace/1GB),1) 
		$Disk_information =  $Disk_information + "(" + $Win32_LogicalDisk.deviceid + ") " + $Total_size + " GB (Total size) / " +  + $Free_size + " GB (Free space) `n"
		$My_Disk_Info.Content = $Disk_information
			
		If($Free_size -lt 1)
			{
				$Disk_Warning.Content = "(Low disk space)"
				$Disk_Warning.Foreground = "yellow"
				$Disk_Warning.FontWeight = "bold"		
				
				$My_Disk_Info.Foreground = "yellow"
				$My_Disk_Info.FontWeight = "bold"			
			}
		Else
			{
				$Disk_Warning.Visibility = "Collapsed"
			}	
}

Function Get_Overview_Infos {
		$User = $env:USERPROFILE
		$ProgData = $env:PROGRAMDATA 
		$Win32_BIOS = Get-CimInstance Win32_BIOS -OperationTimeoutSec 30
		$Win32_OperatingSystem = Get-CimInstance Win32_OperatingSystem -OperationTimeoutSec 30
		$Manufacturer = $Win32_ComputerSystem.manufacturer	
		$MTM = $Win32_ComputerSystem.Model
		$Serial_Number = $Win32_BIOS.SerialNumber
		$Memory_RAM = [Math]::Round(($Win32_ComputerSystem.TotalPhysicalMemory/ 1GB),1) 
		$REG_OS_Version = Get-ItemProperty -Path registry::"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction 'silentlycontinue'

		$OS_Ver = $Win32_OperatingSystem.version
		$Build_number = $Win32_OperatingSystem.buildnumber
		If ($OS_Ver -like "10*")
			{
                $OS_UBR = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name UBR).UBR
				$OS_ReleaseID =  $REG_OS_Version.ReleaseID
				$OS_DisplayVersion =  $REG_OS_Version.DisplayVersion
				If($OS_DisplayVersion -ne $null)
					{
						$Release = $OS_DisplayVersion
					}
				Else	
					{
						$Release = $OS_ReleaseID
					}
			}
		Else
			{
				$Release = ""
			}
			
		If($Manufacturer -like "*lenovo*")
			{
				# $Computer_Model = ((Get-WmiObject -Class:Win32_ComputerSystem).Model).Substring(0,4)
				#$Computer_Model = ($Win32_ComputerSystem.Model).Substring(0,4)
                $Computer_Model = (Get-WmiObject -class Win32_ComputerSystemProduct).Version		
			}
		Else
			{
				$Computer_Model = ($Win32_ComputerSystem.Model)	
			}
		$Device_Model.Content = "Computer model: $Computer_Model"				

		$PC_Name.Content = "Device name: " + $env:computername	
		$OS_Version.Content =  "Windows 10 $(if ($OS_Ver -like "10*") { "($Release - UBR: $OS_UBR)" })"
		$Username.Content = "My user name: " + $env:username
		$Memory.Content = "Memory (RAM): $Memory_RAM GB"
		$Serial.Content = "Serial number: $Serial_Number"

        If ($(TestRegistryValue -Path "HKLM:\Software\TeamViewer" -Name "ClientID") -or (TestRegistryValue -Path "HKLM:\Software\WOW6432Node\TeamViewer" -Name "ClientID")) {
            If (TestRegistryValue -Path "HKLM:\Software\TeamViewer" -Name "ClientID") {
                [string]$TeamViewerID = $((Get-ItemProperty -Path "HKLM:\Software\TeamViewer" -ErrorAction SilentlyContinue)."ClientID")
            } Else {
                [string]$TeamViewerID = $((Get-ItemProperty -Path "HKLM:\Software\WOW6432Node\TeamViewer" -ErrorAction SilentlyContinue)."ClientID")
            }
            $count = $TeamViewerID | Measure-Object -Character
            If ($count.Characters -eq 9) {
                    $TeamViewerID = "$($TeamViewerID.SubString(0,3)) $($TeamViewerID.SubString(3,3)) $($TeamViewerID.SubString(6,3))"
                } ElseIf ($count.Characters -eq 10) {
                    $TeamViewerID = "$($TeamViewerID.SubString(0,1)) $($TeamViewerID.SubString(1,3)) $($TeamViewerID.SubString(4,3)) $($TeamViewerID.SubString(7,3))"
                } Else {

                }
            $TeamViewer.Content = "TeamViewer ID: $TeamViewerID"
  
        } Else {
            $TeamViewer.Content = "TeamViewer missing"
        }

        $wireless = netsh wlan show interfaces
        If ($wireless.Count -gt 1) {
            $ssid1 = $wireless | Select-String '\sSSID'
            $signal1 = $wireless | Select-String '\sSignal'
            $radiotype1 = $wireless | Select-String '\sRadio Type'
            $channel1 = $wireless | Select-String '\sChannel'
            $state1 = $wireless | Select-String '\sState'
            
            # Split string
            $ssid1 = $ssid1 -split ":"
            $signal1 = $signal1 -split ":"
            $radiotype1 = $radiotype1 -split ":"
            $channel1 = $channel1 -split ":"
            $state1 = $state1 -split ":"
            
            # Select the second value and replace spaces
            $ssid = $ssid1[1] -replace '\s',''
            $signal = $signal1[1] -replace '\s',''
            $radiotype = $radiotype1[1] -replace '\s',''
            $channel = $channel1[1] -replace '\s',''
            $state = $state1[1] -replace '\s',''
            If ([int]$channel -lt 14) {
                $channelMode = "2.4 GHz"
            } else {
                $channelMode = "5 GHz"
            }
            If ($state -eq "Connected") {
                    $WirelessInfo.Content = "Wireless: $ssid Signal: $signal Mode: $channelMode"
            } Else {
                #"-- No wireless connected"
            }
        } Else {
            #"-- No wireless connected"
        }           	
	}

Function Show_Tab_Links {

	$StackPanelmain = Create-StackPanel "StackPanelAllDisk" "0,0,0,0" "Horizontal" "Center" 

    foreach ($Monitor in $AllMonitors ){             

         $StackPanelparent  = [String]("StackPparent"+$Monitor.Serial)
         $StackforPartition = [String]("StackForPart"+$Monitor.Serial)
         $Borderdisk        = [String]("BorderOf_"+$Monitor.Serial)
         $StackforPartition = Create-StackPanel  $StackforPartition "0,0,0,0" "Horizontal" "Center"
         $StackPanelparent  = Create-StackPanel  $StackPanelparent "0,0,0,0" "Vertical" "Center"  # inside the block
         $Borderdisk        = Create-Border      $Borderdisk  "10,30,0,0"
		 $Borderdisk.BorderThickness = "0"

         #======================= disk_n ==================================  
         $Titre_Label  	  = [String]("Monitor_"+$Monitor.Serial )
         $Monitor_Pic         = [String]("Monitor_"+$Monitor.Serial+"_ico" )
         $ChildSizeInfo   = [String]("Monitor_"+$Monitor.Serial+"_size" )
         $Carte_LabelInfo   = [String]("Monitor_"+$Monitor.Serial+"_size" )		
         $Serial_LabelInfo   = [String]("Monitor_"+$Monitor.Serial+"_size" )		 		 
         $StackPaneldisk  = [String]("Monitor_"+$Monitor.Serial+"_stackP" )
               
         $StackPaneldisk  = Create-StackPanel  $StackPaneldisk  "0,0,0,0" "Vertical" "Center"
         $DiskManagIco    = Create-Image       $Monitor_Pic "100,90" "5,5,0,0"
         $Titre_Label  = Create-Label       $Titre_Label  "5,0,0,0"    #Disk Id
         $Resolution_Label   = Create-Label       $ChildSizeInfo   "5,0,0,0"
         $Carte_Label   = Create-Label       $Carte_LabelInfo   "5,0,0,0"
         $Serial_Label   = Create-Label       $Serial_LabelInfo   "5,0,0,0"

         $DiskManagIco.Source    = "$Current_Folder\images\monitor.png" 
         $Titre_Label.Content = $Monitor.Name
		 $Titre_Label.FontWeight = "Bold"
		 $Titre_Label.FontSize = "20"

		 $Monitor_Size = $Monitor.size
		 $Monitor_Size = [math]::Round($Monitor_Size)
         $Resolution_Label.Content  = "Size: " + $Monitor_Size + " Inch"		 
		 $Resolution_Label.FontSize = "14"
         # $Carte_Label.Content  = $Graphic_Card
		 $Carte_Label.FontSize = "14"		 

         $Serial_Label.Content  = "Serial: " + $Monitor.serial 
		 $Serial_Label.FontSize = "14"			 
		 
         $StackPaneldisk.Children.Add($DiskManagIco)
         $StackPaneldisk.Children.Add($Titre_Label)
         $StackPaneldisk.Children.Add($Carte_Label)
         $StackPaneldisk.Children.Add($Serial_Label)		 
         $StackPaneldisk.Children.Add($Resolution_Label)
        
         $StackPanelparent.Width = 200
         $StackPanelparent.Height = 260
         $StackPanelparent.Children.Add($StackPaneldisk)

		If($my_theme -eq "BaseDark")
			{
				$Titre_Label.Foreground = "black"			
				$Carte_Label.Foreground = "black"			
				$Serial_Label.Foreground = "black"	
				$Resolution_Label.Foreground = "black"				
			}
		Else
 			{
				$Titre_Label.Foreground = "White"
				$Resolution_Label.Foreground = "White"
				$Carte_Label.Foreground = "White"
				$Serial_Label.Foreground = "White"					
			}
            
        $StackforPartition.Children.Add($StackPanelparent) 
        $Borderdisk.Child = $StackforPartition
        $StackPanelmain.Children.Add($Borderdisk)
    }  
    $MonitorList.Children.Add($StackPanelmain)      
}

Function Set_VPN_Troubleshooting_Info {
    $IPInfo = Invoke-RestMethod http://ipinfo.io/json 
    $Global:VPN_Troubleshooting_IPAddress.Content = "IP: $($IPInfo.ip)"
    $Global:VPN_Troubleshooting_City.Content = "City: $($IPInfo.city)"
    $Global:VPN_Troubleshooting_Region.Content = "Region: $($IPInfo.region)"
    $Global:VPN_Troubleshooting_Country.Content = "Country: $($IPInfo.country)"
}

Function Show_Tab_VPN {
    If (! (Get-VpnConnection -ConnectionName $VPNName -ErrorAction SilentlyContinue)) {

        $Global:VPN_LeftBlock_VPNDetected.Visibility = "Collapsed"
        $Global:VPN_FooterBlock.Visibility = "Collapsed"
        $Global:VPN_LeftBlock_NoVPNDetected.Visibility = "Visible"

        $Certs = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object {$_.Subject -match "$MatchUserCertificate"}
        $CountCerts = 0
        ForEach ($Cert in $Certs) {
            $CountCerts += 1
        }
        If ($countCerts -eq 0) {
            $Global:VPN_NoVPNDetected_Error.Content = "User certificate not found, contact Service Desk"
        } else {
            $Global:VPN_NoVPNDetected_Error.Content = "Please install it from Software Center or contact Service Desk"
        }
    } else {

        $Global:VPN_LeftBlock_NoVPNDetected.Visibility = "Collapsed"
        $Global:VPN_LeftBlock_VPNDetected.Visibility = "Visible"
        $Global:VPN_FooterBlock.Visibility = "Visible"

        $global:CurrentServerAddress = $(Get-VpnConnection -ConnectionName $VPNName).ServerAddress
        $ConnectionStatus = $(Get-VpnConnection -ConnectionName $VPNName).ConnectionStatus

        $global:CurrentServer = ""
        for($i = 0; $i -lt $VPNSites.Length; $i++){
            If ($VPNSites[$i].ServerAddress -eq $CurrentServerAddress) {
                $global:CurrentServer = $VPNSites[$i].Name
            }
        }
        If ($global:CurrentServer -eq $Null -or $global:CurrentServer -eq "") {
            $global:CurrentServer = "Please choose a new!"
        }

        $Global:VPN_Settings_CurrentServer.Content = "Current site: $CurrentServer"

        If ($ConnectionStatus -eq "Disconnected") {
            $global:VPN_Btn_Disconnect.Visibility = "Collapsed"
            $global:VPN_Connected_IP.Visibility = "Collapsed"
            $global:VPN_Connected_Site.Visibility = "Collapsed"

            If ((Resolve-DNSName $CheckInternalServerName -ErrorAction SilentlyContinue).IPAddress -eq "$CheckInternalServerIPAddress") {
                $Global:VPN_Settings_CurrentStatus.Content = "On Company Network, can't connect to VPN"
                $global:VPN_Btn_Connect.Visibility = "Collapsed"
            } else {
                $global:VPN_Settings_CurrentStatus.Visibility = "Collapsed"
                $global:VPN_Btn_Connect.Visibility = "Visible"
            }
        } Else {
            $global:VPN_Btn_Disconnect.Visibility = "Visible"
            $global:VPN_Btn_Connect.Visibility = "Collapsed"
            $global:VPN_Settings_CurrentStatus.Visibility = "Collapsed"
            $global:VPN_Connected_IP.Visibility = "Visible"
            $global:VPN_Connected_Site.Visibility = "Visible"

            If ($ConnectionStatus -eq "Connected" -or $ConnectionStatus -eq "Dormant") {
                $CurrentIPAddress = $(Get-WmiObject MSFT_NetIPAddress -Namespace 'root/standardcimv2' | Where-Object InterfaceAlias -like "$VPNName").IPAddress
                $Global:VPN_Connected_IP.Content = "IP Address: $CurrentIPAddress"

                $Global:CurrentConnectedSite = ""
                For($i = 0; $i -lt $VPNSubnets.Length; $i++){
                    If (IsIpAddressInRange $CurrentIPAddress  $($(Get-IPV4NetworkStartIP $VPNSubnets[$i].ServerSubnet).IPAddressToString) $($(Get-IPV4NetworkEndIP $VPNSubnets[$i].ServerSubnet).IPAddressToString) ) {
                        $CurrentConnectedSite = $VPNSubnets[$i].Name
                    } 
                }
                If ($CurrentConnectedSite -eq $Null -or $CurrentConnectedSite -eq "") {
                    $CurrentConnectedSite = "Could not determine site!"
                }

 
                $Global:VPN_Connected_Site.Content = "Site: $CurrentConnectedSite"

            }
        }
    }
    
}

Function VPN_Change_Site {

$xamlDialog1  = LoadXml("$($current_folder)\resources\VPN_Change_Site.xaml")
$read=(New-Object System.Xml.XmlNodeReader $xamlDialog1)
$DialogForm1=[Windows.Markup.XamlReader]::Load( $read )

# Create a new Dialog attached to Main Form
$global:CustomDialog1  = [MahApps.Metro.Controls.Dialogs.CustomDialog]::new($Form)
$CustomDialog1.AddChild($DialogForm1)
$settings             = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
$settings.ColorScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Theme

$global:DialogDropdownSite  = $DialogForm1.FindName("DropdownSite")
$global:DialogBtnClose    = $DialogForm1.FindName("BtnClose")
$global:DialogBtnChange    = $DialogForm1.FindName("BtnChangeSite")
       
        ForEach ($Site in $VPNSites)
        {
            If ($Site.Name -eq $CurrentServer) {
                
            } Else {
                $DialogDropdownSite.Items.Add($Site.Name)
            }
        }

    $Result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($Form, $CustomDialog1, $settings)

    $global:DialogbtnClose.add_Click({
        # Close the Custom Dialog
        $CustomDialog1.RequestCloseAsync()
    })
    $global:DialogbtnChange.add_Click({
        $CustomDialog1.RequestCloseAsync()
        VPN_Set_Site
    })

}

Function VPN_Set_Site {

    $sitetemp = $DialogDropdownSite.SelectedItem.ToString()
    for($i = 0; $i -lt $VPNSites.Length; $i++){
        If ($VPNSites[$i].Name -eq $sitetemp) {
            $VPNServerAddress = $VPNSites[$i].ServerAddress
        }
    }
    
    Set-VpnConnection -Name $VPNName -ServerAddress $VPNServerAddress -ErrorAction SilentlyContinue

    Show_Tab_VPN

    $DialogMessage.Content = "Site changed to: $sitetemp" 
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)

    $DialogbtnClose.add_Click({
        # Close the Custom Dialog
        $CustomDialog.RequestCloseAsync()
            
    })
}

Function DisconnectVPN {
    If ($(Get-VpnConnection -ConnectionName $VPNName).ConnectionStatus -eq "Connected" -or $(Get-VpnConnection -ConnectionName $VPNName).ConnectionStatus -eq "Connecting"){
        $cmd = $env:WINDIR + "\System32\rasdial.exe"
        $expression = "$cmd ""$VPNName"" /disconnect"
        Invoke-Expression -Command $expression -OutVariable output

        $xamlDialog1  = LoadXml("$($current_folder)\resources\VPN_Disconnect.xaml")
        $read=(New-Object System.Xml.XmlNodeReader $xamlDialog1)
        $DialogForm1=[Windows.Markup.XamlReader]::Load( $read )

        # Create a new Dialog attached to Main Form
        $global:CustomDialog1  = [MahApps.Metro.Controls.Dialogs.CustomDialog]::new($Form)
        $CustomDialog1.AddChild($DialogForm1)
        $settings             = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
        $settings.ColorScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Theme

        $global:TextBlock  = $DialogForm1.FindName("TextBlock")
        $global:BtnClose   = $DialogForm1.FindName("BtnClose")

        #.Add($(TextFormatting -Text 'OS Version: ' ))   -FontSize 16 -Bold -Italic -TextDecorations Underline
        ForEach ($line in $output) {
            If ($line -eq "Command completed successfully.") {
                $TextBlock.Inlines.Add("Successfully disconnected, you may close this window`n")

            } else {
                $TextBlock.Inlines.Add("$line `n")
            }
        }

        $Result = [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($Form, $CustomDialog1, $settings)
    
        $global:BtnClose.add_Click({
            Show_Tab_VPN
            $CustomDialog1.RequestCloseAsync()

        })

    }
} 

Function ConnectVPN {
    If ($(Get-VpnConnection -ConnectionName $VPNName).ConnectionStatus -eq "Disconnected"){
        $success = $null

        $xamlDialog1  = LoadXml("$($current_folder)\resources\VPN_Connect.xaml")
        $read=(New-Object System.Xml.XmlNodeReader $xamlDialog1)
        $DialogForm1=[Windows.Markup.XamlReader]::Load( $read )

        # Create a new Dialog attached to Main Form
        $global:CustomDialog1  = [MahApps.Metro.Controls.Dialogs.CustomDialog]::new($Form)
        $CustomDialog1.AddChild($DialogForm1)
        $settings             = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
        $settings.ColorScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Theme

        $global:TextBlock  = $DialogForm1.FindName("TextBlock")
        $global:DialogBtnClose    = $DialogForm1.FindName("BtnClose")

        $cmd = $env:WINDIR + "\System32\rasdial.exe"
        $expression = "$cmd ""$VPNName"""
        Invoke-Expression -Command $expression -OutVariable output
        
        #.Add($(TextFormatting -Text 'OS Version: ' ))   -FontSize 16 -Bold -Italic -TextDecorations Underline
        ForEach ($line in $output) {
            If ( $line -notmatch "Connecting to") {
                If ($line -eq "Successfully connected to $VPNName.") {
                    $success = $True
                    $TextBlock.Inlines.Add($(TextFormatting -Text "$line" -Bold -FontSize 14))
                    $TextBlock.Inlines.Add("`n")
                } elseIf ($success -and $line -eq "Command completed successfully.") {
                    $TextBlock.Inlines.Add("You may close this window`n")
                } elseIf ($line -eq "" -or $line -match "For more help on this error" -or $line -match "Type 'hh netcfg.chm'" -or $line -match "in help, click Troubleshooting") {
                
                } else {
                    $TextBlock.Inlines.Add("$line `n")
                }
            }
        }
                      
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($Form, $CustomDialog1, $settings)

        $global:DialogBtnClose.add_Click({
            Show_Tab_VPN
            $CustomDialog1.RequestCloseAsync()

        })

        }
}

Function RepairVPN {
    $VPNVersion = "20210401"
    If ($True) {
                ################################
                # VARIABLES
                $Name = "Company VPN"
                $ServerAddress = "vpn.company.com" # IP Address or FQDN
                $TunnelType = "IKEv2" # Values: PPTP | L2TP | SSTP | IKEv2 | Automatic
                $AuthenticationMethod = "EAP" # Values: PAP | CHAP | MSCHAPv2 | EAP
                $EAPSettings = '
                        
                '
                $EncryptionLevel = "Maximum" # Values: NoEncryption | Optional | Required | Maximum
                $SplitTunneling = $true
                $DnsSuffix = "ad.company.com"
                $DnsSuffixSearchList = "ad.company.com" #, "company.local"
                ################################
    
                # Create the VPN connection
                If (Get-VpnConnection -ConnectionName $Name -ErrorAction SilentlyContinue) {
                    # "Exist"
                    Set-VpnConnection -Name $Name -ServerAddress $ServerAddress -TunnelType $TunnelType
                } else {
                    Add-VpnConnection -Name $Name -ServerAddress $ServerAddress -TunnelType $TunnelType -ErrorAction SilentlyContinue
                }
        
                # Do a reset of settings in case of we had a previous connection
                Set-VpnConnectionIpSecConfiguration -ConnectionName $Name -RevertToDefault -Force
    
                # Set the EAP settings and encryption
                Set-VpnConnection -ConnectionName $Name -AuthenticationMethod $AuthenticationMethod -EncryptionLevel $EncryptionLevel -Force -EapConfigXmlStream $EAPSettings
                Set-VpnConnectionIPsecConfiguration -ConnectionName $Name -AuthenticationTransformConstants SHA256128 -CipherTransformConstants AES128 -DHGroup Group14 -EncryptionMethod AES128 -IntegrityCheckMethod SHA256 -PFSgroup PFS2048 -Force

                # Create routes for specific systems
                Add-VpnConnectionRoute -ConnectionName $Name -DestinationPrefix "10.10.110.0/25" -PassThru # Specal subnet....

                # Configure split tunneling and DNS
                Set-VpnConnection -ConnectionName $Name -SplitTunneling $SplitTunneling # -DnsSuffix $DnsSuffix
                Set-VpnConnectionTriggerDnsConfiguration -ConnectionName $Name  -DnsSuffixSearchList $DnsSuffixSearchList -PassThru  -Force

                # Set "Register this connections address in DNS
                $RASPhoneBook = "$([Environment]::GetFolderPath('ApplicationData'))\Microsoft\Network\Connections\Pbk\rasphone.pbk"
                If (Test-Path($RASPhoneBook)) {
                    (Get-Content $RASPhoneBook) -Replace 'IpDnsFlags=0', 'IpDnsFlags=3' | Set-Content $RASPhoneBook
                } else {
                    #Write-Log -Message "--- No Access to rasphone.pbk"
                }

                # Set custom metric from Automatic to 1
                $RASPhoneBook = "$([Environment]::GetFolderPath('ApplicationData'))\Microsoft\Network\Connections\Pbk\rasphone.pbk"
                If (Test-Path($RASPhoneBook)) {
                    (Get-Content $RASPhoneBook) -Replace 'IpInterfaceMetric=0', 'IpInterfaceMetric=1' | Set-Content $RASPhoneBook
                } else {
                    #Write-Log -Message "--- No Access to rasphone.pbk"
                }


                CreateRegistryKey -Path "HKCU:\Company" -Name "VPNVersion" -PropertyType String -Value $VPNVersion

                #Write-Log -Message "--- VPN installed"
        } 

    $DialogMessage.Content = "Permobil VPN has been repaired" 
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)

    $DialogbtnClose.add_Click({
        # Close the Custom Dialog
        $CustomDialog.RequestCloseAsync()
            
    })
}

Function Get-ProcessWithOwner { 
        param( 
            [parameter(mandatory=$true,position=0)]$ProcessName 
        ) 
        $ComputerName=$env:COMPUTERNAME 
        $UserName=$env:USERNAME 
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($(New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$('ProcessName','UserName','Domain','ComputerName','handle')))) 
        try { 
            $Processes = Get-wmiobject -Class Win32_Process -ComputerName $ComputerName -Filter "name LIKE '$ProcessName%'" 
        } catch { 
            return -1 
        } 
        if ($Processes -ne $null) { 
            $OwnedProcesses = @() 
            foreach ($Process in $Processes) { 
                if($Process.GetOwner().User -eq $UserName){ 
                    $Process |  
                    Add-Member -MemberType NoteProperty -Name 'Domain' -Value $($Process.getowner().domain) 
                    $Process | 
                    Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $ComputerName  
                    $Process | 
                    Add-Member -MemberType NoteProperty -Name 'UserName' -Value $($Process.GetOwner().User)  
                    $Process |  
                    Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers 
                    $OwnedProcesses += $Process 
                } 
            } 
            return $OwnedProcesses 
        } else { 
            return 0 
        } 
 
    } 

Function Restart_Explorer {
        "---- Restarting Explorer.exe to make the drive(s) visible"
        #kill all running explorer instances of this user 
        $explorerStatus = Get-ProcessWithOwner explorer 
        if($explorerStatus -eq 0){ 
            "---- WARNING: no instances of Explorer running yet, at least one should be running"
        }elseif($explorerStatus -eq -1){ 
            "---- ERROR Checking status of Explorer.exe: unable to query WMI"
        }else{ 
            "---- Detected running Explorer processes, attempting to shut them down..." 
            foreach($Process in $explorerStatus){ 
                try{ 
                    Stop-Process $Process.handle | Out-Null 
                    "---- Stopped process with handle $($Process.handle)" 
                }catch{ 
                    "---- Failed to kill process with handle $($Process.handle)"
                } 
            } 
        } 
    } 

Function CreateRegistryKey {
<# 
.Synopsis 
    
.DESCRIPTION 
   
.NOTES 
   Created by: Daniel Sjogren 
   Modified: 2016-12-20    
 
   Changelog: 
    * 
 
   To Do: 
    * 

.PARAMETER  

.EXAMPLE 
 
#>
        param (

            [parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]$Path,

            [parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]$Name,

            [parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]$PropertyType,

            [parameter(Mandatory=$true)]
            $Value
        )
        Begin { 
            # Set VerbosePreference to Continue so that verbose messages are displayed. 
            $VerbosePreference = 'Continue' 
        } 
        Process {     
            if (!(test-path ($Path))) { 
                Try { 
                    New-item -path $Path -Force -ErrorAction Stop | out-null
                    #Write-Log -Message "-- Created: $Path"
                } catch { #Write-Log -Message "--- Caught an exception with type '$($_.Exception.GetType().FullName)' and message '$($_.Exception.Message)' and HResult '$($_.Exception.HResult)' " 
                } 
            }
            If ($PropertyType -eq "DEFAULT") {
                Try { 
                    Set-Item -Path $Path -Value $Value -Force -ErrorAction Stop | out-null
                    #Write-Log -Message "-- Created default value: $Value"
                } catch { #Write-Log -Message "--- Caught an exception with type '$($_.Exception.GetType().FullName)' and message '$($_.Exception.Message)' and HResult '$($_.Exception.HResult)' " 
                } 
            } else {

                If ($value -eq "NULL") { $value = $NULL }
                Try {
                    New-ItemProperty -Path $Path -Name $Name -PropertyType $PropertyType -Value $Value -Force -ErrorAction Stop | out-null
                    #Write-Log -Message "-- Created: $Path"
                } catch { #Write-Log -Message "--- Caught an exception with type '$($_.Exception.GetType().FullName)' and message '$($_.Exception.Message)' and HResult '$($_.Exception.HResult)' " 
                }
            }
    
        }
        End {}
    }

Function TestRegistryValue {
    <# 
    .Synopsis 
    
    .DESCRIPTION 
   
    .NOTES 
       Created by: Daniel Sjogren 
       Modified: 2016-12-20    
 
       Changelog: 
        * 
 
       To Do: 
        * 

    .PARAMETER  

    .EXAMPLE 
 
    #>
        param (

            [parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]$Path,

            [parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]$Name
        )
        Begin {} 
        Process { 
            $exists = Get-ItemProperty -Path "$Path" -Name "$Name" -ErrorAction SilentlyContinue
            If (($exists -ne $null) -and ($exists.Length -ne 0)) {
                Return $true
            }
            Return $false
        }
        End {}
    }
  
Function GETRandomPassword() {
        Param(
            [int]$length=10,
            [string[]]$sourcedata
        )
        For ($loop=1; $loop -le $length; $loop++) {
            $TempPassword+=($sourcedata | GET-RANDOM)
        }
        return $TempPassword

    }

Function Test-PasswordComplexity {
        Param (
            [Parameter(Mandatory=$true)][string]$Password
        )
        If (
            ($Password -cmatch "[A-Z\p{Lu}\s]") `
            -and ($Password -cmatch "[a-z\p{Ll}\s]") `
            -and ($Password -match "[\d]") `
            -and ($Password -match "[^\w]")  
        ) { 
            return $true 
        } else { 
            return $false
        }

    }

Function Tools_GeneratePassword {

        $Characters = ([char[]]([char]33)) + ([char[]]([char]35..[char]36) + ([char[]]([char]40..[char]42)) + ([char[]]([char]49..[char]57)) + ([char[]]([char]63..[char]72)) + ([char[]]([char]74..[char]78)) + ([char[]]([char]80..[char]90)) + ([char[]]([char]97..[char]104)) + ([char[]]([char]106..[char]107)) + ([char[]]([char]109..[char]110)) + ([char[]]([char]112..[char]122)) )

        # Ask for Length
        if ($True) {
            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")| out-null
            [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | out-null

            $TempForm               = New-Object System.Windows.Forms.Form 
            $TempForm.Text          = "Generate password"
            $TempForm.Size          = New-Object System.Drawing.Size(300,150) 
            $TempForm.StartPosition = "CenterScreen"
            $TempForm.AutoScalemode = "Dpi"
            $TempForm.BackColor     = [System.Drawing.Color]::FromArgb(255,255,255) 
            $TempForm.Font          = $Font

            $Button                 = New-Object System.Windows.Forms.Button
            $Button.Location        = New-Object System.Drawing.Point(12,60)
            $Button.Size            = New-Object System.Drawing.Size(75,23)
            $Button.Font            = $Font
            $Button.BackColor       = $ButtonBackColor
            $Button.ForeColor       = $ButtonForeColor
            $Button.FlatStyle       = $ButtonFlatStyle
            $Button.Text            = "OK"
            $Button.DialogResult    = [System.Windows.Forms.DialogResult]::OK
            $TempForm.AcceptButton  = $Button
            $TempForm.Controls.Add($Button)

            $Label                  = New-Object System.Windows.Forms.Label
            $Label.Location         = New-Object System.Drawing.Point(10,10) 
            $Label.Size             = New-Object System.Drawing.Size(200,20) 
            $Label.Font             = $Font9
            $Label.Text             = "Length:"
            $TempForm.Controls.Add($Label) 

            $TextBox                = New-Object System.Windows.Forms.TextBox 
            $TextBox.Location       = New-Object System.Drawing.Point(12,30) 
            $TextBox.Size           = New-Object System.Drawing.Size(260,20)
            $TextBox.Text           = "13"
            $TempForm.Controls.Add($TextBox) 

            $TempForm.Topmost       = $True

            $TempForm.Add_Shown({$TextBox.Select()})
            $Result = $TempForm.ShowDialog()

            if ($Result -eq [System.Windows.Forms.DialogResult]::OK)
            {
                $Length = $TextBox.Text
                if ($Length -eq $NULL -or $Length.Length -lt 1 ) {
                $TempForm.Close()
                $TempForm.Dispose()
            }
        }


        }

        DO {
            $PW = GetRandomPassword -length $Length -sourcedata $Characters
            #$PW
        } Until (Test-PasswordComplexity $PW)

        # Display generated password
        if ($True) {
            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")| out-null
            [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | out-null

            $TempForm               = New-Object System.Windows.Forms.Form 
            $TempForm.Text          = "Generate password"
            $TempForm.Size          = New-Object System.Drawing.Size(300,150) 
            $TempForm.StartPosition = "CenterScreen"
            $TempForm.AutoScalemode = "Dpi"
            $TempForm.BackColor     = [System.Drawing.Color]::FromArgb(255,255,255) 
            $TempForm.Font          = $Font

            $Button                 = New-Object System.Windows.Forms.Button
            $Button.Location        = New-Object System.Drawing.Point(12,60)
            $Button.Size            = New-Object System.Drawing.Size(75,23)
            $Button.Font            = $Font
            $Button.BackColor       = $ButtonBackColor
            $Button.ForeColor       = $ButtonForeColor
            $Button.FlatStyle       = $ButtonFlatStyle
            $Button.Text            = "OK"
            $Button.DialogResult    = [System.Windows.Forms.DialogResult]::OK
            $TempForm.AcceptButton  = $Button
            $TempForm.Controls.Add($Button)

            $Label                  = New-Object System.Windows.Forms.Label
            $Label.Location         = New-Object System.Drawing.Point(10,10) 
            $Label.Size             = New-Object System.Drawing.Size(200,20) 
            $Label.Font             = $Font9
            $Label.Text             = "Generated Password:"
            $TempForm.Controls.Add($Label) 

            $TextBox                = New-Object System.Windows.Forms.TextBox 
            $TextBox.Location       = New-Object System.Drawing.Point(12,30) 
            $TextBox.Size           = New-Object System.Drawing.Size(260,20) 
            $TextBox.Text           = $PW
            $TempForm.Controls.Add($TextBox) 

            $TempForm.Topmost = $True

            $TempForm.Add_Shown({$TextBox.Select()})
            $Result = $TempForm.ShowDialog()
        }
    }

Function Get-IPV4NetworkStartIP ($strNetwork) {
    $StrNetworkAddress = ($strNetwork.split("/"))[0]
    $NetworkIP = ([System.Net.IPAddress]$StrNetworkAddress).GetAddressBytes()
    [Array]::Reverse($NetworkIP)
    $NetworkIP = ([System.Net.IPAddress]($NetworkIP -join ".")).Address
    $StartIP = $NetworkIP +1
    #Convert To Double
    If (($StartIP.Gettype()).Name -ine "double")
    {
    $StartIP = [Convert]::ToDouble($StartIP)
    }
    $StartIP = [System.Net.IPAddress]$StartIP
    Return $StartIP
}

Function Get-IPV4NetworkEndIP ($strNetwork) {
    $StrNetworkAddress = ($strNetwork.split("/"))[0]
    [int]$NetworkLength = ($strNetwork.split("/"))[1]
    $IPLength = 32-$NetworkLength
    $NumberOfIPs = ([System.Math]::Pow(2, $IPLength)) -1
    $NetworkIP = ([System.Net.IPAddress]$StrNetworkAddress).GetAddressBytes()
    [Array]::Reverse($NetworkIP)
    $NetworkIP = ([System.Net.IPAddress]($NetworkIP -join ".")).Address
    $EndIP = $NetworkIP + $NumberOfIPs
    If (($EndIP.Gettype()).Name -ine "double")
    {
    $EndIP = [Convert]::ToDouble($EndIP)
    }
    $EndIP = [System.Net.IPAddress]$EndIP
    Return $EndIP
}

Function IsIpAddressInRange {
param(
        [string] $ipAddress,
        [string] $fromAddress,
        [string] $toAddress
    )
 
    $ip = [system.net.ipaddress]::Parse($ipAddress).GetAddressBytes()
    [array]::Reverse($ip)
    $ip = [system.BitConverter]::ToUInt32($ip, 0)
 
    $from = [system.net.ipaddress]::Parse($fromAddress).GetAddressBytes()
    [array]::Reverse($from)
    $from = [system.BitConverter]::ToUInt32($from, 0)
 
    $to = [system.net.ipaddress]::Parse($toAddress).GetAddressBytes()
    [array]::Reverse($to)
    $to = [system.BitConverter]::ToUInt32($to, 0)
 
    $from -le $ip -and $ip -le $to
}

Function GatherInformation {
    $Global:LastRefresh = Get-Date
    $Win32_ComputerSystem = Get-ciminstance Win32_ComputerSystem -OperationTimeoutSec 30
    $Win32_LogicalDisk = Get-ciminstance Win32_LogicalDisk -OperationTimeoutSec 30 | where {$_.DeviceID -eq "C:"}

    $Get_MECM_Client_Version = (Get-WMIObject -Namespace root\ccm -Class SMS_Client -ea silentlycontinue).ClientVersion
    If($Get_MECM_Client_Version -eq $null) {
		$MECM_Client_Version_Block.Visibility = "Collapsed"
		$MECM_Client_Block.Visibility = "Collapsed"
		$MECM_Client_Version_Label.Content = "dd"				
	} Else {
		$MECM_Client_Version_Block.Visibility = "Visible"
		$MECM_Client_Block.Visibility = "Visible"
		$MECM_Client_Version_Label.Content = $Get_MECM_Client_Version		
	}

    $Reboot_Days_Alert = 7
    $Last_boot = Get-CimInstance -ClassName Win32_OperatingSystem | Select -Exp LastBootUpTime
    $Current_Date = get-date
    $Diff_boot_time = $Current_Date - $Last_boot
    $Last_Reboot.Content = "Last reboot: $($Last_boot.ToString("yyyy-MM-dd HH:mm"))"
    If(($Diff_boot_time.Days) -gt $Reboot_Days_Alert) {
		$Reboot_Alert_Block.Visibility = "Visible"	
		$IsRebootRequired.Content = "Last reboot > $Reboot_Days_Alert days, please reboot your device when possible"	
		$IsRebootRequired.FontWeight = "Bold"
		$IsRebootRequired.Foreground = "yellow"					
	} Else {
		$Last_Reboot_Alert.Content = ""	
		$Reboot_Alert_Block.Visibility = "Collapsed"			
	}

    Get_Overview_Infos
    Get_Details_Infos
    Set_VPN_Troubleshooting_Info

    $Drivers_Test = Get-WmiObject Win32_PNPEntity | Where-Object {$_.ConfigManagerErrorCode -gt 0 }        
    $Search_Missing_Drivers = ($Drivers_Test | Where-Object {$_.ConfigManagerErrorCode -eq 28}).Count
    If ($Search_Missing_Drivers -gt 0) {
        $Missing_drivers.Content = "$Search_Missing_Drivers	- drivers are missing"
        $Missing_drivers.Foreground = "Red"			
    }
}

}

# Progressbar 'Getting information about your device'
CreateNewChildRunSpace

# Starting the Progressbar 'Getting information about your device'
Launch_modal_progress

# Initializing the Custom In-Window dialog, Set custom height in Dialog.xaml Row 5
If ($True) {
    $xamlDialog  = LoadXml("$($current_folder)\resources\Dialog.xaml")
    $read=(New-Object System.Xml.XmlNodeReader $xamlDialog)
    $DialogForm=[Windows.Markup.XamlReader]::Load( $read )

    # Create a new Dialog attached to Main Form
    $global:CustomDialog  = [MahApps.Metro.Controls.Dialogs.CustomDialog]::new($Form)
    $CustomDialog.AddChild($DialogForm)
    $settings             = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
    $settings.ColorScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Theme

    $Global:DialogMessage  = $DialogForm.FindName("LblMessage")
    $Global:DialogbtnClose    = $DialogForm.FindName("BtnClose")
}

# Define Overview Tab
If ($True) {

    $Tool_Logo = $form.FindName("Tool_Logo")

    $PC_Name = $form.FindName("Lbl_PC_Name")  
    $Username = $form.FindName("Lbl_Username")  
    $OS_Version = $form.FindName("Lbl_OS_Version")
    $Memory = $form.FindName("Lbl_Memory")
    $Serial = $form.FindName("Lbl_Serial")
    $Device_Model = $form.FindName("Lbl_Device_Model")
    $TeamViewer = $form.FindName("Lbl_TeamViewerID")
    $WirelessInfo = $form.FindName("Lbl_WirelessInfo")
    $Last_Reboot = $form.FindName("Lbl_Last_Reboot")
    $Last_Reboot_Alert = $form.FindName("Lbl_Last_Reboot_Alert")
    $Reboot_Alert_Block = $form.FindName("Reboot_Alert_Block")
        $IsRebootRequired = $form.FindName("IsRebootRequired")    $RoundBtn1 = $form.FindName("RoundBtn1")    $RoundBtn1.Content = "IT Knowledge Base"    $RoundBtn1.Visibility = "Visible"    $RoundBtn1.Add_Click({
       [Diagnostics.Process]::Start("https://kb.company.com")
    })

    $RoundBtn2 = $form.FindName("RoundBtn2")    $RoundBtn2.Content = "IT Self Service portal"    $RoundBtn2.Visibility = "Visible"
    $RoundBtn2.Add_Click({
       [Diagnostics.Process]::Start("https://selfservice.company.com")
    })

    $RoundBtn3 = $form.FindName("RoundBtn3")    $RoundBtn3.Content = "Major Incidents"    $RoundBtn3.Visibility = "Visible"
    $RoundBtn3.Add_Click({
       [Diagnostics.Process]::Start("https://incidents.company.com")
    })

    $RoundBtn4 = $form.FindName("RoundBtn4")    $RoundBtn4.Content = "Title button 4"    $RoundBtn4.Visibility = "Collapsed" # Visible, Collapsed
    $RoundBtn4.Add_Click({
       [Diagnostics.Process]::Start("https://insert.link.here")
    })

    $RoundBtn5 = $form.FindName("RoundBtn5")    $RoundBtn5.Content = "Title button 5"    $RoundBtn5.Visibility = "Collapsed" # Visible, Collapsed
    $RoundBtn5.Add_Click({
       [Diagnostics.Process]::Start("https://insert.link.here")
    })

}

# Define Details Tab
If ($True) {

    $Missing_Drivers_Label = $form.FindName("Missing_Drivers_Label")
    $Check_Drivers_Block = $form.FindName("Check_Drivers_Block")
    $Missing_Drivers_Block = $form.FindName("Missing_Drivers_Block")

    $Printer = $form.FindName("Printer")
    $My_IP = $form.FindName("My_IP")
    $My_MAC = $form.FindName("My_MAC")
    $Domain_name = $form.FindName("Domain_name")
    $Site_code = $form.FindName("Site_code")
    $SCCM_Status = $form.FindName("SCCM_Status")
    $BIOS_Version = $form.FindName("BIOS_Version")
    $Installed_antivirus = $form.FindName("Installed_antivirus")

    $Graphic_Card_details = $form.FindName("Graphic_Card_details")
    $Wifi_Card = $form.FindName("Wifi_Card")
    $Batteries_Info = $form.FindName("Batteries_Info")

    $MECM_Client_Block = $form.FindName("MECM_Client_Block")
    $MECM_Client_Version_Block = $form.FindName("MECM_Client_Version_Block") 
    $MECM_Client_Version_Label = $form.FindName("MECM_Client_Version_Label")

    $antivirus_Status_Label = $form.FindName("antivirus_Status_Label")
    $antivirus_Last_Update_Block = $form.FindName("antivirus_Last_Update_Block")
    $antivirus_Last_Update_Label = $form.FindName("antivirus_Last_Update_Label")
    $antivirus_Last_Scan_Block = $form.FindName("antivirus_Last_Scan_Block")
    $antivirus_Last_Scan_Label = $form.FindName("antivirus_Last_Scan_Label")
    $Check_LastScan_Block = $form.FindName("Check_LastScan_Block")
    $Domain_WKG_Label = $form.FindName("Domain_WKG_Label")
}

# Define Monitor Tab
If ($True) {
    $MonitorList = $form.FindName("MonitorList")
}

# Define Support Tab
If ($True) {
    $btnSupport_selfservice = $form.FindName("Support_selfservice")
    $btnSupport_email = $form.FindName("Support_email")
    $btnSupport_selfservice.Add_Click({
        [Diagnostics.Process]::Start("http://itsupport.company.com")
    })
    $btnSupport_email.Add_Click({
        [Diagnostics.Process]::Start("mailto:itsupport@company.com")
    })
}

# Define Tools Tab
If ($True) {

    $Tools_Block1 = $form.FindName("Tools_Block1")
    $Tools_Block2 = $form.FindName("Tools_Block2")
    $Tools_Block3 = $form.FindName("Tools_Block3")

    $Tools_Block1.Visibility = "Visible"
    $Tools_Block2.Visibility = "Visible"
    $Tools_Block3.Visibility = "Collapsed"

    #Connect to Controls
    $Tools_Btn_Block1_Row1 = $form.FindName("Tools_Btn_Block1_Row1")
    $Tools_Btn_Block1_Row2 = $form.FindName("Tools_Btn_Block1_Row2")
    $Tools_Btn_Block1_Row3 = $form.FindName("Tools_Btn_Block1_Row3")
    $Tools_Btn_Block1_Row4 = $form.FindName("Tools_Btn_Block1_Row4")
    $Tools_Btn_Block1_Row5 = $form.FindName("Tools_Btn_Block1_Row5")
    $Tools_Btn_Block1_Row6 = $form.FindName("Tools_Btn_Block1_Row6")
    $Tools_Btn_Block1_Row7 = $form.FindName("Tools_Btn_Block1_Row7")

    $Tools_Btn_Block2_Row1 = $form.FindName("Tools_Btn_Block2_Row1")
    $Tools_Btn_Block2_Row2 = $form.FindName("Tools_Btn_Block2_Row2")
    $Tools_Btn_Block2_Row3 = $form.FindName("Tools_Btn_Block2_Row3")
    $Tools_Btn_Block2_Row4 = $form.FindName("Tools_Btn_Block2_Row4")
    $Tools_Btn_Block2_Row5 = $form.FindName("Tools_Btn_Block2_Row5")
    $Tools_Btn_Block2_Row6 = $form.FindName("Tools_Btn_Block2_Row6")
    $Tools_Btn_Block2_Row7 = $form.FindName("Tools_Btn_Block2_Row7")

    $Tools_Btn_Block3_Row1 = $form.FindName("Tools_Btn_Block3_Row1")
    $Tools_Btn_Block3_Row2 = $form.FindName("Tools_Btn_Block3_Row2")
    $Tools_Btn_Block3_Row3 = $form.FindName("Tools_Btn_Block3_Row3")
    $Tools_Btn_Block3_Row4 = $form.FindName("Tools_Btn_Block3_Row4")
    $Tools_Btn_Block3_Row5 = $form.FindName("Tools_Btn_Block3_Row5")
    $Tools_Btn_Block3_Row6 = $form.FindName("Tools_Btn_Block3_Row6")
    $Tools_Btn_Block3_Row7 = $form.FindName("Tools_Btn_Block3_Row7")

    $Tools_Btn_Block1_Row1.Content = "Software Center"
    $Tools_Btn_Block1_Row1.Visibility = "Visible"
    $Tools_Btn_Block1_Row1.Add_Click({
       $process = Start-Process Softwarecenter: -PassThru 
    })

    $Tools_Btn_Block1_Row2.Content = "Generate Password"
    $Tools_Btn_Block1_Row2.Visibility = "Visible"
    $Tools_Btn_Block1_Row2.Add_Click({
        Tools_GeneratePassword
    })

    $Tools_Btn_Block1_Row3.Content = "Manage printers"
    $Tools_Btn_Block1_Row3.Visibility = "Visible"
    $Tools_Btn_Block1_Row3.Add_Click({
       $process = Start-Process "ms-settings:printers"
    })

    $Tools_Btn_Block1_Row4.Content = "Another tool"
    $Tools_Btn_Block1_Row4.Visibility = "Collapse"
    $Tools_Btn_Block1_Row4.Add_Click({
       
    })

    $Tools_Btn_Block1_Row5.Content = "Problem Steps Recorder"
    $Tools_Btn_Block1_Row5.Visibility = "Visible"
    $Tools_Btn_Block1_Row5.Add_Click({
       $process = Start-Process psr  
    })

    $Tools_Btn_Block1_Row6.Content = "Title"
    $Tools_Btn_Block1_Row6.Visibility = "Collapse"
    $Tools_Btn_Block1_Row6.Add_Click({
        
    })

    $Tools_Btn_Block1_Row7.Content = "Title"
    $Tools_Btn_Block1_Row7.Visibility = "Collapse"
    $Tools_Btn_Block1_Row7.Add_Click({
        
    })

    $Tools_Btn_Block2_Row1.Content = "Empty Recycle Bin"
    $Tools_Btn_Block2_Row1.Visibility = "Visible"
    $Tools_Btn_Block2_Row1.Add_Click({
       $process = Clear-RecycleBin -Force 
    })

    $Tools_Btn_Block2_Row2.Content = "TreeSize (See disk usage)"
    $Tools_Btn_Block2_Row2.Visibility = "Collapse"
    $Tools_Btn_Block2_Row2.Add_Click({
       $process = Start-Process "$Current_Folder\tools\TreeSizeFree.exe" -PassThru  
    })

    $Tools_Btn_Block2_Row3.Content = "Windows Mobility Center"
    $Tools_Btn_Block2_Row3.Visibility = "Visible"
    $Tools_Btn_Block2_Row3.Add_Click({
       $process = Start-Process "C:\Windows\System32\mblctr.exe"
    })

    $Tools_Btn_Block2_Row4.Content = "Quick Assist"
    $Tools_Btn_Block2_Row4.Visibility = "Visible"
    $Tools_Btn_Block2_Row4.Add_Click({
        $process = Start-Process "C:\Windows\System32\quickassist.exe"
    })

    $Tools_Btn_Block2_Row5.Content = "Title"
    $Tools_Btn_Block2_Row5.Visibility = "Collapse"
    $Tools_Btn_Block2_Row5.Add_Click({
        
    })

    $Tools_Btn_Block2_Row6.Content = "Title"
    $Tools_Btn_Block2_Row6.Visibility = "Collapse"
    $Tools_Btn_Block2_Row6.Add_Click({
        
    })

    $Tools_Btn_Block2_Row7.Content = "Title"
    $Tools_Btn_Block2_Row7.Visibility = "Collapse"
    $Tools_Btn_Block2_Row7.Add_Click({
        
    })

    $Tools_Btn_Block3_Row1.Content = "Title"
    $Tools_Btn_Block3_Row1.Visibility = "Collapse"
    $Tools_Btn_Block3_Row1.Add_Click({
        
    })

    $Tools_Btn_Block3_Row2.Content = "Title"
    $Tools_Btn_Block3_Row2.Visibility = "Collapse"
    $Tools_Btn_Block3_Row2.Add_Click({
        
    })

    $Tools_Btn_Block3_Row3.Content = "Title"
    $Tools_Btn_Block3_Row3.Visibility = "Collapse"
    $Tools_Btn_Block3_Row3.Add_Click({
        
    })

    $Tools_Btn_Block3_Row4.Content = "Title"
    $Tools_Btn_Block3_Row4.Visibility = "Collapse"
    $Tools_Btn_Block3_Row4.Add_Click({
        
    })

    $Tools_Btn_Block3_Row5.Content = "Title"
    $Tools_Btn_Block3_Row5.Visibility = "Collapse"
    $Tools_Btn_Block3_Row5.Add_Click({
        
    })

    $Tools_Btn_Block3_Row6.Content = "Title"
    $Tools_Btn_Block3_Row6.Visibility = "Collapse"
    $Tools_Btn_Block3_Row6.Add_Click({
        
    })

    $Tools_Btn_Block3_Row7.Content = "Title"
    $Tools_Btn_Block3_Row7.Visibility = "Collapse"
    $Tools_Btn_Block3_Row7.Add_Click({
        
    })

    $DialogbtnClose.add_Click({

        # Close the Custom Dialog
        $CustomDialog.RequestCloseAsync()

    })
}

# Define Troubleshooting Tab
If ($True) {

    $Troubleshooting_Block1 = $form.FindName("Troubleshooting_Block1")
    $Troubleshooting_Block2 = $form.FindName("Troubleshooting_Block2")
    $Troubleshooting_Block3 = $form.FindName("Troubleshooting_Block3")

    $Troubleshooting_Block1.Visibility = "Visible"
    $Troubleshooting_Block2.Visibility = "Visible"
    $Troubleshooting_Block3.Visibility = "Visible"

    #Connect to Controls
    $Troubleshooting_Btn_Block1_Row1 = $form.FindName("Troubleshooting_Btn_Block1_Row1")
    $Troubleshooting_Btn_Block1_Row2 = $form.FindName("Troubleshooting_Btn_Block1_Row2")
    $Troubleshooting_Btn_Block1_Row3 = $form.FindName("Troubleshooting_Btn_Block1_Row3")
    $Troubleshooting_Btn_Block1_Row4 = $form.FindName("Troubleshooting_Btn_Block1_Row4")
    $Troubleshooting_Btn_Block1_Row5 = $form.FindName("Troubleshooting_Btn_Block1_Row5")
    $Troubleshooting_Btn_Block1_Row6 = $form.FindName("Troubleshooting_Btn_Block1_Row6")
    $Troubleshooting_Btn_Block1_Row7 = $form.FindName("Troubleshooting_Btn_Block1_Row7")

    $Troubleshooting_Btn_Block2_Row1 = $form.FindName("Troubleshooting_Btn_Block2_Row1")
    $Troubleshooting_Btn_Block2_Row2 = $form.FindName("Troubleshooting_Btn_Block2_Row2")
    $Troubleshooting_Btn_Block2_Row3 = $form.FindName("Troubleshooting_Btn_Block2_Row3")
    $Troubleshooting_Btn_Block2_Row4 = $form.FindName("Troubleshooting_Btn_Block2_Row4")
    $Troubleshooting_Btn_Block2_Row5 = $form.FindName("Troubleshooting_Btn_Block2_Row5")
    $Troubleshooting_Btn_Block2_Row6 = $form.FindName("Troubleshooting_Btn_Block2_Row6")
    $Troubleshooting_Btn_Block2_Row7 = $form.FindName("Troubleshooting_Btn_Block2_Row7")

    $Troubleshooting_Btn_Block3_Row1 = $form.FindName("Troubleshooting_Btn_Block3_Row1")
    $Troubleshooting_Btn_Block3_Row2 = $form.FindName("Troubleshooting_Btn_Block3_Row2")
    $Troubleshooting_Btn_Block3_Row3 = $form.FindName("Troubleshooting_Btn_Block3_Row3")
    $Troubleshooting_Btn_Block3_Row4 = $form.FindName("Troubleshooting_Btn_Block3_Row4")
    $Troubleshooting_Btn_Block3_Row5 = $form.FindName("Troubleshooting_Btn_Block3_Row5")
    $Troubleshooting_Btn_Block3_Row6 = $form.FindName("Troubleshooting_Btn_Block3_Row6")
    $Troubleshooting_Btn_Block3_Row7 = $form.FindName("Troubleshooting_Btn_Block3_Row7")
          
    $Troubleshooting_Btn_Block1_Row1.Content = "Clear Teams cache"
    $Troubleshooting_Btn_Block1_Row1.Visibility = "Visible"
    $Troubleshooting_Btn_Block1_Row1.Add_Click({
            $TeamsRunning = Get-ProcessWithOwner teams
            if($TeamsRunning) {
                foreach($Process in $TeamsRunning){ 
                try{ 
                    Stop-Process $Process.handle | Out-Null 
                    #"Stopped process with handle $($Process.handle)" 
                }catch{ 
                    #"Failed to kill process with handle $($Process.handle)"
                } 
        } 
                Stop-Process  "$([Environment]::GetFolderPath("LocalApplicationData"))\Microsoft\Teams\Update.exe" 
            }
            Remove-Item -Path "$([Environment]::GetFolderPath("ApplicationData"))\Microsoft\teams\application cache\cache\" -Recurse -Force -ErrorAction SilentlyContinue 
            Remove-Item -Path "$([Environment]::GetFolderPath("ApplicationData"))\Microsoft\teams\blob_storage\" -Recurse -Force -ErrorAction SilentlyContinue 
            Remove-Item -Path "$([Environment]::GetFolderPath("ApplicationData"))\Microsoft\teams\Cache\" -Recurse -Force -ErrorAction SilentlyContinue 
            Remove-Item -Path "$([Environment]::GetFolderPath("ApplicationData"))\Microsoft\teams\databases\" -Recurse -Force -ErrorAction SilentlyContinue 
            Remove-Item -Path "$([Environment]::GetFolderPath("ApplicationData"))\Microsoft\teams\GPUcache\" -Recurse -Force -ErrorAction SilentlyContinue 
            Remove-Item -Path "$([Environment]::GetFolderPath("ApplicationData"))\Microsoft\teams\Local Storage\" -Recurse -Force -ErrorAction SilentlyContinue 
            Remove-Item -Path "$([Environment]::GetFolderPath("ApplicationData"))\Microsoft\teams\tmp\" -Recurse -Force -ErrorAction SilentlyContinue 
            Start-Process  "$([Environment]::GetFolderPath("LocalApplicationData"))\Microsoft\Teams\Update.exe" -ArgumentList "--processStart ""Teams.exe"""
        $DialogMessage.Content = "Cleared Teams Cache" 
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)
    })

    $Troubleshooting_Btn_Block1_Row2.Content = "Autoruns"
    $Troubleshooting_Btn_Block1_Row2.Visibility = "Collapse"
    $Troubleshooting_Btn_Block1_Row2.Add_Click({
        $process = Start-Process "C:\PATH_TO\Autoruns.exe" -PassThru 
    })

    $Troubleshooting_Btn_Block1_Row3.Content = "Policy Update (gpupdate)"
    $Troubleshooting_Btn_Block1_Row3.Visibility = "Visible"
    $Troubleshooting_Btn_Block1_Row3.Add_Click({
        $process = Start-Process "cmd.exe" -ArgumentList "/c cls & echo y | gpupdate /force /wait:0 & pause" -PassThru 
    })

    $Troubleshooting_Btn_Block1_Row4.Content = "Repair OneDrive paths"
    $Troubleshooting_Btn_Block1_Row4.Visibility = "Collapse"
    $Troubleshooting_Btn_Block1_Row4.Add_Click({

    })

    $Troubleshooting_Btn_Block1_Row5.Content = "Run Loginscript"
    $Troubleshooting_Btn_Block1_Row5.Visibility = "Collapse"
    $Troubleshooting_Btn_Block1_Row5.Add_Click({
        
    })

    $Troubleshooting_Btn_Block1_Row6.Content = "Title"
    $Troubleshooting_Btn_Block1_Row6.Visibility = "Collapse"
    $Troubleshooting_Btn_Block1_Row6.Add_Click({
        
    })

    $Troubleshooting_Btn_Block1_Row7.Content = "Title"
    $Troubleshooting_Btn_Block1_Row7.Visibility = "Collapse"
    $Troubleshooting_Btn_Block1_Row7.Add_Click({
        
    })

    $Troubleshooting_Btn_Block2_Row1.Content = "Clear Java Cache"
    $Troubleshooting_Btn_Block2_Row1.Visibility = "Visible"
    $Troubleshooting_Btn_Block2_Row1.Add_Click({
        Stop-Process -Name java.exe -Force -ErrorAction SilentlyContinue
        Stop-Process -Name javaws.exe -Force -ErrorAction SilentlyContinue
        Stop-Process -Name javaw.exe -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$([Environment]::GetFolderPath("LocalApplicationData"))\..\LocalLow\Sun\Java\Deployment\cache\6.0\" -Recurse -Force -ErrorAction SilentlyContinue 
        $DialogMessage.Content = "Cleared Java temp files" 
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)
    })

    $Troubleshooting_Btn_Block2_Row2.Content = "Clear Temp folder"
    $Troubleshooting_Btn_Block2_Row2.Visibility = "Visible"
    $Troubleshooting_Btn_Block2_Row2.Add_Click({
        Remove-Item -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue
        $DialogMessage.Content = "Cleared Temp files" 
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)
    })

    $Troubleshooting_Btn_Block2_Row3.Content = "Process Hacker"
    $Troubleshooting_Btn_Block2_Row3.Visibility = "Collapse"
    $Troubleshooting_Btn_Block2_Row3.Add_Click({
        $process = Start-Process "C:\PATH_TO\ProcessHacker\ProcessHacker.exe" -PassThru 
    })

    $Troubleshooting_Btn_Block2_Row4.Content = "Repair Start Menu Tiles"
    $Troubleshooting_Btn_Block2_Row4.Visibility = "Visible"
    $Troubleshooting_Btn_Block2_Row4.Add_Click({
        Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount"  -ErrorAction SilentlyContinue -Confirm:$false -Force -Recurse
        $DialogMessage.Content = "Please log out" 
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)
    })

    $Troubleshooting_Btn_Block2_Row5.Content = "Run SCCM App Evaluation"
    $Troubleshooting_Btn_Block2_Row5.Visibility = "Visible"
    $Troubleshooting_Btn_Block2_Row5.Add_Click({
            $CPAppletMgr = New-Object -ComObject CPApplet.CPAppletMgr
            $ClientActions = $CPAppletMgr.GetClientActions()
            ForEach ($ClientAction in $ClientActions) {
                #Write-Host "Performing action $($ClientAction.Name)"
                If ($ClientAction.Name -eq "Application Global Evaluation Task") {
                    $ClientAction.PerformAction | Out-Null
                }
            }
        $DialogMessage.Content = "Ran SCCM App Evaluation" 
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)
    })

    $Troubleshooting_Btn_Block2_Row6.Content = "Title"
    $Troubleshooting_Btn_Block2_Row6.Visibility = "Collapse"
    $Troubleshooting_Btn_Block2_Row6.Add_Click({
        
    })

    $Troubleshooting_Btn_Block2_Row7.Content = "Title"
    $Troubleshooting_Btn_Block2_Row7.Visibility = "Collapse"
    $Troubleshooting_Btn_Block2_Row7.Add_Click({
        
    })

    $Troubleshooting_Btn_Block3_Row1.Content = "Clear Silverlight cache"
    $Troubleshooting_Btn_Block3_Row1.Visibility = "Visible"
    $Troubleshooting_Btn_Block3_Row1.Add_Click({
        Remove-Item -Path "$([Environment]::GetFolderPath("LocalApplicationData"))\..\LocalLow\Microsoft\Silverlight\is\" -Recurse -Force -ErrorAction SilentlyContinue 
        $DialogMessage.Content = "Cleared Silverlight cache" 
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)
    })

    $Troubleshooting_Btn_Block3_Row2.Content = "Get SCCM Policies"
    $Troubleshooting_Btn_Block3_Row2.Visibility = "Visible"
    $Troubleshooting_Btn_Block3_Row2.Add_Click({
            $CPAppletMgr = New-Object -ComObject CPApplet.CPAppletMgr
            $ClientActions = $CPAppletMgr.GetClientActions()
            ForEach ($ClientAction in $ClientActions) {
                #Write-Host "Performing action $($ClientAction.Name)"
                If ($ClientAction.Name -eq "Request & Evaluate Machine Policy") {
                    $ClientAction.PerformAction | Out-Null
                }
            }        
        $DialogMessage.Content = "Requested SCCM Machine Policies" 
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)
    })

    $Troubleshooting_Btn_Block3_Row3.Content = "Refresh Citrix applications"
    $Troubleshooting_Btn_Block3_Row3.Visibility = "Visible"
    $Troubleshooting_Btn_Block3_Row3.Add_Click({
        $process = Start-Process "C:\Program Files (x86)\Citrix\ICA Client\SelfServicePlugin\SelfService.exe" -ArgumentList ("-poll") -PassThru
        $DialogMessage.Content = "Started refresh of Citrix apps" 
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)
    })

    $Troubleshooting_Btn_Block3_Row4.Content = "Restart Explorer"
    $Troubleshooting_Btn_Block3_Row4.Visibility = "Visible"
    $Troubleshooting_Btn_Block3_Row4.Add_Click({
        Restart_Explorer
    })

    $Troubleshooting_Btn_Block3_Row5.Content = "Run SCCM HW Inventory"
    $Troubleshooting_Btn_Block3_Row5.Visibility = "Visible"
    $Troubleshooting_Btn_Block3_Row5.Add_Click({
            $CPAppletMgr = New-Object -ComObject CPApplet.CPAppletMgr
            $ClientActions = $CPAppletMgr.GetClientActions()
            ForEach ($ClientAction in $ClientActions) {
                #Write-Host "Performing action $($ClientAction.Name)"
                If ($ClientAction.Name -eq "Hardware Inventory Collection Cycle") {
                    $ClientAction.PerformAction | Out-Null
                }
            }               
        $DialogMessage.Content = "Ran SCCM Hardware Inventory" 
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)
    })

    $Troubleshooting_Btn_Block3_Row6.Content = "Title"
    $Troubleshooting_Btn_Block3_Row6.Visibility = "Collapse"
    $Troubleshooting_Btn_Block3_Row6.Add_Click({
        
    })

    $Troubleshooting_Btn_Block3_Row7.Content = "Title"
    $Troubleshooting_Btn_Block3_Row7.Visibility = "Collapse"
    $Troubleshooting_Btn_Block3_Row7.Add_Click({
        
    })

}

# Define Links Tab
If ($True) {

    $Links_Block1 = $form.FindName("Links_Block1")
    $Links_Block2 = $form.FindName("Links_Block2")
    $Links_Block3 = $form.FindName("Links_Block3")

    $Links_Block1.Visibility = "Visible"
    $Links_Block2.Visibility = "Collapsed"
    $Links_Block3.Visibility = "Collapsed"

    $Links_Btn_Block1_Row1 = $form.FindName("Links_Btn_Block1_Row1")
    $Links_Btn_Block1_Row1.Content = "Change MFA Settings"
    $Links_Btn_Block1_Row1.Visibility = "Visible"
    $Links_Btn_Block1_Row1.Add_Click({
        [Diagnostics.Process]::Start("http://aka.ms/setupmfa")
    })

    $Links_Btn_Block1_Row2 = $form.FindName("Links_Btn_Block1_Row2")
    $Links_Btn_Block1_Row2.Content = "MyApps Portal"
    $Links_Btn_Block1_Row2.Visibility = "Visible"
    $Links_Btn_Block1_Row2.Add_Click({
        [Diagnostics.Process]::Start("https://myapplications.microsoft.com/")
    })

    $Links_Btn_Block1_Row3 = $form.FindName("Links_Btn_Block1_Row3")
    $Links_Btn_Block1_Row3.Content = "Title button 3"
    $Links_Btn_Block1_Row3.Visibility = "Visible"
    $Links_Btn_Block1_Row3.Add_Click({
        [Diagnostics.Process]::Start("https://insert.link.here")
    })

    $Links_Btn_Block1_Row4 = $form.FindName("Links_Btn_Block1_Row4")
    $Links_Btn_Block1_Row4.Content = "Title button 4"
    $Links_Btn_Block1_Row4.Visibility = "Collapsed"
    $Links_Btn_Block1_Row4.Add_Click({
        [Diagnostics.Process]::Start("https://insert.link.here")
    })

    $Links_Btn_Block1_Row5 = $form.FindName("Links_Btn_Block1_Row5")
    $Links_Btn_Block1_Row5.Content = "Windows 10 releases and UBR"
    $Links_Btn_Block1_Row5.Visibility = "Visible"
    $Links_Btn_Block1_Row5.Add_Click({
        [Diagnostics.Process]::Start("https://docs.microsoft.com/en-us/windows/release-health/release-information")
    })

    $Links_Btn_Block1_Row6 = $form.FindName("Links_Btn_Block1_Row6")
    $Links_Btn_Block1_Row6.Content = "Title button 6"
    $Links_Btn_Block1_Row6.Visibility = "Collapsed"
    $Links_Btn_Block1_Row6.Add_Click({
        [Diagnostics.Process]::Start("https://insert.link.here")
    })

    $Links_Btn_Block1_Row7 = $form.FindName("Links_Btn_Block1_Row7")
    $Links_Btn_Block1_Row7.Content = "Title button 7"
    $Links_Btn_Block1_Row7.Visibility = "Collapsed"
    $Links_Btn_Block1_Row7.Add_Click({
        [Diagnostics.Process]::Start("https://insert.link.here")
    })

}

# Define VPN Tab
If ($True) {

    $Global:VPNName = "Company VPN"
    $Global:MatchUserCertificate = ", OU=COMPANY, DC=ad, DC=company, DC=com"
    $Global:CheckInternalServerName = "server.ad.company.com"
    $Global:CheckInternalServerIPAddress = "10.1.1.10"
    $ShowTroubleshootingBlock = $True
    $ShowFooterBlock = $True
    $ShowBtnRepairVPN = $True
    $ShowBtnChangeMFA = $True

    $Global:VPNSites = @()
    $VPNSites += [pscustomobject]@{ ServerAddress = "vpn.company.com"; Name = "Automatic (Global)" }
    $VPNSites += [pscustomobject]@{ ServerAddress = "vpn-sweden.company.com"; Name = "Sweden" }

    $Global:VPNSubnets = @()
    $VPNSubnets += [pscustomobject]@{ ServerSubnet = "10.1.1.0/24"; Name = "Sweden" }
    #$VPNSubnets += [pscustomobject]@{ ServerSubnet = "10.1.2.0/24"; Name = "another Country/location" }
                
    # Left Block - No VPN Detected
    $Global:VPN_LeftBlock_NoVPNDetected = $form.FindName("VPN_LeftBlock_NoVPNDetected")
    $VPN_NoVPNDetected_Title = $form.FindName("VPN_NoVPNDetected_Title")
    $VPN_NoVPNDetected_Title.Content = "$($VPNName) not found"
    $Global:VPN_NoVPNDetected_Error = $form.FindName("VPN_NoVPNDetected_Error")
    
    # Left Block - VPN Detected
    $Global:VPN_LeftBlock_VPNDetected = $form.FindName("VPN_LeftBlock_VPNDetected")
    $Global:VPN_Settings_CurrentServer = $form.FindName("VPN_Settings_CurrentServer")
    $VPN_Settings_Btn_ChangeSite = $form.FindName("VPN_Settings_Btn_ChangeSite")
    $Global:VPN_Settings_Title_CurrentStatus = $form.FindName("VPN_Settings_Title_CurrentStatus")
    $Global:VPN_Settings_CurrentStatus = $form.FindName("VPN_Settings_CurrentStatus")
    $Global:VPN_Btn_Connect = $form.FindName("VPN_Btn_Connect")
    $VPN_Connect_Hint = $form.FindName("VPN_Connect_Hint")
    $Global:VPN_Btn_Disconnect = $form.FindName("VPN_Btn_Disconnect")
    $Global:VPN_Connected_IP = $form.FindName("VPN_Connected_IP")
    $Global:VPN_Connected_Site = $form.FindName("VPN_Connected_Site")

    # Footer Block with ChangeMFA and Repair button
    $Global:VPN_FooterBlock = $form.FindName("VPN_FooterBlock")
    If ($ShowFooterBlock) {
        $VPN_FooterBlock.Visibility = "Visible"
    } Else {
        $VPN_FooterBlock.Visibility = "Collapsed" 
    }
    $VPN_Btn_ChangeMFA = $form.FindName("VPN_Btn_ChangeMFA")
    If ($ShowBtnChangeMFA) {
        $VPN_Btn_ChangeMFA.Visibility = "Visible"
    } Else {
        $VPN_Btn_ChangeMFA.Visibility = "Collapsed" 
    }
    $VPN_Btn_Repair = $form.FindName("VPN_Btn_Repair")
    If ($ShowBtnRepairVPN) {
        $VPN_Btn_Repair.Visibility = "Visible"
    } Else {
        $VPN_Btn_Repair.Visibility = "Collapsed" 
    }

    # Right Block with Troubleshooting Info
    $Global:VPN_RightBlock = $form.FindName("VPN_RightBlock")
    $Global:VPN_Troubleshooting_IPAddress = $form.FindName("VPN_Troubleshooting_IPAddress")
    $Global:VPN_Troubleshooting_City = $form.FindName("VPN_Troubleshooting_City")   
    $Global:VPN_Troubleshooting_Region = $form.FindName("VPN_Troubleshooting_Region")
    $Global:VPN_Troubleshooting_Country = $form.FindName("VPN_Troubleshooting_Country")  
    If ($ShowTroubleshootingBlock) {
        $VPN_RightBlock.Visibility = "Visible"
    } Else {
        $VPN_RightBlock.Visibility = "Collapsed" 
    }


    $VPN_Connect_Hint.Visibility = "Collapsed" 
    $VPN_Settings_Btn_ChangeSite.Add_Click({
        VPN_Change_Site
    })  
    
    $VPN_Btn_ChangeMFA.Add_Click({
        [Diagnostics.Process]::Start("http://aka.ms/setupmfa")
    }) 
    $VPN_Btn_Repair.Add_Click({
        RepairVPN
    }) 
    
    $VPN_Btn_Disconnect.Add_Click({
        $VPN_Btn_Disconnect.Content = "Disconnecting from VPN..."
        [System.Windows.Forms.Application]::DoEvents()
        DisconnectVPN
        $VPN_Btn_Disconnect.Content = "Disconnect from VPN"""
    }) 
    $VPN_Btn_Connect.Add_Click({
        $VPN_Btn_Connect.Content = "Connecting to VPN, wait a moment"
        $VPN_Connect_Hint.Visibility = "Visible"
        [System.Windows.Forms.Application]::DoEvents()
        ConnectVPN
        #Start-Sleep -Seconds 5
        $VPN_Btn_Connect.Content = "Connect to VPN" 
        $VPN_Connect_Hint.Visibility = "Collapsed"    
    }) 
            
}
	
# Gather information to Tab Overview, Details and VPN Troubleshooting
GatherInformation

# Close the Progressbar 'Getting information about your device'		
Close_modal_progress	

$Tab_Control.Add_SelectionChanged({	
    # Refresh data if it was one hour or more since data was collected
    $CurrentTime = $(Get-Date)
    $TimeSinceLastRefresh = $(New-Timespan -Start $LastRefresh -End $CurrentTime)
    If ($TimeSinceLastRefresh.TotalMinutes -ge 60) {
        CreateNewChildRunSpace
        Launch_modal_progress
        $DialogMessage.Content = "Window inactive for to long, gathered new data" 
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)
        [System.Windows.Forms.Application]::DoEvents()
        GatherInformation
        Close_modal_progress
        $Tab_Overview.Focus();
    } Else {
        If ($Tab_Control.SelectedItem.Header -eq "Monitors") {	
		    $MonitorList.Children.Clear()     
		    Get_Monitor
		    Show_Tab_Monitor					
	    } ElseIf ($Tab_Control.SelectedItem.Header -eq "VPN") {
            Show_Tab_VPN   				
	    }	
    }
})

$Main_Color = "Cyan" # Available colors: "Red", "Green", "Blue", "Purple", "Orange", "Lime", "Emerald", "Teal", "Cyan", "Cobalt", "Indigo", "Violet", "Pink", "Magenta", "Crimson", "Amber", "Yellow", "Brown", "Olive", "Steel", "Mauve", "Taupe", "Sienna"
$Theme = [MahApps.Metro.ThemeManager]::DetectAppStyle($Form)	
[MahApps.Metro.ThemeManager]::ChangeAppStyle($Form, [MahApps.Metro.ThemeManager]::GetAccent("$Main_Color"), $Theme.Item1);	

$Form.Add_Closing({
    [System.Windows.Forms.Application]::Exit()
    Stop-Process $pid
})


# Define GUI Properties
If ($True) {
    $InitialFormWindowState = $Form.WindowState
    $Form.TopMost = $False
    $Form.Title = "Company IT Tools" 
    $Form.Width = "1024"
    $Form.Height = "600"
    $Tab_Control.Height = $($Form.Height)-50 # 50 less than the Height
}

# Define Tabs visibility with "Visible" or "Collapsed"
if ($True) { 
    #$Tab_Overview.Visibility = "Collapsed"
    #$Tab_Details.Visibility = "Collapsed"
    #$Tab_Links.Visibility = "Collapsed"
    #$Tab_Monitors.Visibility = "Collapsed"
    #$Tab_Support.Visibility = "Collapsed"
    #$Tab_Tools.Visibility = "Collapsed"
    #$Tab_Troubleshooting.Visibility = "Collapsed"
    #$Tab_VPN.Visibility = "Collapsed"
}

# Start the GUI
If ($True) {
    $Form.Show()
    $Form.Activate()
    $appContext = New-Object System.Windows.Forms.ApplicationContext 
    [void][System.Windows.Forms.Application]::Run($appContext)
}

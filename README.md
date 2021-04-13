This is a modified version of "About My PC" from Damien: https://github.com/damienvanrobaeys/About_my_device
The idea is to have a shortcut on the Start Menu and/or Taskbar to start the Tool.

Changes from the original version:
- No Config.xml, all changes are made in the PS1 file except Support phone numbers.
- Removed the Storage part
- Added scriptversion into the Title bar (It takes the modified date of the PS1-file)
- Added support for Custom Dialog
- Moved the progress bar into a Function
- Added support for refreshing the information if the window been inactive for 60 minutes or more.
- Removed the setting to always stay on top (TopMost) but still launch in front of other open windows/apps.
- Changed the size of the Window
- Added Round buttons on the Overview tab
- Added TeamViewer ID and Wireless info on Overview
- Changed how Lenovo models are displayed
- Changed the Date format into yyyy-MM-dd
- Added Battery info on Details page
- Added Tab Links, this page supports 3 columns with 7 links per column.
- Added Tab Tools, this page supports 3 columns with 7 Tools per column. Some tools are created.
- Added Tab Troubleshooting, this page supports 3 columns with 7 Tools per column. Some tools are created.
- Modified the Support page to have 3 columns. 
- Added Tab VPN to handle an Always VPN connection. User can change VPN site to connect to, Connect/disconnect VPN, see current connected site, see simple troubleshooting info.

# General

## How to change the title and Window size?
Change the lines:  
    $Form.Title = "Company IT Tools"  
    $Form.Width = "1024"  
    $Form.Height = "600"  

## How to hide a tab?
Uncomment the line:  
    #$Tab_Overview.Visibility = "Collapsed"  
    #$Tab_Details.Visibility = "Collapsed"  
    #$Tab_Links.Visibility = "Collapsed"  
    #$Tab_Monitors.Visibility = "Collapsed"  
    #$Tab_Support.Visibility = "Collapsed"  
    #$Tab_Tools.Visibility = "Collapsed"  
    #$Tab_Troubleshooting.Visibility = "Collapsed"  
    #$Tab_VPN.Visibility = "Collapsed"

## How to hide or show a Column?
Change the lines:  
    $Links_Block1.Visibility = "Visible"  
    $Links_Block2.Visibility = "Collapsed"  
    $Links_Block3.Visibility = "Collapsed"  
	
## How to configure a button?
The .Content is the Title of the button  
The .Visibility can be used to hide a button with Collapsed  

    $Links_Btn_Block1_Row1 = $form.FindName("Links_Btn_Block1_Row1")  
    $Links_Btn_Block1_Row1.Content = "Change MFA Settings"  
    $Links_Btn_Block1_Row1.Visibility = "Visible" # "Collapsed"  
    $Links_Btn_Block1_Row1.Add_Click({  
        [Diagnostics.Process]::Start("http://aka.ms/setupmfa")  
    })  
	
## How to display a custom dialog?
Add:  
    $DialogMessage.Content = "Add the message here"  
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($form, $CustomDialog, $settings)  

![alt text](https://github.com/DanielSjogren/Company_IT_Tools/blob/main/previews/custom_dialog.png)

## How to configure the VPN?

Define the name of the VPN connection (Same name as in Windows):  
    $Global:VPNName = "Company VPN"  

Define parts of the User certificate to match (If using other solution than user certificates, then remove this section):  
    $Global:MatchUserCertificate = ", OU=COMPANY, DC=ad, DC=company, DC=com"  
    
Define an internal server that can prevent VPN connections when on the company network. Added a check against IP because some providers can translate an address even when not connected:  
    $Global:CheckInternalServerName = "server.ad.company.com"  
    $Global:CheckInternalServerIPAddress = "10.1.1.10"  

Show or Hide the Troubleshooting block at the right:  
    $ShowTroubleshootingBlock = $True  

Show or hide the Footer block with Repair VPN and Change MFA buttons. The Repair VPN needs an updated Function with correct settings.  
    $ShowFooterBlock = $True  
    $ShowBtnRepairVPN = $True  
    $ShowBtnChangeMFA = $True  

Define VPN Sites with Address and Display Name. Used in Change VPN site section:  
    $Global:VPNSites = @()
    $VPNSites += [pscustomobject]@{ ServerAddress = "vpn.company.com"; Name = "Automatic (Global)" }
    $VPNSites += [pscustomobject]@{ ServerAddress = "vpn-sweden.company.com"; Name = "Sweden" }

Define a nicer display name of the connected VPN Site:  
    $Global:VPNSubnets = @()
    $VPNSubnets += [pscustomobject]@{ ServerSubnet = "10.1.1.0/24"; Name = "Sweden" }
    #$VPNSubnets += [pscustomobject]@{ ServerSubnet = "10.1.2.0/24"; Name = "another Country/location" }
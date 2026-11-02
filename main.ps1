$ErrorActionPreference = "Stop"

$Project = [AppDomain]::CurrentDomain.BaseDirectory.TrimEnd("\")

# Load modules
. "$Project\Modules\RAM.ps1"
. "$Project\Modules\Cleaner.ps1"
. "$Project\Modules\Disk.ps1"
. "$Project\Modules\Process.ps1"
. "$Project\Modules\Startup.ps1"
. "$Project\Modules\Defrag.ps1"
. "$Project\Modules\SystemInfo.ps1"
. "$Project\Modules\Network.ps1"
. "$Project\Modules\AppRemover.ps1"

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="NEXUS | System Control Center"
        Height="790" Width="1280"
        MinHeight="680" MinWidth="1080"
        WindowStartupLocation="CenterScreen"
        FontFamily="Segoe UI"
        Background="#080D18">

    <Window.Resources>
        <LinearGradientBrush x:Key="ShellBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#0B1424" Offset="0"/>
            <GradientStop Color="#080D18" Offset="1"/>
        </LinearGradientBrush>
        <LinearGradientBrush x:Key="AccentBrush" StartPoint="0,0" EndPoint="1,0">
            <GradientStop Color="#22D3EE" Offset="0"/>
            <GradientStop Color="#818CF8" Offset="1"/>
        </LinearGradientBrush>
        <LinearGradientBrush x:Key="SelectedBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#12364A" Offset="0"/>
            <GradientStop Color="#20234A" Offset="1"/>
        </LinearGradientBrush>

        <Style TargetType="{x:Type Button}">
            <Setter Property="Background" Value="#17263B"/>
            <Setter Property="Foreground" Value="#EAF4FF"/>
            <Setter Property="BorderBrush" Value="#304762"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="15,9"/>
            <Setter Property="Margin" Value="0,0,9,0"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type Button}">
                        <Border x:Name="ButtonBorder" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="9" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ButtonBorder" Property="Background" Value="#203D58"/>
                                <Setter TargetName="ButtonBorder" Property="BorderBrush" Value="#22D3EE"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="ButtonBorder" Property="Background" Value="#164E63"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="ButtonBorder" Property="Opacity" Value="0.4"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="{x:Type TabItem}">
            <Setter Property="Width" Value="204"/>
            <Setter Property="MinHeight" Value="48"/>
            <Setter Property="Margin" Value="0,4,12,4"/>
            <Setter Property="Padding" Value="16,11"/>
            <Setter Property="Foreground" Value="#8295AE"/>
            <Setter Property="Background" Value="#0E1929"/>
            <Setter Property="BorderBrush" Value="#18283D"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type TabItem}">
                        <Border x:Name="TabBorder" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="10" Padding="{TemplateBinding Padding}">
                            <Grid>
                                <Border x:Name="ActiveMark" Width="3" HorizontalAlignment="Left"
                                        Background="{StaticResource AccentBrush}" CornerRadius="2" Visibility="Collapsed"/>
                                <ContentPresenter ContentSource="Header" VerticalAlignment="Center"
                                                  Margin="8,0,0,0"
                                                  HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="TabBorder" Property="Background" Value="{StaticResource SelectedBrush}"/>
                                <Setter TargetName="TabBorder" Property="BorderBrush" Value="#28617B"/>
                                <Setter TargetName="ActiveMark" Property="Visibility" Value="Visible"/>
                                <Setter Property="Foreground" Value="#E8F8FF"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="TabBorder" Property="Background" Value="#17283E"/>
                                <Setter Property="Foreground" Value="#F1F7FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="{x:Type DataGrid}">
            <Setter Property="Background" Value="#0D1726"/>
            <Setter Property="Foreground" Value="#DCE8F5"/>
            <Setter Property="BorderBrush" Value="#263A52"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="GridLinesVisibility" Value="Horizontal"/>
            <Setter Property="HorizontalGridLinesBrush" Value="#1D3047"/>
            <Setter Property="VerticalGridLinesBrush" Value="#15263A"/>
            <Setter Property="RowBackground" Value="#101D2F"/>
            <Setter Property="AlternatingRowBackground" Value="#142238"/>
            <Setter Property="HeadersVisibility" Value="Column"/>
            <Setter Property="CanUserResizeRows" Value="False"/>
            <Setter Property="RowHeaderWidth" Value="0"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="GridLinesVisibility" Value="Horizontal"/>
        </Style>
        <Style TargetType="{x:Type DataGridColumnHeader}">
            <Setter Property="Background" Value="#1A2C43"/>
            <Setter Property="Foreground" Value="#67E8F9"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Padding" Value="12,11"/>
            <Setter Property="BorderBrush" Value="#2A405B"/>
            <Setter Property="BorderThickness" Value="0,0,1,1"/>
        </Style>
        <Style TargetType="{x:Type DataGridRow}">
            <Setter Property="MinHeight" Value="34"/>
            <Setter Property="Foreground" Value="#DCE8F5"/>
            <Style.Triggers>
                <Trigger Property="IsSelected" Value="True">
                    <Setter Property="Background" Value="#164E63"/>
                    <Setter Property="Foreground" Value="White"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        <Style TargetType="{x:Type TextBox}">
            <Setter Property="Background" Value="#0D1828"/>
            <Setter Property="Foreground" Value="#E6F0FC"/>
            <Setter Property="BorderBrush" Value="#2A405B"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="9,6"/>
            <Setter Property="CaretBrush" Value="#22D3EE"/>
        </Style>
        <Style TargetType="{x:Type ComboBox}">
            <Setter Property="Background" Value="#142238"/>
            <Setter Property="Foreground" Value="#E6F0FC"/>
            <Setter Property="BorderBrush" Value="#2A405B"/>
            <Setter Property="Padding" Value="7,5"/>
        </Style>
        <Style TargetType="{x:Type CheckBox}">
            <Setter Property="Foreground" Value="#D7E5F5"/>
            <Setter Property="Margin" Value="0,5,16,5"/>
        </Style>
        <Style TargetType="{x:Type ProgressBar}">
            <Setter Property="Background" Value="#24364D"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Height" Value="12"/>
        </Style>
    </Window.Resources>

    <Grid Margin="0">
        <Grid.Background>
            <StaticResource ResourceKey="ShellBrush"/>
        </Grid.Background>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <Grid Margin="30,22,30,18">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                <Border Width="46" Height="46" CornerRadius="13" Background="#142C43"
                        BorderBrush="#28617B" BorderThickness="1" Margin="0,0,13,0">
                    <TextBlock Text="N" Foreground="{StaticResource AccentBrush}"
                               FontSize="29" FontWeight="Black" HorizontalAlignment="Center"
                               VerticalAlignment="Center"/>
                </Border>
                <StackPanel VerticalAlignment="Center">
                    <TextBlock Text="NEXUS" Foreground="#F1F7FF"
                               FontSize="25" FontWeight="Bold"/>
                    <TextBlock Text="SYSTEM CONTROL CENTER  /  COMMAND INTERFACE"
                               Foreground="#7187A2" FontSize="10" FontWeight="SemiBold"/>
                </StackPanel>
            </StackPanel>
            <Border Grid.Column="1" Background="#10251F" BorderBrush="#245B4A"
                    BorderThickness="1" CornerRadius="20" Padding="13,8"
                    VerticalAlignment="Center">
                <StackPanel Orientation="Horizontal">
                    <Ellipse Width="7" Height="7" Fill="#34D399" Margin="0,0,8,0"/>
                    <TextBlock Text="ENGINE ONLINE" Foreground="#86EFAC"
                               FontSize="10" FontWeight="Bold" VerticalAlignment="Center"/>
                </StackPanel>
            </Border>
        </Grid>

        <TabControl Grid.Row="1" Margin="22,0,22,22" TabStripPlacement="Left" Padding="16"
                    Background="#0C1727" Foreground="White"
                    BorderBrush="#1D3047" BorderThickness="1">

            <TabItem Header="DASHBOARD">
                <Grid Margin="20">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <TextBlock Text="SYSTEM OVERVIEW"
                               FontSize="23" FontWeight="Bold"
                               Foreground="#22D3EE" Margin="0,0,0,20"/>

                    <StackPanel Grid.Row="1">
                        <Border Background="#142238" CornerRadius="8"
                                Padding="18" Margin="0,0,0,12">
                            <StackPanel>
                                <TextBlock Text="MEMORY / RAM"
                                           Foreground="#91A4BC" FontSize="13"/>
                                <TextBlock Name="RAMText" Text="Loading..."
                                           Foreground="White" FontSize="22"
                                           Margin="0,8,0,8"/>
                                <ProgressBar Name="RAMBar" Height="14"
                                             Maximum="100" Foreground="#22D3EE"/>
                            </StackPanel>
                        </Border>

                        <Border Background="#142238" CornerRadius="8"
                                Padding="18" Margin="0,0,0,12">
                            <StackPanel>
                                <TextBlock Text="PROCESSOR / CPU"
                                           Foreground="#91A4BC" FontSize="13"/>
                                <TextBlock Name="CPUText" Text="Loading..."
                                           Foreground="White" FontSize="22"
                                           Margin="0,8,0,8"/>
                                <ProgressBar Name="CPUBar" Height="14"
                                             Maximum="100" Foreground="#34D399"/>
                            </StackPanel>
                        </Border>

                        <Border Background="#142238" CornerRadius="8"
                                Padding="18">
                            <StackPanel>
                                <TextBlock Text="SYSTEM DRIVE / C:"
                                           Foreground="#91A4BC" FontSize="13"/>
                                <TextBlock Name="DiskText" Text="Loading..."
                                           Foreground="White" FontSize="22"
                                           Margin="0,8,0,8"/>
                                <ProgressBar Name="DiskBar" Height="14"
                                             Maximum="100" Foreground="#FBBF24"/>
                            </StackPanel>
                        </Border>

                        <TextBlock Name="StatusText"
                                   Text="NEXUS ENGINE INITIALIZED"
                                   Foreground="#22D3EE" Margin="0,18,0,0"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <TabItem Header="RAM MANAGER">
                <Grid Margin="20">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <TextBlock Text="RUNNING PROCESSES"
                               FontSize="23" FontWeight="Bold"
                               Foreground="#22D3EE" Margin="0,0,0,15"/>

                    <DataGrid Name="ProcessGrid" Grid.Row="1"
                              AutoGenerateColumns="True"
                              IsReadOnly="True"
                              SelectionMode="Single"
                              Background="#0D1726"
                              Foreground="White"
                              RowBackground="#142238"
                              AlternatingRowBackground="#17283F"
                              HeadersVisibility="Column"
                              CanUserAddRows="False"/>

                    <StackPanel Grid.Row="2" Orientation="Horizontal"
                                Margin="0,15,0,0">
                        <Button Name="RefreshProcessButton"
                                Content="REFRESH PROCESSES"
                                Padding="16,9" Margin="0,0,10,0"/>
                        <Button Name="EndTaskButton"
                                Content="END SELECTED TASK"
                                Padding="16,9" Background="#991B1B"
                                Foreground="White"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <TabItem Header="JUNK CLEANER">
                <Grid Margin="20">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <StackPanel>
                        <TextBlock Text="JUNK CLEANER"
                                   FontSize="23" FontWeight="Bold"
                                   Foreground="#22D3EE"/>
                        <TextBlock Text="Scan cache files before cleaning."
                                   Foreground="#91A4BC" Margin="0,5,0,10"/>
                        <WrapPanel Margin="0,0,0,12">
                            <CheckBox Name="DirectXCheck"
                                      Content="DirectX Shader Cache"
                                      IsChecked="True"
                                      Foreground="White"
                                      Margin="0,0,25,0"/>
                            <CheckBox Name="ThumbnailCheck"
                                      Content="Thumbnail Cache"
                                      IsChecked="True"
                                      Foreground="White"/>
                        </WrapPanel>
                    </StackPanel>

                    <DataGrid Name="CleanerGrid" Grid.Row="1"
                              AutoGenerateColumns="True"
                              IsReadOnly="True"
                              Background="#0D1726"
                              Foreground="White"
                              RowBackground="#142238"
                              AlternatingRowBackground="#17283F"
                              HeadersVisibility="Column"
                              CanUserAddRows="False"/>

                    <StackPanel Grid.Row="2" Orientation="Horizontal"
                                Margin="0,15,0,10">
                        <Button Name="ScanButton" Content="SCAN JUNK"
                                Padding="18,10" Margin="0,0,10,0"/>
                        <Button Name="CleanButton" Content="CLEAN SELECTED CACHE TYPES"
                                Padding="18,10" Background="#0F766E"
                                Foreground="White"/>
                    </StackPanel>

                    <TextBlock Name="CleanerStatus" Grid.Row="3"
                               Text="Ready to scan."
                               Foreground="#22D3EE"/>
                </Grid>
            </TabItem>
            <TabItem Header="DISK MANAGER">
                <Grid Margin="20">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="170"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <TextBlock Text="DISK MANAGER"
                               FontSize="23" FontWeight="Bold"
                               Foreground="#22D3EE" Margin="0,0,0,12"/>

                    <DataGrid Name="DiskGrid" Grid.Row="1"
                              AutoGenerateColumns="True"
                              IsReadOnly="True"
                              SelectionMode="Single"
                              Background="#0D1726"
                              Foreground="White"
                              RowBackground="#142238"
                              AlternatingRowBackground="#17283F"
                              CanUserAddRows="False"/>

                    <StackPanel Grid.Row="2" Orientation="Horizontal"
                                Margin="0,12,0,12">
                        <Button Name="ScanFoldersButton"
                                Content="SCAN 10 FOLDER TERBESAR"
                                Padding="16,10"
                                Background="#0369A1"
                                Foreground="White"/>
                        <TextBlock Name="DiskStatus"
                                   Text="Pilih drive, lalu scan folder."
                                   Foreground="#22D3EE"
                                   VerticalAlignment="Center"
                                   Margin="15,0,0,0"/>
                    </StackPanel>

                    <DataGrid Name="FolderGrid" Grid.Row="3"
                              AutoGenerateColumns="True"
                              IsReadOnly="True"
                              Background="#0D1726"
                              Foreground="White"
                              RowBackground="#142238"
                              AlternatingRowBackground="#17283F"
                              CanUserAddRows="False"/>
                </Grid>
            </TabItem>
            <TabItem Header="PROCESS MANAGER">
                <Grid Margin="20">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <TextBlock Text="PROCESS MANAGER"
                               FontSize="23" FontWeight="Bold"
                               Foreground="#22D3EE" Margin="0,0,0,15"/>

                    <StackPanel Grid.Row="1" Orientation="Horizontal"
                                Margin="0,0,0,12">
                        <TextBox Name="ProcessSearch"
                                 Width="280" Height="32"
                                 Padding="8"
                                 FontSize="13"
                                 Text=""/>
                        <Button Name="ProcessRefresh"
                                Content="REFRESH"
                                Padding="16,7" Margin="10,0,0,0"/>
                        <TextBlock Name="ProcessCount"
                                   Text="Loading..."
                                   Foreground="#22D3EE"
                                   VerticalAlignment="Center"
                                   Margin="15,0,0,0"/>
                    </StackPanel>

                    <DataGrid Name="AllProcessGrid" Grid.Row="2"
                              AutoGenerateColumns="True"
                              IsReadOnly="True"
                              SelectionMode="Single"
                              Background="#0D1726"
                              Foreground="White"
                              RowBackground="#142238"
                              AlternatingRowBackground="#17283F"
                              CanUserAddRows="False"/>

                    <StackPanel Grid.Row="3" Orientation="Horizontal"
                                Margin="0,15,0,0">
                        <Button Name="StopProcessButton"
                                Content="END SELECTED PROCESS"
                                Padding="16,10"
                                Background="#991B1B"
                                Foreground="White"/>
                        <TextBlock Name="ProcessStatus"
                                   Text="Ready."
                                   Foreground="#22D3EE"
                                   VerticalAlignment="Center"
                                   Margin="15,0,0,0"/>
                    </StackPanel>
                </Grid>
            </TabItem>
        <TabItem Header="STARTUP MANAGER">
            <Grid Margin="20">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>
                <TextBlock Text="STARTUP MANAGER"
                           FontSize="23" FontWeight="Bold"
                           Foreground="#22D3EE" Margin="0,0,0,15"/>
                <StackPanel Grid.Row="1" Orientation="Horizontal"
                            Margin="0,0,0,12">
                    <Button Name="StartupRefresh"
                            Content="REFRESH" Padding="16,8"/>
                    <TextBlock Name="StartupCount"
                               Text="Loading..." Foreground="#22D3EE"
                               VerticalAlignment="Center" Margin="15,0,0,0"/>
                </StackPanel>
                <DataGrid Name="StartupGrid" Grid.Row="2"
                          AutoGenerateColumns="True" IsReadOnly="True"
                          SelectionMode="Single"
                          Background="#0D1726" Foreground="White"
                          RowBackground="#142238"
                          AlternatingRowBackground="#17283F"
                          CanUserAddRows="False"/>
                <TextBlock Name="StartupStatus" Grid.Row="3"
                           Text="Ready." Foreground="#22D3EE"
                           Margin="0,12,0,0"/>
            </Grid>
        </TabItem>
        <TabItem Header="DEFRAGMENT MANAGER">
            <Grid Margin="20">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="130"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <TextBlock Text="DEFRAGMENT MANAGER"
                           FontSize="23" FontWeight="Bold"
                           Foreground="#22D3EE" Margin="0,0,0,15"/>

                <StackPanel Grid.Row="1" Orientation="Horizontal"
                            Margin="0,0,0,12">
                    <ComboBox Name="DefragDrive"
                              Width="100" Height="32"
                              FontSize="14"/>
                    <Button Name="DefragAnalyze"
                            Content="ANALYZE"
                            Padding="16,7" Margin="10,0,0,0"/>
                    <Button Name="DefragOptimize"
                            Content="OPTIMIZE"
                            Padding="16,7" Margin="10,0,0,0"
                            Background="#1D4ED8"
                            Foreground="White"/>
                </StackPanel>

                <DataGrid Name="DefragGrid" Grid.Row="2"
                          AutoGenerateColumns="True"
                          IsReadOnly="True"
                          Background="#0D1726"
                          Foreground="White"
                          RowBackground="#142238"
                          AlternatingRowBackground="#17283F"
                          CanUserAddRows="False"/>

                <TextBox Name="DefragOutput" Grid.Row="3"
                         Margin="0,12,0,0"
                         Background="#0A1424"
                         Foreground="#A7F3D0"
                         FontFamily="Consolas"
                         FontSize="12"
                         IsReadOnly="True"
                         AcceptsReturn="True"
                         TextWrapping="Wrap"
                         VerticalScrollBarVisibility="Auto"
                         HorizontalScrollBarVisibility="Auto"/>

                <TextBlock Name="DefragStatus" Grid.Row="4"
                           Text="Ready."
                           Foreground="#22D3EE"
                           Margin="0,12,0,0"/>
            </Grid>
        </TabItem>
        <TabItem Header="SYSTEM INFORMATION">
            <Grid Margin="20">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <TextBlock Text="SYSTEM INFORMATION"
                           FontSize="23" FontWeight="Bold"
                           Foreground="#22D3EE" Margin="0,0,0,15"/>

                <Button Name="SystemInfoRefresh"
                        Grid.Row="1"
                        Content="REFRESH HARDWARE"
                        Width="160" Height="34"
                        HorizontalAlignment="Left"
                        Margin="0,0,0,12"/>

                <DataGrid Name="SystemInfoGrid"
                          Grid.Row="2"
                          AutoGenerateColumns="True"
                          IsReadOnly="True"
                          CanUserAddRows="False"
                          Background="#0D1726"
                          Foreground="White"
                          RowBackground="#142238"
                          AlternatingRowBackground="#17283F"/>

                <TextBlock Name="SystemInfoStatus"
                           Grid.Row="3"
                           Text="Ready."
                           Foreground="#22D3EE"
                           Margin="0,12,0,0"/>
            </Grid>
        </TabItem>
        <TabItem Header="NETWORK MANAGER">
            <Grid Margin="20">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <TextBlock Text="NETWORK MANAGER"
                           FontSize="23" FontWeight="Bold"
                           Foreground="#22D3EE" Margin="0,0,0,15"/>

                <StackPanel Grid.Row="1" Orientation="Horizontal" Margin="0,0,0,12">
                    <Button Name="NetworkRefresh" Content="REFRESH" Padding="14,7"/>
                    <Button Name="NetworkTest" Content="INTERNET TEST" Padding="14,7" Margin="8,0,0,0"/>
                    <Button Name="NetworkFlush" Content="FLUSH DNS" Padding="14,7" Margin="8,0,0,0"/>
                </StackPanel>

                <StackPanel Grid.Row="2" Margin="0,0,0,12">
                    <DataGrid Name="NetworkGrid"
                              Height="115"
                              AutoGenerateColumns="True"
                              IsReadOnly="True"
                              CanUserAddRows="False"
                              Background="#0D1726"
                              Foreground="White"
                              RowBackground="#142238"
                              AlternatingRowBackground="#17283F"/>

                    <WrapPanel Margin="0,12,0,0">
                        <TextBox Name="NetworkPingHost"
                                 Text="1.1.1.1"
                                 Width="150" Height="30"
                                 VerticalContentAlignment="Center"/>
                        <Button Name="NetworkPing"
                                Content="PING"
                                Padding="14,6" Margin="8,0,0,0"/>

                        <TextBox Name="NetworkDomain"
                                 Text="google.com"
                                 Width="150" Height="30"
                                 VerticalContentAlignment="Center"
                                 Margin="15,0,0,0"/>
                        <Button Name="NetworkDNS"
                                Content="DNS LOOKUP"
                                Padding="14,6" Margin="8,0,0,0"/>
                    </WrapPanel>
                </StackPanel>

                <TextBox Name="NetworkOutput"
                         Grid.Row="3"
                         Background="#0A1424"
                         Foreground="#A7F3D0"
                         FontFamily="Consolas"
                         FontSize="12"
                         IsReadOnly="True"
                         AcceptsReturn="True"
                         TextWrapping="Wrap"
                         VerticalScrollBarVisibility="Auto"/>

                <TextBlock Name="NetworkStatus"
                           Grid.Row="4"
                           Text="Ready."
                           Foreground="#22D3EE"
                           Margin="0,12,0,0"/>
            </Grid>
        </TabItem>
        <TabItem Header="APP REMOVER">
            <Grid Margin="20">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <TextBlock Text="APP REMOVER"
                           FontSize="23" FontWeight="Bold"
                           Foreground="#22D3EE" Margin="0,0,0,15"/>

                <StackPanel Grid.Row="1" Orientation="Horizontal" Margin="0,0,0,12">
                    <TextBox Name="AppSearch"
                             Width="230" Height="32"
                             VerticalContentAlignment="Center"
                             ToolTip="Cari nama aplikasi"/>
                    <Button Name="AppRefresh" Content="REFRESH"
                            Padding="14,7" Margin="8,0,0,0"/>
                    <Button Name="AppUninstall" Content="UNINSTALL"
                            Padding="14,7" Margin="8,0,0,0"
                            Background="#991B1B" Foreground="White"/>
                </StackPanel>

                <DataGrid Name="AppGrid" Grid.Row="2"
                          AutoGenerateColumns="False"
                          IsReadOnly="True"
                          SelectionMode="Single"
                          CanUserAddRows="False"
                          Background="#0D1726"
                          Foreground="White"
                          RowBackground="#142238"
                          AlternatingRowBackground="#17283F">
                    <DataGrid.Columns>
                        <DataGridTextColumn Header="Application" Binding="{Binding Name}" Width="2*"/>
                        <DataGridTextColumn Header="Version" Binding="{Binding Version}" Width="*"/>
                        <DataGridTextColumn Header="Publisher" Binding="{Binding Publisher}" Width="2*"/>
                        <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="*"/>
                    </DataGrid.Columns>
                </DataGrid>

                <TextBlock Name="AppCount" Grid.Row="3"
                           Text="0 applications"
                           Foreground="#22D3EE" Margin="0,12,0,0"/>

                <TextBlock Name="AppStatus" Grid.Row="4"
                           Text="Ready."
                           Foreground="#22D3EE" Margin="0,6,0,0"/>
            </Grid>
        </TabItem>
        </TabControl>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get controls
$RAMText = $window.FindName("RAMText")
$RAMBar = $window.FindName("RAMBar")
$CPUText = $window.FindName("CPUText")
$CPUBar = $window.FindName("CPUBar")
$DiskText = $window.FindName("DiskText")
$DiskBar = $window.FindName("DiskBar")
$StatusText = $window.FindName("StatusText")

$ProcessGrid = $window.FindName("ProcessGrid")
$RefreshProcessButton = $window.FindName("RefreshProcessButton")
$EndTaskButton = $window.FindName("EndTaskButton")

$CleanerGrid = $window.FindName("CleanerGrid")
$ScanButton = $window.FindName("ScanButton")
$CleanButton = $window.FindName("CleanButton")
$CleanerStatus = $window.FindName("CleanerStatus")
$AllProcessGrid = $window.FindName("AllProcessGrid")
$ProcessSearch = $window.FindName("ProcessSearch")
$ProcessRefresh = $window.FindName("ProcessRefresh")
$ProcessCount = $window.FindName("ProcessCount")
$StopProcessButton = $window.FindName("StopProcessButton")
$StartupGrid = $window.FindName("StartupGrid")
$StartupRefresh = $window.FindName("StartupRefresh")
$StartupCount = $window.FindName("StartupCount")
$StartupStatus = $window.FindName("StartupStatus")
$DefragDrive = $window.FindName("DefragDrive")
$DefragAnalyze = $window.FindName("DefragAnalyze")
$DefragOptimize = $window.FindName("DefragOptimize")
$DefragGrid = $window.FindName("DefragGrid")
$DefragOutput = $window.FindName("DefragOutput")
$DefragStatus = $window.FindName("DefragStatus")
$SystemInfoGrid = $window.FindName("SystemInfoGrid")
$SystemInfoRefresh = $window.FindName("SystemInfoRefresh")
$SystemInfoStatus = $window.FindName("SystemInfoStatus")
$NetworkGrid = $window.FindName("NetworkGrid")
$NetworkRefresh = $window.FindName("NetworkRefresh")
$NetworkTest = $window.FindName("NetworkTest")
$NetworkFlush = $window.FindName("NetworkFlush")
$NetworkPingHost = $window.FindName("NetworkPingHost")
$NetworkPing = $window.FindName("NetworkPing")
$NetworkDomain = $window.FindName("NetworkDomain")
$NetworkDNS = $window.FindName("NetworkDNS")
$NetworkOutput = $window.FindName("NetworkOutput")
$NetworkStatus = $window.FindName("NetworkStatus")
$AppGrid = $window.FindName("AppGrid")
$AppSearch = $window.FindName("AppSearch")
$AppRefresh = $window.FindName("AppRefresh")
$AppUninstall = $window.FindName("AppUninstall")
$AppCount = $window.FindName("AppCount")
$AppStatus = $window.FindName("AppStatus")
$ProcessStatus = $window.FindName("ProcessStatus")
$DiskGrid = $window.FindName("DiskGrid")
$FolderGrid = $window.FindName("FolderGrid")
$ScanFoldersButton = $window.FindName("ScanFoldersButton")
$DiskStatus = $window.FindName("DiskStatus")
$DirectXCheck = $window.FindName("DirectXCheck")
$ThumbnailCheck = $window.FindName("ThumbnailCheck")

# Dashboard updater
function Update-Dashboard {
    try {
        $ram = Get-RAMInfo
        $RAMText.Text = "$($ram.UsedGB) GB used / $($ram.TotalGB) GB total ($($ram.Percent)%)"
        $RAMBar.Value = [math]::Min(100, [math]::Max(0, $ram.Percent))

        $cpuValue = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples[0].CookedValue
        $cpuValue = [math]::Round($cpuValue, 1)
        $CPUText.Text = "$cpuValue% usage"
        $CPUBar.Value = [math]::Min(100, [math]::Max(0, $cpuValue))

        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
        if ($disk -and $disk.Size -gt 0) {
            $usedGB = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 1)
            $totalGB = [math]::Round($disk.Size / 1GB, 1)
            $diskPercent = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 1)
            $DiskText.Text = "$usedGB GB used / $totalGB GB ($diskPercent%)"
            $DiskBar.Value = [math]::Min(100, [math]::Max(0, $diskPercent))
        }

        $StatusText.Text = "NEXUS ENGINE ONLINE"
    } catch {
        $StatusText.Text = "Dashboard warning: $($_.Exception.Message)"
    }
}

# RAM Manager
function Update-RAMManager {
    try {
        $ProcessGrid.ItemsSource = @(Get-TopRAMProcesses)
    } catch {
        [System.Windows.MessageBox]::Show(
            $_.Exception.Message, "NEXUS RAM Manager",
            "OK", "Warning"
        ) | Out-Null
    }
}

$RefreshProcessButton.Add_Click({
    Update-RAMManager
})

$EndTaskButton.Add_Click({
    $selected = $ProcessGrid.SelectedItem

    if ($null -eq $selected) {
        [System.Windows.MessageBox]::Show("Pilih proses terlebih dahulu.") | Out-Null
        return
    }

    $answer = [System.Windows.MessageBox]::Show(
        "Akhiri proses $($selected.ProcessName) (PID $($selected.Id))?",
        "Konfirmasi End Task",
        "YesNo",
        "Warning"
    )

    if ($answer -ne "Yes") { return }

    try {
        if ([int]$selected.Id -in @(0, 4, $PID)) {
            throw "Proses sistem atau PowerShell tidak boleh dihentikan."
        }

        Stop-Process -Id ([int]$selected.Id) -Force -ErrorAction Stop
        Update-RAMManager
        $StatusText.Text = "Process ended: $($selected.ProcessName)"
    } catch {
        [System.Windows.MessageBox]::Show(
            $_.Exception.Message, "End Task gagal",
            "OK", "Error"
        ) | Out-Null
    }
})

# Cleaner
function Update-CleanerScan {
    try {
        $CleanerGrid.ItemsSource = @(Get-NexusScan)
        $CleanerStatus.Text = "Scan selesai. Periksa kategori dan ukuran sebelum membersihkan."
    } catch {
        $CleanerStatus.Text = "Scan gagal: $($_.Exception.Message)"
    }
}

$ScanButton.Add_Click({
    Update-CleanerScan
})

$CleanButton.Add_Click({
    $selectedCategories = @()

    if ($DirectXCheck.IsChecked) {
        $selectedCategories += "DirectX Shader Cache"
    }

    if ($ThumbnailCheck.IsChecked) {
        $selectedCategories += "Thumbnail Cache"
    }

    if ($selectedCategories.Count -eq 0) {
        [System.Windows.MessageBox]::Show(
            "Pilih minimal satu kategori cache."
        ) | Out-Null
        return
    }

    $answer = [System.Windows.MessageBox]::Show(
        "Bersihkan kategori berikut?`n`n$($selectedCategories -join "`n")`n`nHanya file lebih lama dari 24 jam yang ditargetkan.",
        "Konfirmasi Cleaner",
        "YesNo",
        "Warning"
    )

    if ($answer -ne "Yes") { return }

    try {
        $CleanerStatus.Text = "Memproses kategori terpilih..."

        # Scan ulang sebelum penghapusan
        $CleanerGrid.ItemsSource = @(Get-NexusScan)

        $result = Clear-NexusCacheSelected -Categories $selectedCategories

        $CleanerStatus.Text = "Selesai | Terhapus: $($result.DeletedFiles) | Gagal: $($result.FailedFiles) | Hemat: $($result.SavedMB) MB"

        Update-CleanerScan
    }
    catch {
        $CleanerStatus.Text = "Cleaner gagal: $($_.Exception.Message)"
    }
})

# DISK MANAGER
function Update-DiskManager {
    try {
        $DiskGrid.ItemsSource = @(Get-NexusDiskInfo)
        if ($DiskGrid.Items.Count -gt 0) {
            $DiskGrid.SelectedIndex = 0
        }
        $DiskStatus.Text = "Drive berhasil dibaca."
    }
    catch {
        $DiskStatus.Text = "Disk error: $($_.Exception.Message)"
    }
}

$ScanFoldersButton.Add_Click({
    $selected = $DiskGrid.SelectedItem

    if ($null -eq $selected) {
        [System.Windows.MessageBox]::Show("Pilih drive terlebih dahulu.") | Out-Null
        return
    }

    try {
        $DiskStatus.Text = "Memindai $($selected.Drive)..."

        $window.Dispatcher.Invoke(
            [Action]{},
            [System.Windows.Threading.DispatcherPriority]::Background
        )

        $FolderGrid.ItemsSource = @(Get-NexusTopFolders -Drive $selected.Drive)
        $DiskStatus.Text = "Scan selesai: $($selected.Drive)"
    }
    catch {
        $DiskStatus.Text = "Scan gagal: $($_.Exception.Message)"
    }
})

# PROCESS MANAGER
$script:NexusProcessCache = @()

function Update-ProcessManager {
    try {
        $script:NexusProcessCache = @(Get-NexusProcessList)
        $query = $ProcessSearch.Text.Trim()

        if ($query) {
            $filtered = @(
                $script:NexusProcessCache | Where-Object {
                    $_.Process -like "*$query*" -or
                    "$($_.PID)" -like "*$query*"
                }
            )
        }
        else {
            $filtered = $script:NexusProcessCache
        }

        $AllProcessGrid.ItemsSource = $null
        $AllProcessGrid.ItemsSource = @($filtered)
        $ProcessCount.Text = "$($filtered.Count) proses ditampilkan"
        $ProcessStatus.Text = "Process list updated."
    }
    catch {
        $ProcessStatus.Text = "Gagal: $($_.Exception.Message)"
    }
}

$ProcessSearch.Add_TextChanged({
    $query = $ProcessSearch.Text.Trim()

    if ($query) {
        $filtered = @(
            $script:NexusProcessCache | Where-Object {
                $_.Process -like "*$query*" -or
                "$($_.PID)" -like "*$query*"
            }
        )
    }
    else {
        $filtered = $script:NexusProcessCache
    }

    $AllProcessGrid.ItemsSource = $null
    $AllProcessGrid.ItemsSource = @($filtered)
    $ProcessCount.Text = "$($filtered.Count) proses ditampilkan"
})

$ProcessRefresh.Add_Click({
    Update-ProcessManager
})

$StopProcessButton.Add_Click({
    $selected = $AllProcessGrid.SelectedItem

    if ($null -eq $selected) {
        [System.Windows.MessageBox]::Show(
            "Pilih proses terlebih dahulu."
        ) | Out-Null
        return
    }

    $answer = [System.Windows.MessageBox]::Show(
        "Akhiri proses $($selected.Process) dengan PID $($selected.PID)?`n`nAplikasi tersebut bisa kehilangan pekerjaan yang belum disimpan.",
        "Konfirmasi End Process",
        "YesNo",
        "Warning"
    )

    if ($answer -ne "Yes") { return }

    try {
        $result = Stop-NexusProcess -ProcessId ([int]$selected.PID)
        $ProcessStatus.Text = "Berhasil mengakhiri $($result.Process)"
        Update-ProcessManager
    }
    catch {
        $ProcessStatus.Text = "Gagal: $($_.Exception.Message)"
        [System.Windows.MessageBox]::Show(
            $_.Exception.Message,
            "NEXUS Process Manager",
            "OK",
            "Error"
        ) | Out-Null
    }
})


# STARTUP MANAGER
function Update-StartupManager {
    try {
        $registryItems = @(Get-NexusStartupList)
        $scheduledItems = @(Get-NexusScheduledStartup)
        $allItems = @($registryItems) + @($scheduledItems)

        $StartupGrid.ItemsSource = $allItems
        $StartupCount.Text = "$($allItems.Count) startup entries detected"
        $StartupStatus.Text = "Startup scan completed."
    }
    catch {
        $StartupStatus.Text = "Error: $($_.Exception.Message)"
    }
}

$StartupRefresh.Add_Click({
    Update-StartupManager
})

# DEFRAGMENT MANAGER
function Update-DefragManager {
    try {
        $info = @(Get-NexusDefragInfo)
        $DefragGrid.ItemsSource = $info

        $DefragDrive.Items.Clear()
        foreach ($item in $info) {
            [void]$DefragDrive.Items.Add($item.Drive)
        }

        if ($DefragDrive.Items.Count -gt 0) {
            $DefragDrive.SelectedIndex = 0
        }

        $DefragStatus.Text = "Drive information loaded."
    }
    catch {
        $DefragStatus.Text = "Error: $($_.Exception.Message)"
    }
}

$DefragAnalyze.Add_Click({
    try {
        $drive = [string]$DefragDrive.SelectedItem
        if (-not $drive) { throw "Pilih drive terlebih dahulu." }

        $DefragStatus.Text = "Analyzing $drive ..."
        $DefragOutput.Text = Invoke-NexusDefragAnalysis -Drive $drive
        $DefragStatus.Text = "Analysis completed."
    }
    catch {
        $DefragStatus.Text = "Analysis failed."
        [System.Windows.MessageBox]::Show($_.Exception.Message) | Out-Null
    }
})

$DefragOptimize.Add_Click({
    try {
        $drive = [string]$DefragDrive.SelectedItem
        if (-not $drive) { throw "Pilih drive terlebih dahulu." }

        $answer = [System.Windows.MessageBox]::Show(
            "Jalankan optimasi pada drive $drive? Proses ini dapat memerlukan waktu.",
            "NEXUS Defragment Manager",
            "YesNo",
            "Warning"
        )

        if ($answer -eq "Yes") {
            $DefragStatus.Text = "Optimizing $drive ..."
            $DefragOutput.Text = Invoke-NexusDefragOptimize -Drive $drive
            $DefragStatus.Text = "Optimization completed."
        }
    }
    catch {
        $DefragStatus.Text = "Optimization failed."
        [System.Windows.MessageBox]::Show($_.Exception.Message) | Out-Null
    }
})

# SYSTEM INFORMATION
function Update-SystemInfo {
    try {
        $data = Get-NexusSystemInfo

        $rows = foreach ($property in $data.PSObject.Properties) {
            [PSCustomObject]@{
                Component = $property.Name
                Details = [string]$property.Value
            }
        }

        $SystemInfoGrid.ItemsSource = @($rows)
        $SystemInfoStatus.Text = "Hardware information loaded successfully."
    }
    catch {
        $SystemInfoStatus.Text = "Error: $($_.Exception.Message)"
    }
}

$SystemInfoRefresh.Add_Click({
    Update-SystemInfo
})

# NETWORK MANAGER
function Update-NetworkManager {
    try {
        $NetworkGrid.ItemsSource = @(Get-NexusNetworkInfo)
        $NetworkStatus.Text = "Network information loaded."
    }
    catch {
        $NetworkStatus.Text = "Error: $($_.Exception.Message)"
    }
}

$NetworkRefresh.Add_Click({
    Update-NetworkManager
})

$NetworkTest.Add_Click({
    try {
        $NetworkStatus.Text = "Testing internet connection..."
        $result = Test-NexusInternet
        $NetworkOutput.Text = ($result | Format-List | Out-String)
        if ($result.TcpTestSucceeded) {
            $NetworkStatus.Text = "Internet connection: CONNECTED"
        } else {
            $NetworkStatus.Text = "Internet connection: FAILED"
        }
    }
    catch {
        $NetworkStatus.Text = "Test failed: $($_.Exception.Message)"
    }
})

$NetworkPing.Add_Click({
    try {
        $hostName = $NetworkPingHost.Text.Trim()
        if (-not $hostName) { throw "Masukkan alamat tujuan." }

        $NetworkStatus.Text = "Running ping..."
        $result = @(Test-NexusPing -HostName $hostName)

        if ($result.Count -gt 0) {
            $NetworkOutput.Text = ($result | Format-Table Address, ResponseTime, Status -AutoSize | Out-String)
        } else {
            $NetworkOutput.Text = "Tidak ada balasan ping dari $hostName."
        }

        $NetworkStatus.Text = "Ping completed."
    }
    catch {
        $NetworkStatus.Text = "Ping failed: $($_.Exception.Message)"
    }
})

$NetworkDNS.Add_Click({
    try {
        $domain = $NetworkDomain.Text.Trim()
        if (-not $domain) { throw "Masukkan nama domain." }

        $result = @(Get-NexusDNS -Domain $domain)
        $NetworkOutput.Text = ($result | Format-Table -AutoSize | Out-String)
        $NetworkStatus.Text = "DNS lookup completed."
    }
    catch {
        $NetworkStatus.Text = "DNS lookup failed: $($_.Exception.Message)"
    }
})

$NetworkFlush.Add_Click({
    $answer = [System.Windows.MessageBox]::Show(
        "Bersihkan cache DNS Windows sekarang?",
        "NEXUS Network Manager",
        "YesNo",
        "Question"
    )

    if ($answer -eq "Yes") {
        try {
            $NetworkOutput.Text = Clear-NexusDNS
            $NetworkStatus.Text = "DNS cache cleared."
        }
        catch {
            $NetworkStatus.Text = "Flush DNS failed: $($_.Exception.Message)"
        }
    }
})

# APP REMOVER
$script:NexusAppCache = @()

function Update-AppRemover {
    try {
        $script:NexusAppCache = @(Get-NexusInstalledApps)
        $AppGrid.ItemsSource = $script:NexusAppCache
        $AppCount.Text = "$($script:NexusAppCache.Count) applications detected"
        $AppStatus.Text = "Application list refreshed."
    }
    catch {
        $AppStatus.Text = "Error: $($_.Exception.Message)"
    }
}

$AppSearch.Add_TextChanged({
    $query = $AppSearch.Text.Trim()
    $filtered = @($script:NexusAppCache | Where-Object {
        $_.Name -like "*$query*" -or $_.Publisher -like "*$query*"
    })
    $AppGrid.ItemsSource = $filtered
    $AppCount.Text = "$($filtered.Count) matching applications"
})

$AppRefresh.Add_Click({
    Update-AppRemover
})

$AppUninstall.Add_Click({
    $selected = $AppGrid.SelectedItem

    if (-not $selected) {
        [System.Windows.MessageBox]::Show(
            "Pilih aplikasi terlebih dahulu."
        ) | Out-Null
        return
    }

    if ($selected.Name -match '(?i)Microsoft Visual C\+\+|Redistributable|Windows|Driver|Update Health') {
        [System.Windows.MessageBox]::Show(
            "Aplikasi ini merupakan komponen sistem atau runtime. Penghapusan diblokir untuk mencegah kerusakan aplikasi Windows."
        ) | Out-Null
        return
    }

    $answer = [System.Windows.MessageBox]::Show(
        "Yakin ingin menjalankan uninstall aplikasi:`n`n$($selected.Name)`n$($selected.Version)`n`nPastikan aplikasi tidak sedang digunakan.",
        "NEXUS APP REMOVER",
        "YesNo",
        "Warning"
    )

    if ($answer -eq "Yes") {
        try {
            $AppStatus.Text = "Uninstalling $($selected.Name)..."
            $result = Remove-NexusInstalledApp -Name $selected.Name -Type $selected.Type
            [System.Windows.MessageBox]::Show($result) | Out-Null
            Update-AppRemover
        }
        catch {
            $AppStatus.Text = "Uninstall failed: $($_.Exception.Message)"
            [System.Windows.MessageBox]::Show($_.Exception.Message) | Out-Null
        }
    }
})
# Initial load
Update-Dashboard
Update-RAMManager
Update-CleanerScan
Update-DiskManager
Update-ProcessManager
Update-StartupManager
Update-DefragManager
Update-SystemInfo
Update-NetworkManager
Update-AppRemover
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(2)
$timer.Add_Tick({
    Update-Dashboard
})
$timer.Start()

$window.ShowDialog() | Out-Null











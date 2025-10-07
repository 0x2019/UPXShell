object CommandsForm: TCommandsForm
  Left = 330
  Top = 242
  BorderStyle = bsDialog
  Caption = 'UPX Commands'
  ClientHeight = 415
  ClientWidth = 559
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  ShowHint = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pgcCommands: TPageControl
    Left = 0
    Top = 0
    Width = 559
    Height = 415
    Hint = 'cl'
    ActivePage = tbsUPX3
    Align = alClient
    TabOrder = 0
    object tbsUPX1: TTabSheet
      Caption = 'UPX v1.25'
      object mmoUPX1: TMemo
        Left = 0
        Top = 0
        Width = 551
        Height = 387
        Cursor = crArrow
        Align = alClient
        BorderStyle = bsNone
        Color = cl3DLight
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'Version: v1.25'
          '--------------'
          'Commands:'
          '  -1     compress faster                   -9    compress better'
          '  --best compress best (can be very slow for big files)'
          
            '  -d     decompress                        -l    list compressed' +
            ' file'
          
            '  -t     test compressed file              -V    display version' +
            ' number'
          
            '  -h     give this help                    -L    display softwar' +
            'e license'
          ''
          'Options:'
          '  -q     be quiet                          -v    be verbose'
          '  -oFILE write output to `FILE'#39
          '  -f     force compression of suspicious files'
          '  --no-color, --mono, --color, --no-progress   change look'
          ''
          'Backup options:'
          '  -k, --backup        keep backup files'
          '  --no-backup         no backup files [default]'
          ''
          'Overlay options:'
          
            '  --overlay=copy      copy any extra data attached to the file [' +
            'default]'
          
            '  --overlay=strip     strip any extra data attached to the file ' +
            '[dangerous]'
          '  --overlay=skip      don'#39't compress a file with an overlay'
          ''
          'Options for dos/com:'
          '  --8086              make compressed com work on any 8086'
          ''
          'Options for dos/exe:'
          '  --8086              make compressed exe work on any 8086'
          '  --no-reloc          put no relocations in to the exe header'
          ''
          'Options for dos/sys:'
          '  --8086              make compressed sys work on any 8086'
          ''
          'Options for djgpp2/coff:'
          '  --coff              produce COFF output [default: EXE]'
          ''
          'Options for watcom/le:'
          '  --le                produce LE output [default: EXE]'
          ''
          'Options for win32/pe & rtm32/pe:'
          '  --compress-exports=0    do not compress the export section'
          '  --compress-exports=1    compress the export section [default]'
          '  --compress-icons=0      do not compress any icons'
          '  --compress-icons=1      compress all but the first icon'
          
            '  --compress-icons=2      compress all but the first icon direct' +
            'ory '
          '[default]'
          '  --compress-resources=0  do not compress any resources at all'
          '  --strip-relocs=0        do not strip relocations'
          '  --strip-relocs=1        strip relocations [default]'
          ''
          '  file.. executables to (de)compress'
          ''
          
            'This version supports: dos/exe, dos/com, dos/sys, djgpp2/coff, w' +
            'atcom/le,'
          
            '                       win32/pe, rtm32/pe, tmt/adam, atari/tos, ' +
            'linux/386'
          ''
          
            'UPX comes with ABSOLUTELY NO WARRANTY; for details type `upx -L'#39 +
            '.')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        WantReturns = False
      end
    end
    object tbsUPX2: TTabSheet
      Caption = 'UPX v2.03'
      ImageIndex = 1
      object mmoUPX2: TMemo
        Left = 0
        Top = 0
        Width = 551
        Height = 387
        Cursor = crArrow
        Align = alClient
        BorderStyle = bsNone
        Color = cl3DLight
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'Version: v2.03'
          '--------------'
          'Commands:'
          '  -1     compress faster                   -9    compress better'
          '  --best compress best (can be slow for big files)'
          
            '  -d     decompress                        -l    list compressed' +
            ' file'
          
            '  -t     test compressed file              -V    display version' +
            ' number'
          
            '  -h     give this help                    -L    display softwar' +
            'e license'
          ''
          'Options:'
          '  -q     be quiet                          -v    be verbose'
          '  -oFILE write output to `FILE'#39
          '  -f     force compression of suspicious files'
          '  --no-color, --mono, --color, --no-progress   change look'
          ''
          'Backup options:'
          '  -k, --backup        keep backup files'
          '  --no-backup         no backup files [default]'
          ''
          'Overlay options:'
          
            '  --overlay=copy      copy any extra data attached to the file [' +
            'default]'
          
            '  --overlay=strip     strip any extra data attached to the file ' +
            '[DANGEROUS]'
          '  --overlay=skip      don'#39't compress a file with an overlay'
          ''
          'Options for atari/tos:'
          '  --all-methods       try all available compression methods'
          ''
          'Options for djgpp2/coff:'
          '  --coff              produce COFF output [default: EXE]'
          '  --all-methods       try all available compression methods'
          '  --all-filters       try all available preprocessing filters'
          ''
          'Options for dos/com:'
          '  --8086              make compressed com work on any 8086'
          '  --all-methods       try all available compression methods'
          '  --all-filters       try all available preprocessing filters'
          ''
          'Options for dos/exe:'
          '  --8086              make compressed exe work on any 8086'
          '  --no-reloc          put no relocations in to the exe header'
          '  --all-methods       try all available compression methods'
          ''
          'Options for dos/sys:'
          '  --8086              make compressed sys work on any 8086'
          '  --all-methods       try all available compression methods'
          '  --all-filters       try all available preprocessing filters'
          ''
          'Options for ps1/exe:'
          '  --all-methods       try all available compression methods'
          
            '  --8-bit             uses 8 bit size compression [default: 32 b' +
            'it]'
          '  --console-run       enables client/host transfer compatibility'
          
            '  --no-align          don'#39't align to 2048 bytes [enables: --cons' +
            'ole-run]'
          ''
          'Options for tmt/adam:'
          '  --all-methods       try all available compression methods'
          '  --all-filters       try all available preprocessing filters'
          ''
          'Options for vmlinuz/386'
          '  --all-methods       try all available compression methods'
          '  --all-filters       try all available preprocessing filters'
          ''
          'Options for watcom/le:'
          '  --le                produce LE output [default: EXE]'
          ''
          'Options for win32/pe & rtm32/pe:'
          '  --compress-exports=0    do not compress the export section'
          '  --compress-exports=1    compress the export section [default]'
          '  --compress-icons=0      do not compress any icons'
          '  --compress-icons=1      compress all but the first icon'
          
            '  --compress-icons=2      compress all but the first icon direct' +
            'ory '
          '[default]'
          '  --compress-resources=0  do not compress any resources at all'
          
            '  --keep-resource=list    do not compress resources specified by' +
            ' list'
          '  --strip-relocs=0        do not strip relocations'
          '  --strip-relocs=1        strip relocations [default]'
          '  --all-methods           try all available compression methods'
          
            '  --all-filters           try all available preprocessing filter' +
            's'
          ''
          'file..   executables to (de)compress'
          ''
          'This version supports:'
          
            '    arm/pe, atari/tos, bvmlinuz/386, djgpp2/coff, dos/com, dos/e' +
            'xe, dos/sys,'
          
            '    linux/amd64, linux/i386, linux/ppc32, mach/ppc32, ps1/exe, r' +
            'tm32/pe,'
          '    tmt/adam, vmlinux/386, vmlinuz/386, watcom/le, win32/pe'
          ''
          
            'UPX comes with ABSOLUTELY NO WARRANTY; for details visit http://' +
            'upx.sf.net')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        WantReturns = False
      end
    end
    object tbsUPX3: TTabSheet
      Caption = 'UPX v2.9x'
      ImageIndex = 2
      object mmoUPX3: TMemo
        Left = 0
        Top = 0
        Width = 551
        Height = 387
        Cursor = crArrow
        Align = alClient
        BorderStyle = bsNone
        Color = cl3DLight
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'Version: v2.9x'
          '--------------'
          'Commands:'
          '  -1     compress faster                   -9    compress better'
          '  --best compress best (can be slow for big files)'
          
            '  -d     decompress                        -l    list compressed' +
            ' file'
          
            '  -t     test compressed file              -V    display version' +
            ' number'
          
            '  -h     give this help                    -L    display softwar' +
            'e license'
          ''
          'Options:'
          '  -q     be quiet                          -v    be verbose'
          '  -oFILE write output to '#39'FILE'#39
          '  -f     force compression of suspicious files'
          '  --no-color, --mono, --color, --no-progress   change look'
          ''
          'Compression tuning options:'
          
            '  --brute             try all available compression methods & fi' +
            'lters'
          '  --ultra-brute       try even more compression variants'
          ''
          'Backup options:'
          '  -k, --backup        keep backup files'
          '  --no-backup         no backup files [default]'
          ''
          'Overlay options:'
          
            '  --overlay=copy      copy any extra data attached to the file [' +
            'default]'
          
            '  --overlay=strip     strip any extra data attached to the file ' +
            '[DANGEROUS]'
          '  --overlay=skip      don'#39't compress a file with an overlay'
          ''
          'Options for atari/tos:'
          '  --all-methods       try all available compression methods'
          ''
          'Options for djgpp2/coff:'
          '  --coff              produce COFF output [default: EXE]'
          '  --all-methods       try all available compression methods'
          '  --all-filters       try all available preprocessing filters'
          ''
          'Options for dos/com:'
          '  --8086              make compressed com work on any 8086'
          '  --all-methods       try all available compression methods'
          '  --all-filters       try all available preprocessing filters'
          ''
          'Options for dos/exe:'
          '  --8086              make compressed exe work on any 8086'
          '  --no-reloc          put no relocations in to the exe header'
          '  --all-methods       try all available compression methods'
          ''
          'Options for dos/sys:'
          '  --8086              make compressed sys work on any 8086'
          '  --all-methods       try all available compression methods'
          '  --all-filters       try all available preprocessing filters'
          ''
          'Options for ps1/exe:'
          '  --all-methods       try all available compression methods'
          
            '  --8-bit             uses 8 bit size compression [default: 32 b' +
            'it]'
          '  --8mb-ram           8 megabyte memory limit [default: 2 mb]'
          
            '  --boot-only         disables client/host transfer compatibilit' +
            'y'
          
            '  --no-align          don'#39't align to 2048 bytes [enables: --cons' +
            'ole-run]'
          ''
          'Options for tmt/adam:'
          '  --all-methods       try all available compression methods'
          '  --all-filters       try all available preprocessing filters'
          ''
          'Options for vmlinuz/386'
          '  --all-methods       try all available compression methods'
          '  --all-filters       try all available preprocessing filters'
          ''
          'Options for watcom/le:'
          '  --le                produce LE output [default: EXE]'
          ''
          'Options for win32/pe, rtm32/pe & arm/pe:'
          '  --compress-exports=0    do not compress the export section'
          '  --compress-exports=1    compress the export section [default]'
          '  --compress-icons=0      do not compress any icons'
          '  --compress-icons=1      compress all but the first icon'
          
            '  --compress-icons=2      compress all but the first icon direct' +
            'ory '
          '[default]'
          '  --compress-icons=3      compress all icons'
          '  --compress-resources=0  do not compress any resources at all'
          
            '  --keep-resource=list    do not compress resources specified by' +
            ' list'
          '  --strip-relocs=0        do not strip relocations'
          '  --strip-relocs=1        strip relocations [default]'
          '  --all-methods           try all available compression methods'
          
            '  --all-filters           try all available preprocessing filter' +
            's'
          ''
          'file..   executables to (de)compress'
          ''
          'This version supports:'
          '    amd64-linux.elf                  linux/ElfAMD'
          '    amd64-linux.kernel.vmlinux       vmlinux/AMD64'
          '    arm-linux.elf                    linux/armLE'
          '    arm-linux.kernel.vmlinux         vmlinux/ARM'
          '    arm-wince.pe                     arm/pe'
          '    armeb-linux.elf                  linux/armBE'
          '    i286-dos16.com                   dos/com'
          '    i286-dos16.exe                   dos/exe'
          '    i286-dos16.sys                   dos/sys'
          '    i386-bsd.elf.execve              *BSD/386'
          '    i386-dos32.djgpp2                djgpp2/coff'
          '    i386-dos32.tmt                   tmt/adam'
          '    i386-dos32.watcom.le             watcom/le'
          '    i386-freebsd.elf                 BSD/elf386'
          '    i386-linux.elf                   linux/elf386'
          '    i386-linux.elf.execve            linux/386'
          '    i386-linux.elf.shell             linux/sh386'
          '    i386-linux.kernel.bvmlinuz       bvmlinuz/386'
          '    i386-linux.kernel.vmlinux        vmlinux/386'
          '    i386-linux.kernel.vmlinuz        vmlinuz/386'
          '    i386-netbsd.elf                  BSD/elf386'
          '    i386-openbsd.elf                 BSD/elf386'
          '    i386-win32.pe                    win32/pe'
          '    m68k-atari.tos                   atari/tos'
          '    mipsel.r3000-ps1                 ps1/exe'
          '    powerpc-darwin.macho             Mach/ppc32'
          '    powerpc-linux.elf                linux/ElfPPC'
          ''
          
            'UPX comes with ABSOLUTELY NO WARRANTY; for details visit http://' +
            'upx.sf.net')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        WantReturns = False
      end
    end
  end
  object btnClose: TButton
    Left = 536
    Top = 0
    Width = 20
    Height = 18
    BiDiMode = bdLeftToRight
    Caption = 'x'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentBiDiMode = False
    ParentFont = False
    TabOrder = 1
  end
end

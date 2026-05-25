# Lion Addon Build Script — v3 (128x64 texture, 2-bone legs, prominent mane)
# Usage: .\build.ps1
# Output: lion_addon.mcaddon

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outFile    = Join-Path $scriptDir "lion_addon.mcaddon"
Write-Host "=== Lion Addon Builder ===" -ForegroundColor Cyan

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

# ─── Texture helper functions ────────────────────────────────────────────────
function New-Bmp($w,$h) {
    $b = New-Object System.Drawing.Bitmap($w,$h)
    $g = [System.Drawing.Graphics]::FromImage($b)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.Dispose()
    return $b
}
function Get-Gfx($bmp) { return [System.Drawing.Graphics]::FromImage($bmp) }
function Col($hex)      { return [System.Drawing.ColorTranslator]::FromHtml($hex) }
function Rect($g,$x,$y,$w,$h,$hex) {
    $br = New-Object System.Drawing.SolidBrush((Col $hex))
    $g.FillRectangle($br,[int]$x,[int]$y,[int]$w,[int]$h)
    $br.Dispose()
}
function Px($g,$x,$y,$hex) { Rect $g $x $y 1 1 $hex }

# ─── UV box face helper ───────────────────────────────────────────────────────
# For a cube UV at [U,V] with size [W,H,D]:
#   Top    face: [U+D,   V    ] size [W, D]
#   Bottom face: [U+D+W, V    ] size [W, D]
#   Left   face: [U,     V+D  ] size [D, H]
#   FRONT  face: [U+D,   V+D  ] size [W, H]   ← what you see face-on
#   Right  face: [U+D+W, V+D  ] size [D, H]
#   Back   face: [U+2D+W,V+D  ] size [W, H]

# ─── Generate 128x64 lion texture ────────────────────────────────────────────
$texPath = Join-Path $scriptDir "lion_RP\textures\entity\lion.png"
New-Item -ItemType Directory -Force -Path (Split-Path $texPath) | Out-Null

$bmp = New-Bmp 128 64
$g   = Get-Gfx $bmp

# Base fill — golden amber
Rect $g  0  0 128 64 "#C8922A"

# ── BODY [0,0] W=8 H=5 D=16 ─────────────────────────────────────────────────
# Top:   [16,0]→[24,16]  Left:[0,16]→[16,21]  Front:[16,16]→[24,21]
# Right: [24,16]→[40,21]  Back:[40,16]→[48,21]
Rect $g  0  0 48 16 "#BF8820"  # top/bottom strip
Rect $g 16  0  8 16 "#D4A040"  # body top face
Rect $g  0 16 48  5 "#C8922A"  # side strips base
Rect $g 16 16  8  5 "#E0C878"  # belly front

# Body fur texture — alternating lighter/darker pixels on side faces
# Left side [0,16]→[16,21] and Right side [24,16]→[40,21] (each 16×5)
foreach ($fx in @(0,3,6,9,12,15)) {
    Px $g $fx       17 "#A87020"   # dark spot row 1 left
    Px $g (24+$fx)  17 "#A87020"   # dark spot row 1 right
    Px $g ($fx+1)   19 "#DAAC50"   # light spot row 3 left
    Px $g (25+$fx)  19 "#DAAC50"   # light spot row 3 right
}
# Back face [40,16]→[48,21] fur hints
foreach ($bx in @(41,43,45,47)) {
    Px $g $bx 17 "#A87020"
    Px $g $bx 19 "#DAAC50"
}
# Darker spine stripe on body top face
Rect $g 18  4  4  8 "#B87818"   # mid-spine darker strip

# ── HEAD [0,22] W=8 H=8 D=8 ─────────────────────────────────────────────────
# UV box layout for head (W=8, H=8, D=8) at UV [0,22]:
#   Top face:    [8,22]→[16,30]   (what you see from above)
#   Left side:   [0,30]→[8,38]
#   FRONT face:  [8,30]→[16,38]   ← face pixels go here
#   Right side:  [16,30]→[24,38]
#   Back face:   [24,30]→[32,38]
#   Bottom:      [16,22]→[24,30]
#
# Face pixel map — absolute coords [8..15, 30..37], 8×8:
#  y\x  8    9    10   11   12   13   14   15
#   30: FUR  FUR  FUR  STR  STR  FUR  FUR  FUR   (forehead, centre stripe)
#   31: FUR  DRK  AMB  AMB  AMB  AMB  DRK  FUR   (eye sockets + amber iris)
#   32: FUR  DRK  AMB  PUP  PUP  AMB  DRK  FUR   (pupils)
#   33: FUR  DRK  DRK  FUR  FUR  DRK  DRK  FUR   (under-eye dark marks)
#   34: CRM  CRM  CRM  CRM  CRM  CRM  CRM  CRM   (cream muzzle starts)
#   35: CRM  CRM  NOS  NOS  NOS  NOS  CRM  CRM   (nose)
#   36: CRM  CRM  NOS  ___  ___  NOS  CRM  CRM   (nose bottom)
#   37: CRM  MTH  CRM  CRM  CRM  CRM  MTH  CRM   (mouth corners)

# Head — all faces base colour
Rect $g  0 22 32 16 "#C8922A"
# Top of head — slightly lighter (fur on crown)
Rect $g  8 22  8  8 "#D4A848"
# Side faces — warm tan (cheeks)
Rect $g  0 30  8  8 "#C8922A"
Rect $g 16 30  8  8 "#C8922A"

# ── FRONT FACE of head [8,30] 8×8 ───────────────────────────────────────────
# Row y=30 — forehead
Rect $g  8 30  8  1 "#D4A040"        # forehead base
Px $g 11 30 "#A87830"                 # centre forehead stripe pixel 1
Px $g 12 30 "#A87830"                 # centre forehead stripe pixel 2

# Row y=31 — eye sockets (near-black frame) + vivid amber iris
Px $g  8 31 "#D4A040"  # outer left fur
Px $g  9 31 "#2A1400"  # DARK socket left
Px $g 10 31 "#F0A000"  # vivid amber iris left
Px $g 11 31 "#F0A000"
Px $g 12 31 "#F0A000"  # vivid amber iris right
Px $g 13 31 "#F0A000"
Px $g 14 31 "#2A1400"  # DARK socket right
Px $g 15 31 "#D4A040"  # outer right fur

# Row y=32 — pupils (pure black) inside bright iris
Px $g  8 32 "#D4A040"
Px $g  9 32 "#2A1400"  # socket frame
Px $g 10 32 "#F0A000"  # iris
Px $g 11 32 "#000000"  # pupil left — pure black
Px $g 12 32 "#000000"  # pupil right — pure black
Px $g 13 32 "#F0A000"  # iris
Px $g 14 32 "#2A1400"  # socket frame
Px $g 15 32 "#D4A040"

# Row y=33 — under-eye dark mark (keeps eye defined at bottom)
Px $g  8 33 "#D4A040"
Px $g  9 33 "#2A1400"  # dark under left
Px $g 10 33 "#2A1400"
Px $g 11 33 "#C8922A"  # fur gap between eyes
Px $g 12 33 "#C8922A"
Px $g 13 33 "#2A1400"  # dark under right
Px $g 14 33 "#2A1400"
Px $g 15 33 "#D4A040"

# Rows y=34..37 — cream/white muzzle
Rect $g  8 34  8  4 "#F0E8D0"   # full cream fill
# Nose on muzzle
Px $g 10 35 "#2A1200"            # nose top
Px $g 11 35 "#2A1200"
Px $g 12 35 "#2A1200"
Px $g 13 35 "#2A1200"
Px $g 10 36 "#2A1200"            # nose bottom
Px $g 11 36 "#2A1200"
Px $g 12 36 "#2A1200"
Px $g 13 36 "#2A1200"
# Mouth corners
Px $g  9 37 "#9A5A2A"
Px $g 14 37 "#9A5A2A"
# Chin centre line
Px $g 11 37 "#C8B898"
Px $g 12 37 "#C8B898"

# Eye highlights — pure white to make eyes sparkle
Px $g 10 31 "#FFFFFF"  # left eye highlight (top-left of iris)
Px $g 10 32 "#FFFFFF"  # left eye second highlight
Px $g 13 31 "#FFFFFF"  # right eye highlight
Px $g 13 32 "#FFFFFF"  # right eye second highlight

# ── SNOUT [32,22] W=6 H=4 D=4 ───────────────────────────────────────────────
# Front face of snout: [U+D, V+D] = [36, 26] size [6,4]
Rect $g 32 22 20  8 "#C8922A"   # snout sides base
Rect $g 36 22  6  4 "#D4A040"   # snout top face (fur)
# Front face — cream with nose and whisker dots
Rect $g 36 26  6  4 "#F0E8D0"   # cream snout front
Px $g 37 27 "#2A1200"            # left nostril
Px $g 40 27 "#2A1200"            # right nostril
Px $g 38 27 "#3A1A00"            # nose bridge
Px $g 39 27 "#3A1A00"
Px $g 36 28 "#B8A890"            # whisker dot left
Px $g 41 28 "#B8A890"            # whisker dot right
Px $g 37 29 "#9A5A2A"            # mouth left
Px $g 40 29 "#9A5A2A"            # mouth right

# ── MANE [0,40] W=14 H=14 D=10 ──────────────────────────────────────────────
# UV spans [0,40]→[48,64]  (2*(10+14)=48 wide, 10+14=24 tall)
# Top face:   [10,40]→[24,50]
# Front face: [10,50]→[24,64]   ← mane front ring
# Sides:      [0,50]→[10,64] and [24,50]→[34,64]
# Back face:  [34,50]→[48,64]
Rect $g  0 40 48 24 "#7A4A0A"  # mane — dark rich brown base
Rect $g 10 40 14 10 "#8A5A1A"  # mane top face — slightly lighter
Rect $g 10 50 14 14 "#6A3000"  # mane front face — darkest (depth)
# Mane front face symmetric fur highlights
# Front face is 14px wide: x=10..23, centre gap between x=16 and x=17
# Pixel pairs: (10+n) mirrors (23-n) for perfect left/right symmetry
# Pairs used: (11,22), (13,20), (15,18) on alternating rows
foreach ($row in @(50, 52, 54, 56, 58, 60, 62)) {
    Px $g 11 $row "#9A6520"   # left streak A  — mirrors right streak A
    Px $g 22 $row "#9A6520"   # right streak A
    Px $g 14 $row "#8A5A18"   # left streak B  — mirrors right streak B
    Px $g 19 $row "#8A5A18"   # right streak B
}
Rect $g  0 50 10 14 "#7A4A0A"  # left side mane
Rect $g 34 50 14 14 "#7A4A0A"  # back of mane


# ── FRONT THIGH [52,0] W=4 H=5 D=4 ──────────────────────────────────────────
# Front face: [56,4]→[60,9]
Rect $g 52  0 16  9 "#C8922A"
Rect $g 56  0  4  4 "#BF8820"  # top cap
Rect $g 56  4  4  5 "#C8922A"  # front face
Rect $g 52  4  4  5 "#BF8820"  # left side
Rect $g 60  4  4  5 "#BF8820"  # right side
# Fur texture on front face — alternating light/dark pixel pairs
Px $g 56 4 "#DAAC50"  ; Px $g 58 4 "#DAAC50"    # light row
Px $g 57 6 "#A87020"  ; Px $g 59 6 "#A87020"    # dark row
Px $g 56 8 "#DAAC50"  ; Px $g 58 8 "#DAAC50"    # light row

# ── FRONT SHIN [68,0] W=3 H=5 D=3 ───────────────────────────────────────────
# Front face: [71,3]→[74,8]
Rect $g 68  0 12  8 "#C09030"
Rect $g 71  0  3  3 "#A07828"  # shin top
Rect $g 71  3  3  5 "#C09030"  # shin front
Px $g 71 4 "#D4A848" ; Px $g 73 4 "#D4A848"   # fur light
Px $g 72 6 "#A07020" ; Px $g 71 7 "#A07020"   # fur dark

# ── FRONT PAW [80,0] W=5 H=2 D=4 ────────────────────────────────────────────
# Front face: [84,4]→[89,6]
Rect $g 80  0 18  6 "#A07020"  # paw — darkest
Rect $g 84  0  5  4 "#906018"  # paw top
Rect $g 84  4  5  2 "#906018"  # paw front face
# Claw marks on paw front
Px $g 84 5 "#2A1A00"
Px $g 86 5 "#2A1A00"
Px $g 88 5 "#2A1A00"

# ── BACK THIGH [52,12] W=5 H=6 D=5 ──────────────────────────────────────────
# Front face: [57,17]→[62,23]
Rect $g 52 12 20 11 "#BE8820"  # back thigh — slightly darker (muscular)
Rect $g 57 12  5  5 "#AE7818"  # top cap
Rect $g 57 17  5  6 "#BE8820"  # front face

# ── BACK SHIN [72,12] W=3 H=6 D=3 ───────────────────────────────────────────
Rect $g 72 12 12 12 "#B08028"  # back shin
Rect $g 75 12  3  3 "#906018"  # top
Rect $g 75 15  3  6 "#B08028"  # front face

# ── BACK PAW [84,12] W=5 H=2 D=5 ────────────────────────────────────────────
Rect $g 84 12 20  7 "#906018"  # back paw — wider/flatter
Rect $g 89 12  5  5 "#804010"  # top
Rect $g 89 17  5  2 "#804010"  # front face
# Back claw marks
Px $g 89 18 "#2A1A00"
Px $g 91 18 "#2A1A00"
Px $g 93 18 "#2A1A00"

# ── TAIL SHAFT [98,0] W=2 H=2 D=8 ──────────────────────────────────────────
# UV layout [98,0]→[118,10]
# Top=[106,0]→[108,8] (2×8)  Left=[98,8]→[106,10] (8×2)  Front=[106,8]→[108,10]
Rect $g 98  0 20 10 "#B08030"          # shaft base
Rect $g 106  0  2  8 "#D4A850"         # top face — lighter (lit from above)
Rect $g  98  8  8  2 "#806020"         # underside — darker shadow
# Fur streaks along top face — alternating light/dark across the 8px length
foreach ($tz in @(0,2,4,6)) {
    Px $g 106 $tz "#E0B858"            # lighter streak
    Px $g 107 ($tz+1) "#9A7028"        # darker streak (offset for diagonal feel)
}


# ── TAIL DARK MID [98,12] W=2 H=2 D=3 ───────────────────────────────────────
# Same 2×2 cross-section as the shaft — seamless continuation, just darker
# UV: 2*(3+2)=10 wide, 3+2=5 tall → [98,12]→[108,17]
#   Top face:   [U+D,V]   = [101,12] size [2,3] → [101,12]→[103,15]
#   Front face: [U+D,V+D] = [101,15] size [2,2] → [101,15]→[103,17]
Rect $g  98 12 10  5 "#4A2800"          # mid section base — rich dark brown
Rect $g 101 12  2  3 "#6A3C10"          # top face — lighter (lit from above)
Rect $g  98 15  3  2 "#3A1C00"          # left side — in shadow
Rect $g 103 15  5  2 "#3A1C00"          # right side + back
Rect $g 101 15  2  2 "#5A3010"          # front face — visible face, mid-dark
# Fur streaks on top face matching shaft style
Px $g 101 12 "#8A5020"                  # light streak left
Px $g 102 13 "#3A1800"                  # dark streak right

# ── TAIL NARROW TIP [108,12] W=1 H=1 D=4 ────────────────────────────────────
# Narrows from 2×2 down to 1×1 — the actual point of the tail
# UV: 2*(4+1)=10 wide, 4+1=5 tall → [108,12]→[118,17]
#   Top face:   [U+D,V]   = [112,12] size [1,4] → [112,12]→[113,16]
#   Front face: [U+D,V+D] = [112,16] size [1,1] → [112,16]→[113,17]
Rect $g 108 12 10  5 "#1A0800"          # tip — near black (darkest)
Rect $g 112 12  1  4 "#2A1200"          # top face — faint warmth
Rect $g 112 16  1  1 "#0A0400"          # front face — absolute darkest pixel



# ── Generate 64x64 Jeep texture ───────────────────────────────────────────────
$jeepTexPath = Join-Path $scriptDir "lion_RP\textures\entity\jeep.png"
$jbmp = New-Bmp 64 64
$jg   = Get-Gfx $jbmp

# Base fill — desert tan
Rect $jg  0  0 64 64 "#C8A050"

# ── CHASSIS [0,0] W=10 H=3 D=14 ─────────────────────────────────────────────
# Top face [14,0]→[24,14]: sunlit lighter tan
Rect $jg 14  0 10 14 "#D4B060"
# Sides base [0,14]→[48,17]
Rect $jg  0 14 48  3 "#B89040"
# Front face of chassis [14,14]→[24,17]: darker, grille
Rect $jg 14 14 10  3 "#906830"
# Grille horizontal lines
Px $jg 15 15 "#1A1A1A" ; Px $jg 17 15 "#1A1A1A" ; Px $jg 19 15 "#1A1A1A"
Px $jg 21 15 "#1A1A1A" ; Px $jg 23 15 "#1A1A1A"
# Headlights on front face
Rect $jg 14 14  2  2 "#F0E870"  # left headlight
Rect $jg 22 14  2  2 "#F0E870"  # right headlight

# ── HOOD [0,18] W=8 H=3 D=5 ──────────────────────────────────────────────────
# All faces: tan base
Rect $jg  0 18 26  8 "#C8A050"
# Top face [5,18]→[13,23]: brightest (most sunlight)
Rect $jg  5 18  8  5 "#E0C070"
# Front face [5,23]→[13,26]: slightly darker
Rect $jg  5 23  8  3 "#B89040"

# ── CABIN [0,27] W=8 H=6 D=7 ─────────────────────────────────────────────────
# All faces: tan base
Rect $jg  0 27 30 13 "#C8A050"
# Top face [7,27]→[15,34]: tan top
Rect $jg  7 27  8  7 "#D4B060"
# FRONT face [7,34]→[15,40]: windshield (dark glass)
Rect $jg  7 34  8  6 "#141C28"
# Window pane highlight
Rect $jg  8 35  6  3 "#1E2E48"
# Windshield frame
Px $jg  7 34 "#B89040" ; Px $jg 14 34 "#B89040"  # top corners
Px $jg  7 39 "#B89040" ; Px $jg 14 39 "#B89040"  # bottom corners
# Side windows on left face [0,34]→[7,40]
Rect $jg  1 35  5  4 "#1E2E48"  # left side window
# Side windows on right face [23,34]→[30,40]
Rect $jg 24 35  5  4 "#1E2E48"  # right side window

# ── WHEELS [32,0] W=2 H=4 D=4 ───────────────────────────────────────────────
# All faces: dark tyre
Rect $jg 32  0 12  8 "#1A1A1A"
# Top face [36,0]→[38,4]: dark hub
Rect $jg 36  0  2  4 "#3A3A3A"
# Front face [36,4]→[38,8]: hub detail
Rect $jg 36  4  2  4 "#4A4A4A"
# Hub bolt
Px $jg 36  5 "#7A7A7A" ; Px $jg 37  6 "#7A7A7A"

$jg.Dispose()
$jbmp.Save($jeepTexPath, [System.Drawing.Imaging.ImageFormat]::Png)
$jbmp.Dispose()
Write-Host "  Jeep texture generated (64x64): $jeepTexPath" -ForegroundColor Green

$g.Dispose()

$bmp.Save($texPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "  Texture generated (128x64): $texPath" -ForegroundColor Green

# ── Pack icons (paw print on amber) ──────────────────────────────────────────
foreach ($packDir in @("lion_BP","lion_RP")) {
    $iconPath = Join-Path $scriptDir "$packDir\pack_icon.png"
    New-Item -ItemType Directory -Force -Path (Split-Path $iconPath) | Out-Null
    $icon = New-Bmp 64 64
    $ig   = Get-Gfx $icon
    $ig.Clear((Col "#C8922A"))
    $db = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(140,60,20,0))
    $ig.FillEllipse($db, 14, 20, 36, 28)  # main pad
    $ig.FillEllipse($db,  6, 10, 16, 13)  # toe 1
    $ig.FillEllipse($db, 24,  5, 16, 13)  # toe 2
    $ig.FillEllipse($db, 42, 10, 16, 13)  # toe 3
    $db.Dispose(); $ig.Dispose()
    $icon.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $icon.Dispose()
}
Write-Host "  Pack icons generated" -ForegroundColor Green

# ── Package .mcaddon ──────────────────────────────────────────────────────────
if (Test-Path $outFile) { Remove-Item $outFile }
$zip = [System.IO.Compression.ZipFile]::Open($outFile, "Create")
foreach ($packDir in @("lion_BP","lion_RP")) {
    $fullPack = Join-Path $scriptDir $packDir
    Get-ChildItem $fullPack -Recurse -File | ForEach-Object {
        $entry = "$packDir/" + $_.FullName.Substring($fullPack.Length+1).Replace("\","/")
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, $_.FullName, $entry,
            [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
}
$zip.Dispose()

Write-Host ""
Write-Host "  Built: $outFile" -ForegroundColor Green
Write-Host ""
Write-Host "=== Import Instructions ===" -ForegroundColor Cyan
Write-Host "  1. Double-click  lion_addon.mcaddon"
Write-Host "  2. Minecraft: 'Import started' -> 'Successfully imported'"
Write-Host "  3. Edit world -> activate BOTH packs (BP + RP)"
Write-Host "  5. /summon lion_pack:lion   or use Spawn Lion egg in Creative"
Write-Host "  6. Find wild lions in Savanna biomes"
Write-Host ""

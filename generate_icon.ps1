Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# --- Background: rounded rectangle with gradient ---
$bgRect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $bgRect,
    [System.Drawing.Color]::FromArgb(255, 30, 30, 65),   # Dark navy top
    [System.Drawing.Color]::FromArgb(255, 75, 20, 120),   # Deep purple bottom
    [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
)

# Rounded rect path for background
function New-RoundedRect($x, $y, $w, $h, $r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($x, $y, $r*2, $r*2, 180, 90)
    $path.AddArc($x + $w - $r*2, $y, $r*2, $r*2, 270, 90)
    $path.AddArc($x + $w - $r*2, $y + $h - $r*2, $r*2, $r*2, 0, 90)
    $path.AddArc($x, $y + $h - $r*2, $r*2, $r*2, 90, 90)
    $path.CloseFigure()
    return $path
}

$bgPath = New-RoundedRect 0 0 $size $size 180
$g.FillPath($bgBrush, $bgPath)

# --- Subtle radial glow in center ---
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(180, 180, 664, 664)
$glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(50, 140, 100, 255)
$glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 140, 100, 255))
$g.FillPath($glowBrush, $glowPath)

# --- Function to draw a die face ---
function Draw-Die($g, $cx, $cy, $dieSize, $rotation, $faceColor, $dotColor, $shadowColor, $dotCount) {
    $state = $g.Save()
    $g.TranslateTransform($cx, $cy)
    $g.RotateTransform($rotation)

    $half = $dieSize / 2
    $cornerR = $dieSize * 0.18

    # Shadow
    $shadowPath = New-RoundedRect (-$half + 8) (-$half + 8) $dieSize $dieSize $cornerR
    $shadowBrush = New-Object System.Drawing.SolidBrush($shadowColor)
    $g.FillPath($shadowBrush, $shadowPath)

    # Die body
    $diePath = New-RoundedRect (-$half) (-$half) $dieSize $dieSize $cornerR
    $dieBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle(-$half, -$half, $dieSize, $dieSize)),
        $faceColor,
        [System.Drawing.Color]::FromArgb($faceColor.A,
            [Math]::Max(0, $faceColor.R - 40),
            [Math]::Max(0, $faceColor.G - 40),
            [Math]::Max(0, $faceColor.B - 40)),
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )
    $g.FillPath($dieBrush, $diePath)

    # Subtle border/highlight
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), 3)
    $g.DrawPath($borderPen, $diePath)

    # Inner highlight (top-left shine)
    $shinePath = New-RoundedRect (-$half + 6) (-$half + 6) ($dieSize * 0.4) ($dieSize * 0.35) ($cornerR - 2)
    $shineBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, 255, 255, 255))
    $g.FillPath($shineBrush, $shinePath)

    # Dots
    $dotR = $dieSize * 0.09
    $offset = $dieSize * 0.27
    $dotBrush = New-Object System.Drawing.SolidBrush($dotColor)

    # Dot shadow
    $dotShadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 0, 0, 0))

    function Draw-Dot($gfx, $dx, $dy, $r, $db, $dsb) {
        $gfx.FillEllipse($dsb, ($dx - $r + 2), ($dy - $r + 2), $r*2, $r*2)
        $gfx.FillEllipse($db, ($dx - $r), ($dy - $r), $r*2, $r*2)
        # Small highlight on dot
        $hlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(50, 255, 255, 255))
        $gfx.FillEllipse($hlBrush, ($dx - $r*0.4), ($dy - $r*0.6), $r*0.8, $r*0.8)
    }

    # Draw dots based on count
    switch ($dotCount) {
        1 {
            Draw-Dot $g 0 0 $dotR $dotBrush $dotShadowBrush
        }
        2 {
            Draw-Dot $g (-$offset) (-$offset) $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g $offset $offset $dotR $dotBrush $dotShadowBrush
        }
        3 {
            Draw-Dot $g (-$offset) (-$offset) $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g 0 0 $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g $offset $offset $dotR $dotBrush $dotShadowBrush
        }
        4 {
            Draw-Dot $g (-$offset) (-$offset) $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g $offset (-$offset) $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g (-$offset) $offset $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g $offset $offset $dotR $dotBrush $dotShadowBrush
        }
        5 {
            Draw-Dot $g (-$offset) (-$offset) $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g $offset (-$offset) $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g 0 0 $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g (-$offset) $offset $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g $offset $offset $dotR $dotBrush $dotShadowBrush
        }
        6 {
            Draw-Dot $g (-$offset) (-$offset) $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g $offset (-$offset) $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g (-$offset) 0 $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g $offset 0 $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g (-$offset) $offset $dotR $dotBrush $dotShadowBrush
            Draw-Dot $g $offset $offset $dotR $dotBrush $dotShadowBrush
        }
    }

    $g.Restore($state)
}

# --- Draw two dice ---

# Die 1 (left, tilted -15°) - Red/crimson
Draw-Die $g 370 480 310 -15 `
    ([System.Drawing.Color]::FromArgb(255, 220, 50, 50)) `
    ([System.Drawing.Color]::White) `
    ([System.Drawing.Color]::FromArgb(80, 0, 0, 0)) `
    6

# Die 2 (right, tilted +12°) - White/cream
Draw-Die $g 660 530 310 12 `
    ([System.Drawing.Color]::FromArgb(255, 245, 245, 240)) `
    ([System.Drawing.Color]::FromArgb(255, 40, 40, 50)) `
    ([System.Drawing.Color]::FromArgb(80, 0, 0, 0)) `
    5

# --- Sparkle/star decorations ---
function Draw-Sparkle($gfx, $x, $y, $sparkleSize, $alpha) {
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($alpha, 255, 255, 255), 2.5)
    # Horizontal line
    $gfx.DrawLine($pen, ($x - $sparkleSize), $y, ($x + $sparkleSize), $y)
    # Vertical line
    $gfx.DrawLine($pen, $x, ($y - $sparkleSize), $x, ($y + $sparkleSize))
    # Diagonal lines (smaller)
    $ds = $sparkleSize * 0.6
    $gfx.DrawLine($pen, ($x - $ds), ($y - $ds), ($x + $ds), ($y + $ds))
    $gfx.DrawLine($pen, ($x + $ds), ($y - $ds), ($x - $ds), ($y + $ds))
    # Center glow
    $glowB = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb([int]($alpha * 0.7), 255, 255, 255))
    $gfx.FillEllipse($glowB, ($x - 3), ($y - 3), 6, 6)
}

Draw-Sparkle $g 170 200 22 200
Draw-Sparkle $g 850 180 16 160
Draw-Sparkle $g 130 700 14 130
Draw-Sparkle $g 880 650 18 170
Draw-Sparkle $g 500 150 12 140
Draw-Sparkle $g 820 420 10 100

# --- Small floating dots (particle effect) ---
$particleBrush1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 255, 200, 255))
$particleBrush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 200, 220, 255))

$g.FillEllipse($particleBrush1, 220, 350, 12, 12)
$g.FillEllipse($particleBrush2, 750, 300, 8, 8)
$g.FillEllipse($particleBrush1, 300, 800, 10, 10)
$g.FillEllipse($particleBrush2, 680, 820, 14, 14)
$g.FillEllipse($particleBrush1, 900, 500, 9, 9)
$g.FillEllipse($particleBrush2, 100, 500, 11, 11)

# --- Save ---
$outPath = Join-Path $PSScriptRoot "assets\icon_launcher.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()

Write-Host "Icon saved to $outPath ($size x $size)"


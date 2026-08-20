Add-Type -AssemblyName System.Drawing

# ==============================================================================
# 1. GENERATE 512x512 WARM MINDFUL ARCHWAY APP ICON
# ==============================================================================
$iconBmp = [System.Drawing.Bitmap]::new(512, 512)
$g = [System.Drawing.Graphics]::FromImage($iconBmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Background: Warm Organic Sand & Linen Gradient
$pt0 = [System.Drawing.Point]::new(0, 0)
$pt512 = [System.Drawing.Point]::new(512, 512)
$cSandLight = [System.Drawing.Color]::FromArgb(255, 252, 248, 243)
$cSandWarm = [System.Drawing.Color]::FromArgb(255, 238, 226, 214)
$bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($pt0, $pt512, $cSandLight, $cSandWarm)
$g.FillRectangle($bgBrush, 0, 0, 512, 512)

# Outer Frame
$framePen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(60, 180, 130, 100), 2)
$g.DrawRectangle($framePen, 20, 20, 472, 472)

# 1. Radiant Glowing Rising Sun in Center
$sunBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Point]::new(256, 130),
    [System.Drawing.Point]::new(256, 290),
    [System.Drawing.Color]::FromArgb(255, 248, 185, 120),
    [System.Drawing.Color]::FromArgb(255, 224, 130, 95)
)
$g.FillEllipse($sunBrush, 176, 130, 160, 160)

# 2. Rolling Dune / Mountain Waves behind arch
$mountainPath1 = [System.Drawing.Drawing2D.GraphicsPath]::new()
$mountainPath1.AddLines([System.Drawing.Point[]]@(
    [System.Drawing.Point]::new(100, 380),
    [System.Drawing.Point]::new(180, 230),
    [System.Drawing.Point]::new(280, 260),
    [System.Drawing.Point]::new(412, 380)
))
$mountainPath1.CloseFigure()
$mBrush1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 214, 166, 142))
$g.FillPath($mBrush1, $mountainPath1)

$mountainPath2 = [System.Drawing.Drawing2D.GraphicsPath]::new()
$mountainPath2.AddLines([System.Drawing.Point[]]@(
    [System.Drawing.Point]::new(100, 380),
    [System.Drawing.Point]::new(240, 280),
    [System.Drawing.Point]::new(340, 240),
    [System.Drawing.Point]::new(412, 380)
))
$mountainPath2.CloseFigure()
$mBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 186, 136, 112))
$g.FillPath($mBrush2, $mountainPath2)

# 3. Architectural Mindful Archway Outline
$archPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$archPath.AddArc(126, 80, 260, 260, 180, 180)
$archPath.AddLine(386, 210, 386, 385)
$archPath.AddLine(386, 385, 126, 385)
$archPath.AddLine(126, 385, 126, 210)
$archPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 138, 85, 62), 7)
$g.DrawPath($archPen, $archPath)

# Inner Arch accent line
$innerArchPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
$innerArchPath.AddArc(142, 96, 228, 228, 180, 180)
$innerArchPath.AddLine(370, 210, 370, 385)
$innerArchPath.AddLine(370, 385, 142, 385)
$innerArchPath.AddLine(142, 385, 142, 210)
$innerArchPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(180, 214, 172, 148), 3)
$g.DrawPath($innerArchPen, $innerArchPath)

# 4. Organic Botanical Palm / Olive Leaves Framing Left & Right
$leafBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240, 95, 65, 50))
$g.FillEllipse($leafBrush, 75, 260, 45, 18)
$g.FillEllipse($leafBrush, 65, 290, 48, 18)
$g.FillEllipse($leafBrush, 70, 320, 52, 20)

$g.FillEllipse($leafBrush, 392, 260, 45, 18)
$g.FillEllipse($leafBrush, 398, 290, 48, 18)
$g.FillEllipse($leafBrush, 390, 320, 52, 20)

# 5. Bottom Brand Typography: "A V A N"
$sf = [System.Drawing.StringFormat]::new()
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center

$titleFont = [System.Drawing.Font]::new('Georgia', 34, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$titleBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 60, 40, 30))
$rectTitle = [System.Drawing.RectangleF]::new(0, 405, 512, 45)
$g.DrawString('A V A N', $titleFont, $titleBrush, $rectTitle, $sf)

$tagFont = [System.Drawing.Font]::new('Arial', 12, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$tagBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(200, 140, 100, 80))
$rectTag = [System.Drawing.RectangleF]::new(0, 452, 512, 25)
$g.DrawString('MINDSET & AFFIRMATIONS', $tagFont, $tagBrush, $rectTag, $sf)

$g.Dispose()
$iconBmp.Save('playstore_icon_512.png', [System.Drawing.Imaging.ImageFormat]::Png)
$iconBmp.Dispose()


# ==============================================================================
# 2. GENERATE 1024x500 WARM AESTHETIC FEATURE GRAPHIC
# ==============================================================================
$fgBmp = [System.Drawing.Bitmap]::new(1024, 500)
$g2 = [System.Drawing.Graphics]::FromImage($fgBmp)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g2.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Background: Soothing Sand to Warm Terracotta Gradient
$ptFg1 = [System.Drawing.Point]::new(0, 0)
$ptFg2 = [System.Drawing.Point]::new(1024, 500)
$cFg1 = [System.Drawing.Color]::FromArgb(255, 253, 249, 244)
$cFg2 = [System.Drawing.Color]::FromArgb(255, 235, 218, 204)
$fgBg = [System.Drawing.Drawing2D.LinearGradientBrush]::new($ptFg1, $ptFg2, $cFg1, $cFg2)
$g2.FillRectangle($fgBg, 0, 0, 1024, 500)

# Ambient Warm Sun Halo on the Left
$haloBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(80, 250, 200, 150))
$g2.FillEllipse($haloBrush, 40, 40, 360, 360)

# Sun Inside Left Artwork
$fgSunBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Point]::new(220, 100),
    [System.Drawing.Point]::new(220, 260),
    [System.Drawing.Color]::FromArgb(255, 248, 185, 120),
    [System.Drawing.Color]::FromArgb(255, 224, 130, 95)
)
$g2.FillEllipse($fgSunBrush, 140, 100, 160, 160)

# Dunes inside Left Artwork
$fgM1 = [System.Drawing.Drawing2D.GraphicsPath]::new()
$fgM1.AddLines([System.Drawing.Point[]]@(
    [System.Drawing.Point]::new(70, 390),
    [System.Drawing.Point]::new(160, 220),
    [System.Drawing.Point]::new(260, 260),
    [System.Drawing.Point]::new(370, 390)
))
$fgM1.CloseFigure()
$g2.FillPath([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 214, 166, 142)), $fgM1)

$fgM2 = [System.Drawing.Drawing2D.GraphicsPath]::new()
$fgM2.AddLines([System.Drawing.Point[]]@(
    [System.Drawing.Point]::new(70, 390),
    [System.Drawing.Point]::new(220, 280),
    [System.Drawing.Point]::new(310, 230),
    [System.Drawing.Point]::new(370, 390)
))
$fgM2.CloseFigure()
$g2.FillPath([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 186, 136, 112)), $fgM2)

# Archway on Left
$fgArch = [System.Drawing.Drawing2D.GraphicsPath]::new()
$fgArch.AddArc(90, 70, 260, 260, 180, 180)
$fgArch.AddLine(350, 200, 350, 390)
$fgArch.AddLine(350, 390, 90, 390)
$fgArch.AddLine(90, 390, 90, 200)
$g2.DrawPath([System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 138, 85, 62), 6), $fgArch)

# Botanical leaves on left
$g2.FillEllipse($leafBrush, 45, 270, 46, 18)
$g2.FillEllipse($leafBrush, 38, 300, 48, 18)
$g2.FillEllipse($leafBrush, 42, 330, 52, 20)

$g2.FillEllipse($leafBrush, 352, 270, 46, 18)
$g2.FillEllipse($leafBrush, 358, 300, 48, 18)
$g2.FillEllipse($leafBrush, 350, 330, 52, 20)

# ==============================================================================
# RIGHT SIDE EDITORIAL TYPOGRAPHY & HIGHLIGHTS
# ==============================================================================
$sfLeft = [System.Drawing.StringFormat]::new()
$sfLeft.Alignment = [System.Drawing.StringAlignment]::Near
$sfLeft.LineAlignment = [System.Drawing.StringAlignment]::Center

# Badge: DAILY MINDSET & AFFIRMATIONS
$badgeBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 240, 224, 212))
$g2.FillRectangle($badgeBg, 430, 95, 290, 32)
$g2.DrawRectangle([System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(180, 200, 160, 140), 1), 430, 95, 290, 32)
$badgeFont = [System.Drawing.Font]::new('Arial', 11, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$badgeTextBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 140, 80, 55))
$g2.DrawString('PSYCHOLOGICAL REFLECTION', $badgeFont, $badgeTextBrush, [System.Drawing.RectangleF]::new(430, 95, 290, 32), $sf)

# Title: AVAN
$titleFont2 = [System.Drawing.Font]::new('Georgia', 54, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$titleBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 55, 35, 25))
$rectTitle2 = [System.Drawing.RectangleF]::new(430, 155, 540, 60)
$g2.DrawString('A V A N', $titleFont2, $titleBrush2, $rectTitle2, $sfLeft)

# Subtitle
$subTitleFont2 = [System.Drawing.Font]::new('Georgia', 21, [System.Drawing.FontStyle]::Italic, [System.Drawing.GraphicsUnit]::Pixel)
$subTitleBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 140, 85, 60))
$rectSub2 = [System.Drawing.RectangleF]::new(430, 220, 540, 35)
$g2.DrawString('Rewire your subconscious with serene audio cadence', $subTitleFont2, $subTitleBrush2, $rectSub2, $sfLeft)

# Feature Bullets
$bulletFont = [System.Drawing.Font]::new('Arial', 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bulletBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 90, 65, 50))
$g2.DrawString('+ 16D Personalized Affirmation Engine Across 11 Archetypes', $bulletFont, $bulletBrush, [System.Drawing.RectangleF]::new(430, 270, 540, 25), $sfLeft)
$g2.DrawString('+ Calibrated 18s Audio Pacing (6s Voice + 12s Reflection Silence)', $bulletFont, $bulletBrush, [System.Drawing.RectangleF]::new(430, 300, 540, 25), $sfLeft)
$g2.DrawString('+ 100% Offline Solfeggio Soundscapes, Voice Studio & Vision Board', $bulletFont, $bulletBrush, [System.Drawing.RectangleF]::new(430, 330, 540, 25), $sfLeft)

# Bottom Privacy Pill
$privBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g2.FillRectangle($privBrush, 430, 380, 280, 36)
$g2.DrawRectangle([System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(120, 160, 120, 95), 1.2), 430, 380, 280, 36)
$privFont = [System.Drawing.Font]::new('Arial', 12, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$privTextBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 110, 65, 45))
$g2.DrawString('100% Private & On-Device Storage', $privFont, $privTextBrush, [System.Drawing.RectangleF]::new(430, 380, 280, 36), $sf)

$g2.Dispose()
$fgBmp.Save('playstore_feature_graphic_1024x500.png', [System.Drawing.Imaging.ImageFormat]::Png)
$fgBmp.Dispose()

Write-Output 'SUCCESS: Generated aesthetic warm Archway App Icon and Feature Graphic matching AVAN theme!'

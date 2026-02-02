package com.cfore.hittracker.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import com.cfore.hittracker.data.Hit
import com.cfore.hittracker.data.HitType
import com.cfore.hittracker.ui.theme.*

@Composable
fun SoftballField(
    hits: List<Hit>,
    onFieldTap: ((Double, Double) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Canvas(
        modifier = modifier
            .aspectRatio(1f)
            .padding(8.dp)
            .then(
                if (onFieldTap != null) {
                    Modifier.pointerInput(Unit) {
                        detectTapGestures { offset ->
                            val x = offset.x / size.width
                            val y = offset.y / size.height
                            onFieldTap(x.toDouble(), y.toDouble())
                        }
                    }
                } else Modifier
            )
    ) {
        val width = size.width
        val height = size.height
        val centerX = width / 2
        val homeY = height * 0.85f
        val fieldRadius = width * 0.8f

        // Draw outfield grass
        drawOutfield(centerX, homeY, fieldRadius)

        // Draw infield dirt
        drawInfield(centerX, homeY, width)

        // Draw base paths
        drawBasePaths(centerX, homeY, width)

        // Draw bases
        drawBases(centerX, homeY, width)

        // Draw hits
        hits.forEach { hit ->
            val hitX = (hit.locationX * width).toFloat()
            val hitY = (hit.locationY * height).toFloat()
            val color = getHitColor(hit.hitType)
            drawCircle(
                color = color,
                radius = 12f,
                center = Offset(hitX, hitY)
            )
            drawCircle(
                color = Color.White,
                radius = 12f,
                center = Offset(hitX, hitY),
                style = Stroke(width = 2f)
            )
        }
    }
}

private fun DrawScope.drawOutfield(centerX: Float, homeY: Float, radius: Float) {
    val path = Path().apply {
        moveTo(centerX, homeY)
        lineTo(centerX - radius * 0.7f, homeY - radius)
        quadraticBezierTo(
            centerX, homeY - radius * 1.1f,
            centerX + radius * 0.7f, homeY - radius
        )
        close()
    }
    drawPath(path, FieldGreen)
}

private fun DrawScope.drawInfield(centerX: Float, homeY: Float, width: Float) {
    val infieldSize = width * 0.35f
    val path = Path().apply {
        moveTo(centerX, homeY)
        lineTo(centerX - infieldSize, homeY - infieldSize)
        lineTo(centerX, homeY - infieldSize * 2)
        lineTo(centerX + infieldSize, homeY - infieldSize)
        close()
    }
    drawPath(path, DirtBrown.copy(alpha = 0.7f))
}

private fun DrawScope.drawBasePaths(centerX: Float, homeY: Float, width: Float) {
    val baseDistance = width * 0.2f
    val lineWidth = 4f
    val lineColor = Color.White.copy(alpha = 0.8f)

    // Home to first
    drawLine(
        color = lineColor,
        start = Offset(centerX, homeY),
        end = Offset(centerX + baseDistance, homeY - baseDistance),
        strokeWidth = lineWidth
    )

    // First to second
    drawLine(
        color = lineColor,
        start = Offset(centerX + baseDistance, homeY - baseDistance),
        end = Offset(centerX, homeY - baseDistance * 2),
        strokeWidth = lineWidth
    )

    // Second to third
    drawLine(
        color = lineColor,
        start = Offset(centerX, homeY - baseDistance * 2),
        end = Offset(centerX - baseDistance, homeY - baseDistance),
        strokeWidth = lineWidth
    )

    // Third to home
    drawLine(
        color = lineColor,
        start = Offset(centerX - baseDistance, homeY - baseDistance),
        end = Offset(centerX, homeY),
        strokeWidth = lineWidth
    )
}

private fun DrawScope.drawBases(centerX: Float, homeY: Float, width: Float) {
    val baseDistance = width * 0.2f
    val baseSize = 16f

    // Home plate (pentagon)
    val homePath = Path().apply {
        moveTo(centerX, homeY)
        lineTo(centerX - baseSize / 2, homeY - baseSize / 2)
        lineTo(centerX - baseSize / 2, homeY - baseSize)
        lineTo(centerX + baseSize / 2, homeY - baseSize)
        lineTo(centerX + baseSize / 2, homeY - baseSize / 2)
        close()
    }
    drawPath(homePath, BaseWhite)

    // First base
    drawRect(
        color = BaseWhite,
        topLeft = Offset(centerX + baseDistance - baseSize / 2, homeY - baseDistance - baseSize / 2),
        size = Size(baseSize, baseSize)
    )

    // Second base
    drawRect(
        color = BaseWhite,
        topLeft = Offset(centerX - baseSize / 2, homeY - baseDistance * 2 - baseSize / 2),
        size = Size(baseSize, baseSize)
    )

    // Third base
    drawRect(
        color = BaseWhite,
        topLeft = Offset(centerX - baseDistance - baseSize / 2, homeY - baseDistance - baseSize / 2),
        size = Size(baseSize, baseSize)
    )
}

fun getHitColor(hitType: HitType): Color {
    return when (hitType) {
        HitType.FLY_BALL -> FlyBallColor
        HitType.LINE_DRIVE -> LineDriveColor
        HitType.POP_UP -> PopUpColor
        HitType.GROUNDER -> GrounderColor
    }
}

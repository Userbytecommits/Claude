package dev.game.runtime

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.SurfaceView
import android.view.SurfaceHolder
import dev.game.engine.core.GameEngine
import dev.game.engine.core.Scene
import dev.game.engine.utils.Vector2
import kotlin.math.max

class GameSurfaceView(context: Context, attrs: AttributeSet? = null) : SurfaceView(context, attrs),
    SurfaceHolder.Callback {

    private var gameEngine: GameEngine? = null
    private var renderThread: RenderThread? = null
    private var lastTouchTime = 0L

    init {
        holder.addCallback(this)
        isFocusable = true
        isFocusableInTouchMode = true
    }

    fun setGameEngine(engine: GameEngine) {
        this.gameEngine = engine
    }

    override fun surfaceCreated(holder: SurfaceHolder) {
        gameEngine?.let {
            it.start()
            renderThread = RenderThread(holder, it).also { thread ->
                thread.start()
            }
        }
    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {}

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        gameEngine?.stop()
        renderThread?.stopRendering()
        renderThread?.join(1000)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        gameEngine?.let { engine ->
            val x = event.x
            val y = event.y
            val pointerId = event.getPointerId(event.actionIndex)

            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN, MotionEvent.ACTION_POINTER_DOWN -> {
                    engine.inputManager.updateTouchDown(pointerId, x, y)
                }
                MotionEvent.ACTION_MOVE -> {
                    engine.inputManager.updateTouchMove(pointerId, x, y)
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_POINTER_UP -> {
                    engine.inputManager.updateTouchUp(pointerId)
                }
            }
        }
        return true
    }

    private inner class RenderThread(
        private val holder: SurfaceHolder,
        private val engine: GameEngine
    ) : Thread() {
        private var running = true
        private val targetFPS = 60
        private val frameTimeMs = 1000L / targetFPS

        fun stopRendering() {
            running = false
        }

        override fun run() {
            while (running) {
                val frameStartTime = System.currentTimeMillis()

                engine.update()

                try {
                    val canvas = holder.lockCanvas()
                    if (canvas != null) {
                        synchronized(holder) {
                            canvas.drawColor(Color.BLACK)
                            renderGame(canvas)
                        }
                        holder.unlockCanvasAndPost(canvas)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }

                val frameEndTime = System.currentTimeMillis()
                val frameDuration = frameEndTime - frameStartTime
                val sleepTime = max(0, frameTimeMs - frameDuration)

                if (sleepTime > 0) {
                    try {
                        Thread.sleep(sleepTime)
                    } catch (e: InterruptedException) {
                        e.printStackTrace()
                    }
                }
            }
        }

        private fun renderGame(canvas: Canvas) {
            val scene = engine.getCurrentScene() ?: return
            val entities = scene.getEntities()

            entities.forEach { entity ->
                val spriteComponent = entity.getComponent<dev.game.engine.graphics.SpriteComponent>()
                if (spriteComponent != null && entity.active) {
                    // Simple circle rendering for now (visual placeholder)
                    val paint = android.graphics.Paint().apply {
                        color = spriteComponent.tintColor
                    }

                    val radius = 32f
                    canvas.drawCircle(entity.position.x, entity.position.y, radius, paint)

                    // Draw entity name as debug info
                    val textPaint = android.graphics.Paint().apply {
                        color = Color.WHITE
                        textSize = 20f
                    }
                    canvas.drawText(entity.name, entity.position.x - 20, entity.position.y + 50, textPaint)
                }
            }
        }
    }
}

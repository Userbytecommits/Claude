package dev.game.runtime

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.SurfaceView
import android.view.SurfaceHolder
import dev.game.engine.core.GameEngine
import dev.game.engine.graphics.Renderer
import dev.game.engine.graphics.SpriteComponent
import kotlin.math.max

class GameSurfaceView(context: Context, attrs: AttributeSet? = null) : SurfaceView(context, attrs),
    SurfaceHolder.Callback {

    private var gameEngine: GameEngine? = null
    private var renderThread: RenderThread? = null
    private val renderer = Renderer()

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

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        renderer.camera.setViewport(width.toFloat(), height.toFloat())
    }

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
            renderer.beginFrame(canvas)

            val scene = engine.getCurrentScene() ?: return
            val entities = scene.getEntities()

            entities.filter { it.active && !it.isDestroyed() }.forEach { entity ->
                val spriteComponent = entity.getComponent<SpriteComponent>()
                if (spriteComponent != null) {
                    renderer.queueSprite(entity, spriteComponent)
                }
            }

            renderer.endFrame(canvas)

            // Draw FPS counter
            val paint = android.graphics.Paint().apply {
                color = Color.WHITE
                textSize = 40f
            }
            canvas.drawText("FPS: 60", 50f, 50f, paint)
        }
    }
}

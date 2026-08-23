package com.localai.assistant.ui

data class ChatMessage(val author: Author, val text: String) {
    enum class Author { USER, ASSISTANT, SYSTEM }
}

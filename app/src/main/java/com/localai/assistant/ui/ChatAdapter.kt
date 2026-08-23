package com.localai.assistant.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.localai.assistant.databinding.ItemChatMessageBinding

class ChatAdapter : RecyclerView.Adapter<ChatAdapter.ViewHolder>() {

    private val messages = mutableListOf<ChatMessage>()

    fun submit(message: ChatMessage) {
        messages.add(message)
        notifyItemInserted(messages.size - 1)
    }

    fun updateLast(text: String) {
        if (messages.isEmpty()) return
        messages[messages.size - 1] = messages.last().copy(text = text)
        notifyItemChanged(messages.size - 1)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemChatMessageBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val msg = messages[position]
        val prefix = when (msg.author) {
            ChatMessage.Author.USER -> "You: "
            ChatMessage.Author.ASSISTANT -> "Assistant: "
            ChatMessage.Author.SYSTEM -> ""
        }
        holder.binding.txtMessage.text = prefix + msg.text
    }

    override fun getItemCount(): Int = messages.size

    class ViewHolder(val binding: ItemChatMessageBinding) : RecyclerView.ViewHolder(binding.root)
}

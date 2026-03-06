class AiChatsController < ApplicationController
  before_action :authenticate_user!

  def create
    question = params[:question]

    # Build portfolio context
    total = current_user.assets.sum(:value)
    assets_list = current_user.assets.map { |a| "#{a.name} (#{a.category}): €#{a.value}" }.join(", ")
    category_breakdown = current_user.assets.group(:category).sum(:value)
      .map { |cat, val| "#{cat}: €#{val} (#{(val/total*100).round(1)}%)" }.join(", ")

    context = "User's portfolio: Total net worth €#{total}. Assets: #{assets_list}. Breakdown: #{category_breakdown}."

    # Call OpenAI
    answer = ask_ai(question, context)

    # Return as turbo stream to append to chat
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "ai-messages",
          partial: "ai_chats/message",
          locals: { question: question, answer: answer }
        )
      end
    end
  end

  private

  def ask_ai(question, context)
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "You are a helpful financial advisor. #{context} Be concise and friendly. Use bullet points for lists. Keep responses under 150 words." },
          { role: "user", content: question }
        ],
        temperature: 0.7,
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue => e
    "I'm having trouble connecting right now. Please try again!"
  end
end

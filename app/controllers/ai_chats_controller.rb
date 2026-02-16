class AiChatsController < ApplicationController
  before_action :authenticate_user!

  def create
    question = params[:question]

    if question.blank?
      redirect_to root_path, alert: "Please type a question!"
      return
    end

    @answer = ask_ai(question)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "ai-response",
          partial: "ai_chats/response",
          locals: { question: question, answer: @answer }
        )
      end
      format.html { redirect_to root_path }
    end
  end

  private

  # Builds the user's portfolio data to send to OpenAI
  def portfolio_context
    total = current_user.assets.sum(:value)
    breakdown = current_user.assets.group(:category).sum(:value)
    assets_list = current_user.assets
                               .map { |a| "#{a.name} (#{a.category}): $#{a.value}" }
                               .join(", ")

    "User's Financial Portfolio:\n" \
    "- Total Net Worth: $#{total}\n" \
    "- Assets: #{assets_list}\n" \
    "- Breakdown by category: #{breakdown.map { |k, v| "#{k}: $#{v}" }.join(", ")}"
  end

  
  def ask_ai(question)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "You are a friendly and knowledgeable financial advisor assistant. " \
                     "You have access to the user's portfolio data and can give personalized advice. " \
                     "Keep responses concise, clear and actionable. " \
                     "Always be encouraging and positive while being honest about risks. " \
                     "Format your responses in plain text without markdown symbols like ** or ##."
          },
          {
            role: "user",
            content: "#{portfolio_context}\n\nQuestion: #{question}"
          }
        ],
        max_tokens: 500,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue => e
    "Sorry, I couldn't process your question right now. Please try again."
  end
end

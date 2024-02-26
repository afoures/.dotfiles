function set_emoji {
  current_emoji="$1"
}

function random_emoji {
  local EMOJIS=("🚀" "👻" "🤖" "🦄" "🐳" "🦁" "🦊" "🐙" "🦖" "🦕" "🐢" "👀" "🧠" "💭")
  set_emoji "${EMOJIS[$RANDOM % ${#EMOJIS[@]}]}"
}

alias blastoff="set_emoji 🚀"
alias trex="set_emoji 🦖"
alias octopus="set_emoji 🐙"
alias rde="random_emoji"

random_emoji

#!/usr/bin/env bash
# claude code status line: context, cost and cache on the left; rate limits, version, model and
# effort on the right
#   46.2k (5%) · $1.23 · →14:35          5h 2% · 7d 10% · v2.1.318 | Opus 5.5 · medium
# percentages turn green → yellow (≥50%) → red (≥80%); the cache expiry is blue, or yellow "cold";
# labels, separators, cost and version are dimmed; tokens, model and effort stay plain.
# leave a small margin so the line never wraps
cols=$(( ${COLUMNS:-80} - 4 ))
jq -r --argjson cols "$cols" '
  # a segment is a list of [text, ansi-code] parts; code "" means no styling
  def dim: [., "2"];
  def plain: [., ""];
  def level: if . >= 80 then "31" elif . >= 50 then "33" else "32" end;
  def pct: [ "\(round)%", level ];
  def raw: map(.[0]) | join("");
  def styled: map(if .[1] == "" then .[0] else "\u001b[\(.[1])m\(.[0])\u001b[0m" end) | join("");
  def segments: map(select(. != null));
  # join segments with a dim separator, returning one flat list of parts
  def joined: [ to_entries[] | (if .key > 0 then [" · " | dim] else [] end) + .value ] | add // [];

  .context_window as $c
  | ($c.current_usage // {}) as $u
  | (($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0)) as $t
  | [ (if $t >= 1000 then "\(($t / 100 | floor) / 10)k" else "\($t)" end | plain),
      (" (" | plain), (($c.used_percentage // 0) | pct), (")" | plain) ] as $ctx

  | (.rate_limits.five_hour.used_percentage | if . == null then null else [("5h " | dim), pct] end) as $five
  | (.rate_limits.seven_day.used_percentage | if . == null then null else [("7d " | dim), pct] end) as $seven

  # the status line re-runs when the cache expires, so a fixed expiry time stays accurate
  | (.prompt_cache as $p
     | if $p == null then null
       elif $p.warm and $p.expires_at then [["→\($p.expires_at | strflocaltime("%H:%M"))", "34"]]
       else [["cold", "33"]] end) as $cache

  # session cost in gray, always with two decimals
  | (.cost.total_cost_usd
     | if . == null then null
       else (. * 100 | round) as $cents
       | [["$\($cents / 100 | floor).\($cents % 100 | tostring | if length < 2 then "0" + . else . end)", "2"]]
       end) as $cost

  | ([$ctx, $cost, $cache] | segments | joined) as $left
  | ([ $five, $seven,
       ([ (if .version then ["v\(.version) | ", "2"] else null end),
          ((.model.display_name // .model.id) | if . then plain else null end) ] | segments
          | if length > 0 then . else null end),
       (.effort.level | if . then [plain] else null end)
     ] | segments | joined) as $right

  | ([$cols - ($left | raw | length) - ($right | raw | length), 1] | max) as $pad
  | ($left | styled) + (" " * $pad // "") + ($right | styled)
'

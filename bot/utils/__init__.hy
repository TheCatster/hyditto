(import
  [.config [Config]]
  [.embeds [create_embed wait_for_choice]])

(setv config (Config))

(defn get_guild_prefix [_bot guild_id]
  (setv prefix config.prefix)
  (try
    (setv guild_data (get _bot.guild_data guild_id))
    (setv _prefix guild_data.prefix)
    (if (_prefix is not None) (setv prefix _prefix))
    (except [KeyError]
      None))
  (return prefix))
